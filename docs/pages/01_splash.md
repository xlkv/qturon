# 01_splash.md — Splash sahifa

> Marshrut: `/splash` · Role: hammada · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Ilova ochilganda eng birinchi ko'rinadi. 3 ta vazifa:
1. Firebase init (agar `main.dart` da bo'lmasa) va resurslar tayyor bo'lishini kutish.
2. `flutter_secure_storage`'dan saqlangan pass-key'ni o'qib, **silent login** qilishga urinish.
3. Natijaga qarab `/login` yoki `/map` ga yo'naltirish.

## 2. UI

- Markazda logo (vector — yo'qligi sababli faqat **TS** harflari, brend rangda).
- Ostida `CircularProgressIndicator` (kichik).
- Foydalanuvchi hech narsaga bosmaydi — passiv ekran.
- Light/Dark — `Theme.of(context).colorScheme` bo'yicha.

## 3. State (Riverpod)

`splashControllerProvider` — `AsyncNotifier<SplashResult>`:
```dart
enum SplashResult { needLogin, needSuperAdminSetup, ready }
```

- `needLogin` → secure storage'da pass-key yo'q.
- `needSuperAdminSetup` → `users` collection bo'sh (deyarli yuz bermaydi normal vaziyatda; lekin birinchi run uchun foydali).
- `ready` → silent login muvaffaqiyatli.

## 4. Logika

```
1. await Firebase.initializeApp() — agar main.dart da bo'lmasa
2. final passKey = await SecureStorage.read('auth.passKey')
3. if (passKey == null) → router.go('/login')
4. else:
     try {
       result = await CloudFunction.validatePassKey(passKey)
       await FirebaseAuth.signInWithCustomToken(result.customToken)
       router.go('/map')
     } catch (e) {
       await SecureStorage.delete('auth.passKey')
       router.go('/login')
     }
```

## 5. Firestore o'qish/yozish

Hech narsa. Faqat `validatePassKey` Cloud Function chaqirig'i.

## 6. Permission

Hammaga.

## 7. Edge case

| Holat | Harakat |
|---|---|
| Internet yo'q | "Internet bilan ulanish kerak" toast → `/login` |
| Pass-key noto'g'ri (user o'chirilgan/active=false) | Storage'dan tozala → `/login` (xabarsiz) |
| Firebase init xato | "Tizim ishga tushmadi. Ilovani qayta oching." — single button "Qayta urin" |

## 8. Navigation

- `pushReplacement` ishlatadi (history'da `/splash` qolmaydi).

## 9. Aloqador hujjatlar

- [../AUTH_AND_ROLES.md §1.1](../AUTH_AND_ROLES.md) — login flow
- [../FIREBASE.md §6](../FIREBASE.md) — `validatePassKey`

## 10. Build prompt (AI uchun)

```
docs/README.md ni o'qib chiqing. Keyin docs/pages/01_splash.md ni o'qing.

Vazifa: SplashPage yaratish.

Joylashuv: lib/features/auth/presentation/splash_page.dart
Provider: lib/features/auth/application/splash_controller.dart

Talab:
1. ConsumerStatefulWidget yoki ConsumerWidget bilan splashControllerProvider'ni watch qilsin.
2. SplashResult.ready → router.go('/map'), needLogin → router.go('/login').
3. Logo + CircularProgressIndicator.
4. flutter_secure_storage va Cloud Function chaqiruvi controllerda bo'lsin.
5. Xato chiqsa secure storage'ni tozalash.
6. Code rules: Riverpod codegen, const constructor, no print.

Tugatgandan keyin:
- docs/pages/01_splash.md ni Status: DONE qiling.
- docs/pages/INDEX.md jadvalida statusni yangilang.
- docs/logs/CHANGELOG.md ga 1 qator qo'shing.
```

## Status

DONE (2026-06-04) — `lib/features/auth/presentation/splash_page.dart` + `splash_controller.dart`. Silent login real Cloud Function'ni chaqiradi; functions deploy qilinmagan paytda `needLogin` ga qaytadi.
