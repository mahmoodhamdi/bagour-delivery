# API Documentation - Bagour Delivery

تم إنشاء توثيق شامل لجميع الـ Endpoints في المشروع بثلاث طرق مختلفة.

## 📚 طرق الوصول للتوثيق

### 1. Swagger UI (تفاعلي)

الطريقة الأكثر شعبية للتوثيق التفاعلي مع إمكانية تجربة الـ API مباشرة.

**الرابط:**
```
http://localhost:5000/api-docs
```

**المميزات:**
- ✅ واجهة تفاعلية لتجربة الـ Endpoints
- ✅ إمكانية إرسال الطلبات مباشرة من المتصفح
- ✅ عرض جميع الـ Request/Response schemas
- ✅ دعم المصادقة (JWT Bearer Token)
- ✅ تجميع الـ Endpoints حسب الوحدات (Tags)

**كيفية الاستخدام:**
1. افتح المتصفح وادخل على الرابط أعلاه
2. اختر الـ Endpoint الذي تريد تجربته
3. اضغط على "Try it out"
4. أدخل البيانات المطلوبة
5. اضغط "Execute" لإرسال الطلب

### 2. ReDoc (توثيق احترافي)

واجهة توثيق نظيفة واحترافية، مثالية للقراءة والمراجعة.

**الرابط:**
```
http://localhost:5000/api-redoc
```

**المميزات:**
- ✅ تصميم نظيف واحترافي
- ✅ سهل القراءة والتصفح
- ✅ يدعم اللغة العربية (خط Cairo)
- ✅ عرض جميع التفاصيل بطريقة منظمة
- ✅ إمكانية البحث في التوثيق
- ✅ تحميل التوثيق كملف

**مثالي لـ:**
- المطورين الجدد للتعرف على الـ API
- مراجعة الـ API specs بشكل شامل
- عرض التوثيق للعملاء أو الفريق

### 3. Postman Collection (ملف JSON)

ملف JSON جاهز للاستيراد في Postman مع جميع الـ Endpoints.

**المسار:**
```
backend/postman_collection.json
```

**المميزات:**
- ✅ جميع الـ Endpoints معدة ومجهزة
- ✅ متغيرات Collection للـ tokens و IDs
- ✅ Scripts تلقائية لحفظ الـ tokens بعد تسجيل الدخول
- ✅ Bearer Token authentication مضبوطة تلقائياً
- ✅ تجميع الطلبات حسب الوحدات

**كيفية الاستخدام:**
1. افتح Postman
2. اضغط على زر "Import"
3. اختر الملف `postman_collection.json`
4. سيتم استيراد جميع الـ Endpoints تلقائياً

**نصائح Postman:**
- بعد تسجيل الدخول، يتم حفظ الـ access token تلقائياً
- استخدم متغيرات الـ Collection لحفظ الـ IDs (orderId, restaurantId, etc.)
- جميع الطلبات ترث الـ Bearer Token تلقائياً

## 🔄 تحديث التوثيق

### تحديث Swagger/ReDoc (تلقائي)

التوثيق يتم تحديثه تلقائياً من ملفات YAML في:
```
backend/src/docs/*.yaml
```

كل ملف YAML يحتوي على توثيق لوحدة معينة:
- `auth.yaml` - التسجيل وتسجيل الدخول
- `customer.yaml` - إدارة ملف العميل
- `restaurants.yaml` - المطاعم
- `menu.yaml` - القوائم والأصناف
- `orders.yaml` - الطلبات
- `driver.yaml` - السائقين
- `reviews.yaml` - التقييمات
- `coupons.yaml` - الكوبونات
- `payments.yaml` - المدفوعات
- `transactions.yaml` - المعاملات المالية
- `notifications.yaml` - الإشعارات
- `admin.yaml` - لوحة الإدارة
- `upload.yaml` - رفع الملفات

### إعادة توليد Postman Collection

لتحديث ملف Postman بعد تعديل التوثيق:

```bash
cd backend
npm run generate:postman
```

أو:

```bash
npm run docs:export
```

## 📥 تحميل التوثيق

### تحميل OpenAPI Specification (JSON)

```
http://localhost:5000/api-docs.json
```

