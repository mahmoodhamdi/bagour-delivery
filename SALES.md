# Bagour Delivery — منصة توصيل طعام كاملة

## للمستثمرين والـ operators اللي عاوزين يلانشوا منصة delivery في مدينة أو منطقة

> منصة 6 مكونات: backend API، 3 تطبيقات Flutter (عميل، سائق، مطعم)،
> dashboard مطعم، dashboard مدير. للسوق المصري والعربي. تصميم RTL،
> دفع Paymob، خرائط Google، إشعارات FCM، real-time عبر Socket.io.

---

## ليه Bagour؟

سوق التوصيل في مصر:
- Talabat / Otlob / Elmenus بيغطوا القاهرة الكبرى والإسكندرية
- المدن الصغيرة والمحافظات: مفيش لاعب محلي قوي
- المطاعم بتدفع 25-35% commission للمنصات الكبيرة
- التطبيقات الكبيرة بتاخد بيانات العملاء وتستخدمها للترويج لمطاعم منافسة

**Bagour** بيتيح لك إنك تطلق منصة **خاصة بمدينتك**:
- Commission أقل (15-20% المعتاد)
- بيانات العملاء عند المنصة بتاعتك
- branding كامل (اسم، شعار، ألوان)
- ربط مباشر بمطاعم المنطقة

---

## مين العميل المثالي؟

### للمستثمر اللي عاوز يدخل السوق
- شركة ناشئة في مدينة (الزقازيق، طنطا، المنصورة، أسيوط، إلخ.)
- مستثمر بـ$30K–$100K حابب يبدأ delivery business
- صاحب مطعم/سلسلة عاوز يبني تطبيق خاص بمحلاته
- بلدية أو cooperative

### للسلسلة
- مطعم بـ5+ فروع عاوز delivery كاملة بدون منصة طرف ثالث
- معالم محلية بتاخد طلبات أونلاين بـ WhatsApp النهارده

---

## ما يحتويه النظام

### 1. Backend API (Node + Express + MongoDB)
- 120+ endpoints
- Authentication بـ JWT + Firebase Auth
- Socket.io real-time للطلبات والتوصيل
- Cloudinary للصور
- Paymob للدفع الإلكتروني
- Rate limiting + helmet + CSRF + mongo-sanitize
- 4 user roles (customer, restaurant, driver, admin)

### 2. Customer App (Flutter)
- iOS + Android (نفس الـ codebase)
- تصفح المطاعم + قوائم الأكل + filters
- سلة وطلب + tracking للسائق على الخريطة
- Loyalty + coupons + reviews
- Push notifications

### 3. Driver App (Flutter)
- iOS + Android
- استلام طلبات بـ acceptance window
- توجيه على Google Maps
- تحديث status (picked-up, on-the-way, delivered)
- earnings + payout history

### 4. Restaurant App (Flutter)
- تطبيق موبايل للمطاعم اللي ما عندهاش web access
- إشعار بطلبات جديدة (push + sound)
- accept/reject + prep time
- menu management بسيط

### 5. Restaurant Dashboard (Web — Next.js 16)
- لوحة كاملة لإدارة المطعم
- menu management مع صور
- orders queue real-time
- analytics + earnings + payouts

### 6. Admin Dashboard (Web — Next.js 16)
- إدارة المنصة بالكامل
- approve/reject restaurants and drivers
- zones + delivery fees
- coupons + promotions
- payout management
- platform analytics

---

## بيتركب في كام يوم؟

| المرحلة | المدة |
|--------|------|
| Backend + DB + dashboards على VPS | يوم 1 |
| Flutter apps build + Google Play / App Store internal track | يوم 2-3 |
| Customization (logo, colors, zones, fees) | يوم 3 |
| Onboard first 5 restaurants | يوم 4-5 |
| Onboard first 10 drivers | يوم 5-6 |
| Training (مدير، مساعدين، حسابات) | يوم 6 |
| Soft launch (مدينة واحدة، 10 مطاعم) | يوم 7 |

**أسبوع من البداية للـ soft launch**.

---

## الباقات

### Starter — تشغيل في مدينة واحدة
**$8,000 / مرة واحدة + $400/شهر دعم**

- النظام كامل (6 apps)
- تركيب على VPS العميل
- iOS + Android build + Play Store / App Store account setup
- branding بسيط (logo + name + 2 colors)
- 4 hours training (admin + ops)
- 3 شهور دعم
- 6 شهور warranty

### Pro — الأكثر طلباً
**$15,000 / مرة واحدة + $1,000/شهر دعم**

كل اللي في Starter، زائد:
- استضافة جاهزة سنة كاملة
- Paymob integration + verification
- Firebase project setup + FCM
- 2 مدن (zones config)
- 12 hour training
- backup + monitoring + uptime alerts
- 6 شهور دعم priority

### Enterprise — للسلاسل والمنصات الكبيرة
**$30,000+ / مرة واحدة + $2,500/شهر دعم**

- multi-city + multi-tenant
- white-label كامل
- custom features (specific to industry)
- 24/7 on-call
- 12 شهر دعم
- SLA 99.5% uptime
- ربط مع insurance / accounting

---

## الـ economics اللي بنبني عليها

| البند | السعر النموذجي |
|------|----------------|
| Commission من كل order | 15-20% |
| Order متوسط | 100-150 ج.م |
| Commission متوسط | 15-30 ج.م لكل order |
| Orders في اليوم (أول 6 شهور) | 50-200 |
| Revenue شهري متوقع (متوسط) | 30,000-180,000 ج.م |
| تكاليف infra | ~$50/شهر |
| تكاليف SMS/OTP | ~5,000 ج.م/شهر |
| Break-even | شهر 2-3 |

**Disclaimer**: الأرقام تقديرية للمنطقة المصرية. الأداء الفعلي بيختلف حسب
المدينة، الـ marketing budget، وكثافة المطاعم.

---

## للتواصل

**Mahmoud Hamdy — MWM Software Solutions**
📧 mwm.softwars.solutions@gmail.com

Demo 60 دقيقة + Q&A — بنوريك الـ 6 apps شغالين، الـ admin dashboard،
الـ economics calculator.
