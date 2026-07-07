// ================================================================
// update_prices.js — GitHub Actions (مجاني 100%)
// ترتيب المزودين:
//   ① gold-api.com   — مجاني، بلا مفتاح، بلا rate limit (الأول دائماً)
//   ② GOLDAPI_KEY    — إن وُجد في GitHub Secrets
//   ③ METALS_API_KEY — إن وُجد في GitHub Secrets
//   ④ آخر سعر Firestore — إذا فشل الجميع
//
// يجلب الذهب والفضة معاً من المزود الأول
// ================================================================
const admin = require("firebase-admin");
const https  = require("https");

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

const GOLD_NISAB_GRAMS   = 85;
const SILVER_NISAB_GRAMS = 595;

const FALLBACK_FX = {
  LYD: 4.85,  SAR: 3.75,  AED: 3.67,  EGP: 30.9,
  USD: 1.0,   EUR: 0.92,  GBP: 0.79,  KWD: 0.31,
  QAR: 3.64,  JOD: 0.71,  MAD: 10.1,  TND: 3.12,
  DZD: 134.5, MYR: 4.7,   IDR: 15800, PKR: 278.0,
};

// ── HTTP helper ───────────────────────────────────────────────
function fetchJSON(url, headers = {}) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, { headers, timeout: 9000 }, (res) => {
      let data = "";
      res.on("data", (c) => (data += c));
      res.on("end", () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch (e) { reject(new Error("Invalid JSON from " + url)); }
      });
    });
    req.on("error", reject);
    req.on("timeout", () => { req.destroy(); reject(new Error("timeout: " + url)); });
  });
}

// ── جلب الذهب والفضة ─────────────────────────────────────────
async function fetchMetals() {

  // ① gold-api.com — مجاني بلا مفتاح (الأول دائماً)
  try {
    const [goldRes, silverRes] = await Promise.all([
      fetchJSON("https://api.gold-api.com/price/XAU"),
      fetchJSON("https://api.gold-api.com/price/XAG"),
    ]);
    const goldUSD   = goldRes.body?.price;
    const silverUSD = silverRes.body?.price;
    if (goldRes.status === 200 && goldUSD) {
      console.log(`✅ [1] gold-api.com — ذهب: $${goldUSD} | فضة: $${silverUSD ?? "N/A"}`);
      return { goldUSD, silverUSD: silverUSD ?? null, source: "gold-api.com" };
    }
    console.warn("⚠️ [1] gold-api.com: بيانات غير صالحة");
  } catch (e) { console.warn("⚠️ [1] gold-api.com فشل:", e.message); }

  // ② GoldAPI.io — يحتاج GOLDAPI_KEY
  if (process.env.GOLDAPI_KEY) {
    try {
      const [gRes, sRes] = await Promise.all([
        fetchJSON("https://www.goldapi.io/api/XAU/USD", { "x-access-token": process.env.GOLDAPI_KEY }),
        fetchJSON("https://www.goldapi.io/api/XAG/USD", { "x-access-token": process.env.GOLDAPI_KEY }),
      ]);
      if (gRes.status === 200 && gRes.body?.price) {
        console.log(`✅ [2] GoldAPI — ذهب: $${gRes.body.price} | فضة: $${sRes.body?.price ?? "N/A"}`);
        return { goldUSD: gRes.body.price, silverUSD: sRes.body?.price ?? null, source: "goldapi" };
      }
      console.warn("⚠️ [2] GoldAPI:", gRes.status, gRes.body?.error ?? "");
    } catch (e) { console.warn("⚠️ [2] GoldAPI فشل:", e.message); }
  } else {
    console.log("ℹ️ [2] GOLDAPI_KEY غير موجود — تخطّي");
  }

  // ③ Metals-API — يحتاج METALS_API_KEY
  if (process.env.METALS_API_KEY) {
    try {
      const url = `https://metals-api.com/api/latest?access_key=${process.env.METALS_API_KEY}&base=USD&symbols=XAU,XAG`;
      const { status, body } = await fetchJSON(url);
      const xau = body?.rates?.XAU;
      const xag = body?.rates?.XAG;
      const goldUSD   = xau ? (xau < 1 ? 1 / xau : xau) : null;
      const silverUSD = xag ? (xag < 1 ? 1 / xag : xag) : null;
      if (status === 200 && goldUSD && goldUSD > 100) {
        console.log(`✅ [3] Metals-API — ذهب: $${goldUSD} | فضة: $${silverUSD ?? "N/A"}`);
        return { goldUSD, silverUSD, source: "metals-api" };
      }
      console.warn("⚠️ [3] Metals-API: بيانات غير صالحة");
    } catch (e) { console.warn("⚠️ [3] Metals-API فشل:", e.message); }
  } else {
    console.log("ℹ️ [3] METALS_API_KEY غير موجود — تخطّي");
  }

  console.warn("❌ كل المزودين فشلوا");
  return null;
}

// ── أسعار الصرف ───────────────────────────────────────────────
async function fetchFxRates() {
  try {
    const { status, body } = await fetchJSON("https://open.er-api.com/v6/latest/USD");
    if (status === 200 && body?.rates) {
      console.log("✅ FX rates محدَّثة");
      return body.rates;
    }
  } catch (e) { console.warn("⚠️ FX rates فشلت:", e.message); }
  return FALLBACK_FX;
}

// ── حساب النصاب ───────────────────────────────────────────────
function computeNisab(goldUsdPerOz, silverUsdPerOz, fxRates) {
  const gUSD = goldUsdPerOz   / 31.1035;
  const sUSD = silverUsdPerOz / 31.1035;
  const result = {};
  for (const [cur, fallback] of Object.entries(FALLBACK_FX)) {
    const fx = fxRates[cur] ?? fallback;
    result[cur] = {
      goldPricePerGram:   parseFloat((gUSD * fx).toFixed(4)),
      silverPricePerGram: parseFloat((sUSD * fx).toFixed(4)),
      goldNisab:          parseFloat((gUSD * GOLD_NISAB_GRAMS   * fx).toFixed(2)),
      silverNisab:        parseFloat((sUSD * SILVER_NISAB_GRAMS * fx).toFixed(2)),
    };
  }
  return result;
}

// ── main ──────────────────────────────────────────────────────
async function main() {
  console.log("🚀 بدء تحديث الأسعار —", new Date().toISOString());

  const docRef   = db.collection("prices").doc("latest");
  const existing = await docRef.get();
  const lastGoldUSD   = existing.data()?.goldUsdPerOz   ?? 2350;
  const lastSilverUSD = existing.data()?.silverUsdPerOz ?? 27.5;

  const [metals, fxRates] = await Promise.all([
    fetchMetals(),
    fetchFxRates(),
  ]);

  const goldUSD   = metals?.goldUSD   ?? lastGoldUSD;
  const silverUSD = metals?.silverUSD ?? lastSilverUSD; // الآن حقيقي إن أمكن
  const nisab     = computeNisab(goldUSD, silverUSD, fxRates);

  await docRef.set({
    goldUsdPerOz:   goldUSD,
    silverUsdPerOz: silverUSD,
    nisab,
    source:    metals?.source ?? "cached",
    updatedAt: new Date().toISOString(),
  });

  console.log(`✅ تم الحفظ — ذهب: $${goldUSD}/oz | فضة: $${silverUSD}/oz | مصدر: ${metals?.source ?? "cached"}`);
  process.exit(0);
}

main().catch((err) => {
  console.error("❌ خطأ:", err);
  process.exit(1);
});