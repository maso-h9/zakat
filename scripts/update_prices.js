// ================================================================
// update_prices.js — GitHub Actions (مجاني 100%)
// ترتيب المزودين: metals.live أولاً → GOLDAPI_KEY → METALS_API_KEY → Firestore cache
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

// ── HTTP helper ────────────────────────────────────────────────
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
    req.on("timeout", () => { req.destroy(); reject(new Error("timeout")); });
  });
}

// ── جلب سعر الذهب بالترتيب الصحيح ────────────────────────────
async function fetchGoldUSD() {

  // ① metals.live — مجاني، بلا مفتاح، الأول دائماً
  try {
    const { status, body } = await fetchJSON("https://metals.live/api/v1/spot/gold");
    const price = Array.isArray(body) ? body[0]?.gold : body?.gold;
    if (status === 200 && price) {
      console.log("✅ [1] metals.live:", price);
      return { priceUSD: price, source: "metals.live" };
    }
    console.warn("⚠️ [1] metals.live: بيانات غير صالحة");
  } catch (e) { console.warn("⚠️ [1] metals.live فشل:", e.message); }

  // ② GoldAPI — يحتاج GOLDAPI_KEY في GitHub Secrets
  if (process.env.GOLDAPI_KEY) {
    try {
      const { status, body } = await fetchJSON(
        "https://www.goldapi.io/api/XAU/USD",
        { "x-access-token": process.env.GOLDAPI_KEY }
      );
      if (status === 200 && body?.price) {
        console.log("✅ [2] GoldAPI:", body.price);
        return { priceUSD: body.price, source: "goldapi" };
      }
      console.warn("⚠️ [2] GoldAPI: status", status, body?.error ?? "");
    } catch (e) { console.warn("⚠️ [2] GoldAPI فشل:", e.message); }
  } else {
    console.log("ℹ️ [2] GOLDAPI_KEY غير موجود — تخطّي");
  }

  // ③ Metals-API — يحتاج METALS_API_KEY في GitHub Secrets
  if (process.env.METALS_API_KEY) {
    try {
      const url = `https://metals-api.com/api/latest?access_key=${process.env.METALS_API_KEY}&base=USD&symbols=XAU`;
      const { status, body } = await fetchJSON(url);
      const raw   = body?.rates?.XAU ?? body?.rates?.USDXAU;
      const price = raw ? (raw < 1 ? 1 / raw : raw) : null;
      if (status === 200 && price && price > 100) {
        console.log("✅ [3] Metals-API:", price);
        return { priceUSD: price, source: "metals-api" };
      }
      console.warn("⚠️ [3] Metals-API: بيانات غير صالحة");
    } catch (e) { console.warn("⚠️ [3] Metals-API فشل:", e.message); }
  } else {
    console.log("ℹ️ [3] METALS_API_KEY غير موجود — تخطّي");
  }
     
const silverUSD = silverResp.body?.price ?? lastSilverUSD;
  console.warn("❌ كل المزودين فشلوا — سيُستخدم آخر سعر Firestore");
  return null;


  // في fetchGoldUSD — أضف هذا لو عندك GOLDAPI_KEY
       const silverResp = await fetchJSON(
             "https://www.goldapi.io/api/XAG/USD",
           { "x-access-token": process.env.GOLDAPI_KEY }
              );
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
  console.warn("⚠️ FX: استخدام القيم الاحتياطية");
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

// ── main ───────────────────────────────────────────────────────
async function main() {
  console.log("🚀 بدء تحديث الأسعار —", new Date().toISOString());

  const docRef   = db.collection("prices").doc("latest");
  const existing = await docRef.get();
  const lastGoldUSD   = existing.data()?.goldUsdPerOz   ?? 2350;
  const lastSilverUSD = existing.data()?.silverUsdPerOz ?? 27.5;

  const [goldResult, fxRates] = await Promise.all([
    fetchGoldUSD(),
    fetchFxRates(),
  ]);

  const goldUSD   = goldResult?.priceUSD ?? lastGoldUSD;
  const silverUSD = lastSilverUSD;
  const nisab     = computeNisab(goldUSD, silverUSD, fxRates);

  await docRef.set({
    goldUsdPerOz:   goldUSD,
    silverUsdPerOz: silverUSD,
    nisab,
    source:    goldResult?.source ?? "cached",
    updatedAt: new Date().toISOString(),
  });

  console.log(`✅ تم الحفظ. الذهب: $${goldUSD}/oz — المصدر: ${goldResult?.source ?? "cached"}`);
  process.exit(0);
}

main().catch((err) => {
  console.error("❌ خطأ:", err);
  process.exit(1);
});