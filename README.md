# ShopX — Firebase Auth + Firestore + Offline Cache

## خطوات الإعداد (مطلوبة قبل التشغيل)

### 1. إنشاء مشروع Firebase
- اذهب إلى [console.firebase.google.com](https://console.firebase.google.com)
- أنشئ مشروعاً جديداً → اسمه مثلاً `shopx`

### 2. تفعيل Email/Password Authentication
```
Firebase Console → Authentication → Sign-in method → Email/Password → Enable
```
> ⚠️ Common Mistake #2: نسيان تفعيل Email/Password في Console

### 3. إنشاء Firestore Database
```
Firebase Console → Firestore Database → Create database → Start in test mode
```

### 4. ربط التطبيق بـ Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
> ⚠️ Common Mistake #3: تخطي `flutterfire configure` — يجب تشغيله ليتم توليد `firebase_options.dart` بالقيم الحقيقية

### 5. تشغيل التطبيق
```bash
flutter pub get
flutter run
```

---

## التمارين المطبّقة

### Exercise 1 — Firebase Authentication
- `AuthService`: signUp / signIn / signOut
- ✅ `WidgetsFlutterBinding.ensureInitialized()` قبل `Firebase.initializeApp()` (Mistake #1 fixed)
- ✅ `StreamBuilder` في `main.dart` يعرض شاشة مختلفة حسب حالة المستخدم
- ✅ رسائل خطأ ودية — لا تظهر Firebase codes الخام للمستخدم (Mistake #7 fixed)
- ✅ فحص `mounted` بعد كل `await` (Mistake #6 fixed)

### Exercise 2 — Firestore Products Collection
- `FirestoreService.productsStream()` يستخدم `snapshots()` للتحديث اللحظي
- `Product.fromDoc()` + `toFirestoreMap()` — نمط fromDoc/toMap
- المجموعة `products` تُغذَّى تلقائياً من DummyJSON API عند أول تشغيل

### Exercise 3 — Personal Favorites per User
- كل مستخدم له مساره الخاص: `users/{userId}/favorites`
- `set()` للإضافة، `delete()` للحذف، `snapshots()` للمزامنة الفورية
- المفضلة تُحمَّل تلقائياً عند تسجيل الدخول
- المستخدم الضيف: بيانات محلية في `favorites.json`

---

## Firestore Security Rules (مهم للإنتاج)
في Firebase Console → Firestore → Rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{doc} {
      allow read: if true;
      allow write: if false; // only admin seeds
    }
    match /users/{userId}/favorites/{fav} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
> ⚠️ Common Mistake #4: استخدام `allow read, write: if true` في الإنتاج خطر جداً!