يمكن استخدام هذا الملف في:
- تحويل إلى Postman
- تحويل إلى أي أداة توثيق أخرى
- توليد SDKs للغات مختلفة
- مشاركته مع الفرق الأخرى

## 🔐 المصادقة (Authentication)

جميع الـ Endpoints المحمية تحتاج إلى JWT token في الـ header:

```
Authorization: Bearer <access_token>
```

### الحصول على Token:

1. **تسجيل حساب جديد:**
   ```
   POST /api/v1/auth/customer/register
   POST /api/v1/auth/restaurant/register
   POST /api/v1/auth/driver/register
   ```

2. **تسجيل الدخول:**
   ```
   POST /api/v1/auth/customer/login
   POST /api/v1/auth/restaurant/login
   POST /api/v1/auth/driver/login
   POST /api/v1/auth/admin/login
   ```

3. **استخدام الـ Token في Swagger:**
   - اضغط على زر "Authorize" 🔓 في أعلى الصفحة
   - أدخل الـ token في خانة "Value"
   - اضغط "Authorize"
   - الآن جميع الطلبات ستستخدم الـ token تلقائياً

## 📝 بنية الـ Response

### Success Response:
```json
{
  "success": true,
  "message": "رسالة النجاح بالعربي",
  "data": { ... }
}
```

### Error Response:
```json
{
  "success": false,
  "message": "رسالة الخطأ بالعربي",
  "error": {
    "code": "ERROR_CODE",
    "details": { ... }
  }
}
```

### Paginated Response:
```json
{
  "success": true,
  "message": "تم جلب البيانات بنجاح",
  "data": [...],
  "pagination": {
    "total": 100,
    "page": 1,
    "limit": 10,
    "pages": 10
  }
}
```

## 🏷️ الوحدات (Tags/Modules)

الـ API مقسمة إلى الوحدات التالية:

| الوحدة | الوصف | عدد الـ Endpoints |
|--------|-------|------------------|
| **Auth** | التسجيل وتسجيل الدخول | 12+ |
| **Customer** | إدارة ملف العميل والعناوين | 8+ |
| **Restaurants** | تصفح المطاعم والبحث | 10+ |
| **Restaurant Dashboard** | إدارة المطعم من المالك | 15+ |
| **Menu** | القوائم والأصناف | 12+ |
| **Orders** | إدارة الطلبات (جميع الأدوار) | 20+ |
| **Driver** | السائقين والتوصيلات | 10+ |
| **Reviews** | التقييمات والتعليقات | 8+ |
| **Coupons** | الكوبونات والخصومات | 6+ |
| **Payments** | معالجة المدفوعات | 5+ |
| **Transactions** | المعاملات المالية | 8+ |
| **Notifications** | الإشعارات | 6+ |
| **Admin** | لوحة إدارة المنصة | 25+ |
| **Upload** | رفع الصور والملفات | 3+ |

**الإجمالي:** أكثر من **150 Endpoint** موثق بالكامل ✨

## 🌐 الخوادم (Servers)

### Development:
```
http://localhost:5000/api/v1
```

### Production:
```
https://api.bagour-delivery.com/api/v1
```

## ⚡ Rate Limiting

- **غير مصادق:** 100 طلب كل 15 دقيقة
- **مصادق:** 500 طلب كل 15 دقيقة

## 🛠️ أدوات إضافية

### تحويل OpenAPI إلى أدوات أخرى:

```bash
# تحويل إلى Postman
npm run generate:postman

# الملف الناتج
backend/postman_collection.json
```

### استخدام مع أدوات أخرى:

الملف `api-docs.json` متوافق مع:
- [Insomnia](https://insomnia.rest/)
- [Paw](https://paw.cloud/)
- [HTTPie](https://httpie.io/)
- [OpenAPI Generator](https://openapi-generator.tech/)

## 📞 الدعم

للأسئلة والمشاكل:
- Email: support@bagour-delivery.com
- الـ Issues على GitHub

---

**ملاحظة:** تأكد من تشغيل الـ backend server قبل الوصول للتوثيق:
```bash
cd backend
npm run dev
```

ثم افتح أحد روابط التوثيق المذكورة أعلاه. 🚀
