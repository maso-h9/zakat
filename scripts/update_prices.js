// ================================================================
// update_prices.js — يعمل عبر GitHub Actions (مجاني بالكامل)
// يجلب أسعار الذهب/الفضة، يحسب النصاب لكل عملة، يكتب في Firestore
// ================================================================
const admin = require("firebase-admin");
const https = require("https");

// ────────────────────────────────────────────────────
// تهيئة Firebase Admin من متغيرات البيئة (GitHub Secrets)
// ────────────────────────────────────────────────────
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();

// ────────────────────────────────────────────────────
// أسعار الصرف الاحتياطية (لو فشل API الصرف)
// ────────────────────────────────────────────────────
const FALLBACK_FX = {
  LYD: 4.85, SAR: 3.75, AED: 3.67, EGP: 30.9,
  USD: 1.0,  EUR: 0.92, GBP: 0.79, KWD: 0.31,
  QAR: 3.64, JOD: 0.71, MAD: 10.1, TND: 3.12,
  DZD: 134.5, MYR: 4.7, IDR: 15800, PKR: 278.0,
};

const GOLD_NISAB_GRAMS   = 85;
const SILVER_NISAB_GRAMS = 595;

// ────────────────────────────────────────────────────
// مساعد HTTP عام مع دعم headers
// ────────────────────────────────────────────────────
function fetchJSON(url, headers = {}) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, { headers, timeout: 8000 }, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        try { resolve(JSON.parse(data)); }
        catch (e) { reject(new Error("Invalid JSON: " + e.message)); }
      });
    });
    req.on("error", reject);
    req.on("timeout", () => { req.destroy(); reject(new Error("timeout")); });
  });
}

// ────────────────────────────────────────────────────
// جلب سعر الذهب — 3 مزودين بالترتيب
// ────────────────────────────────────────────────────
async function fetchGoldUSD() {
  // المزود 1: GoldAPI (إذا وضعت مفتاح في Secrets)
  if (process.env.GOLDAPI_KEY) {
    try {
      const data = await fetchJSON("https://www.goldapi.io/api/XAU/USD", {
        "x-access-token": process.env.GOLDAPI_KEY,
      });
      if (data && data.price) {
        console.log("✅ GoldAPI:", data.price);
        return { priceUSD: data.price, source: "goldapi" };
      }
    } catch (e) { console.warn("⚠️ GoldAPI failed:", e.message); }
  }

  // المزود 2: metals.live (مجاني بدون مفتاح)
  try {
    const data = await fetchJSON("https://metals.live/api/v1/spot/gold");
    const price = Array.isArray(data) ? data[0]?.gold : data?.gold;
    if (price) {
      console.log("✅ metals.live:", price);
      return { priceUSD: price, source: "metals.live" };
    }
  } catch (e) { console.warn("⚠️ metals.live failed:", e.message); }

  // المزود 3: metals-api.com (احتياطي إضافي إن وُجد مفتاح)
  if (process.env.METALS_API_KEY) {
    try {
      const data = await fetchJSON(
        `https://metals-api.com/api/latest?access_key=${process.env.METALS_API_KEY}&base=USD&symbols=XAU`
      );
      const price = data?.rates?.USDXAU ? 1 / data.rates.USDXAU : null;
      if (price) {
        console.log("✅ metals-api.com:", price);
        return { priceUSD: price, source: "metals-api" };
      }
    } catch (e) { console.warn("⚠️ metals-api.com failed:", e.message); }
  }

  console.warn("❌ كل المزودين فشلوا — سنستخدم آخر سعر محفوظ في Firestore");
  return null;
}

// ────────────────────────────────────────────────────
// جلب أسعار الصرف
// ────────────────────────────────────────────────────
async function fetchFxRates() {
  try {
    const data = await fetchJSON("https://open.er-api.com/v6/latest/USD");
    if (data && data.rates) {
      console.log("✅ FX rates fetched");
      return data.rates;
    }
  } catch (e) { console.warn("⚠️ FX rates failed:", e.message); }
  console.warn("استخدام أسعار الصرف الاحتياطية");
  return FALLBACK_FX;
}

// ────────────────────────────────────────────────────
// حساب النصاب لكل عملة
// ────────────────────────────────────────────────────
function computeNisab(goldUsdPerOz, silverUsdPerOz, fxRates) {
  const goldPerGramUSD   = goldUsdPerOz   / 31.1035;
  const silverPerGramUSD = silverUsdPerOz / 31.1035;
  const nisab = {};
  for (const [currency, fallbackRate] of Object.entries(FALLBACK_FX)) {
    const fx = fxRates[currency] ?? fallbackRate;
    nisab[currency] = {
      goldPricePerGram:   parseFloat((goldPerGramUSD   * fx).toFixed(4)),
      silverPricePerGram: parseFloat((silverPerGramUSD * fx).toFixed(4)),
      goldNisab:   parseFloat((goldPerGramUSD   * GOLD_NISAB_GRAMS   * fx).toFixed(2)),
      silverNisab: parseFloat((silverPerGramUSD * SILVER_NISAB_GRAMS * fx).toFixed(2)),
    };
  }
  return nisab;
}

// ────────────────────────────────────────────────────
// التنفيذ الرئيسي
// ────────────────────────────────────────────────────
async function main() {
  console.log("🚀 بدء تحديث الأسعار —", new Date().toISOString());

  const docRef = db.collection("prices").doc("latest");
  const existing = await docRef.get();
  const lastGoldUSD   = existing.data()?.goldUsdPerOz   ?? 2350;
  const lastSilverUSD = existing.data()?.silverUsdPerOz ?? 27.5;

  const [goldResult, fxRates] = await Promise.all([
    fetchGoldUSD(),
    fetchFxRates(),
  ]);

  const goldUSD   = goldResult?.priceUSD ?? lastGoldUSD;
  const silverUSD = lastSilverUSD; // لا يوجد مزود فضة مجاني حالياً

  const nisab = computeNisab(goldUSD, silverUSD, fxRates);

  await docRef.set({
    goldUsdPerOz:   goldUSD,
    silverUsdPerOz: silverUSD,
    nisab,
    source:    goldResult?.source ?? "cached",
    updatedAt: new Date().toISOString(),
  });

  console.log(`✅ تم التحديث. الذهب: $${goldUSD}/oz — المصدر: ${goldResult?.source ?? "cached"}`);
  process.exit(0);
}

main().catch((err) => {
  console.error("❌ فشل غير متوقع:", err);
  process.exit(1);
});