# ERRORS.md

> 30+ daqiqalik bug, noma'lum-sabab xato, yoki "shu yana takrorlanmasin" deyiladigan hodisalar.
> Eng yangi yuqorida.

---

## Format

```markdown
## YYYY-MM-DD — <qisqa nomlash>
**Belgi (simptom):** nima ko'rinadi
**Sabab:** asl manba — nima sabab bo'ldi
**Yechim:** nima qilindi
**Aloqador fayllar:** ...
**Profilaktika:** kelajakda yana yuz bermasligi uchun nima qilish kerak
```

## Misol

```markdown
## 2026-06-15 — Yandex MapKit init: `MissingPluginException`
**Belgi:** App ochilganda `YandexMap` widget render bo'lmaydi, console:
  `MissingPluginException(No implementation found for method ru.yandex.runtime.api)`
**Sabab:** AndroidManifest.xml da `<meta-data android:name="ru.yandex.runtime.api.key" ...` qo'shilmagan edi.
**Yechim:** `android/app/src/main/AndroidManifest.xml` ga meta-data qo'shildi (build.gradle BuildConfig.YANDEX_KEY orqali).
**Aloqador fayllar:** AndroidManifest.xml, app/build.gradle, lib/core/config/app_config.dart
**Profilaktika:** docs/ARCHITECTURE.md §12 ga Android setup checklist qo'shildi.
```

---

## Yozuvlar

## 2026-06-04 — Windows: `cloud_functions` plugin "Unable to establish connection on channel"
**Belgi:** Windows app login sahifasida kod kiritilganda yoki silent_login chaqirilganda:
  `Unable to establish connection on channel: "dev.flutter.pigeon.cloud_functions_platform_interface.CloudFunctionsHostApi.call"`
**Sabab:** `cloud_functions` Flutter plugin Windows desktopni qo'llab-quvvatlamaydi (rasmiy supported platforms: Android, iOS, macOS, Web). Pigeon channel mavjud emas → MethodChannel chaqirig'i muvaffaqiyatsiz.
**Yechim:** `cloud_functions` paketi olib tashlandi. `lib/data/firebase/http_callable.dart` — pure-Dart `http` paketi orqali Cloud Function callable'larga REST chaqirig'i. URL format: `https://<region>-<project>.cloudfunctions.net/<function>`. Request: `{"data": {...}}`, response: `{"result": {...}}`. Hamma platformada (Windows + Android + iOS + Web) ishlaydi. `AuthRepository` shu wrapper'ni ishlatadi.
**Aloqador fayllar:** `pubspec.yaml`, `lib/data/firebase/http_callable.dart`, `lib/features/auth/data/auth_repository.dart`.
**Profilaktika:** Firebase plugin'larini qo'shishdan oldin Windows desktop support'ni tekshirish (pub.dev'da "supported platforms"). Cloud Functions chaqirig'i uchun HTTP wrapper standart pattern bo'lib qoldi — yangi callable'lar shu yo'l bilan qo'shiladi.

## 2026-06-04 — Windows build: `Cannot open include file: 'atlstr.h'`
**Belgi:** `flutter build windows` xato:
  `flutter_secure_storage_windows_plugin.cpp(6,10): error C1083: Cannot open include file: 'atlstr.h'`
**Sabab:** `flutter_secure_storage` Windows implementatsiyasi Microsoft ATL (Active Template Library) ga bog'liq. ATL faqat Visual Studio "C++ ATL for v143 build tools" workload o'rnatilganda mavjud (default emas).
**Yechim:** `flutter_secure_storage` paketini olib tashlab, `shared_preferences` ga ko'chirildi. `lib/core/utils/secure_storage.dart` interface saqlandi (impl o'zgardi) — barcha calling code o'zgarmaydi. Pass-key endi plain text saqlanadi (lekin himoya server tomonida — Firebase custom token + rate-limit). Tafsilot: `docs/AUTH_AND_ROLES.md` §7.
**Aloqador fayllar:** `pubspec.yaml`, `lib/core/utils/secure_storage.dart`, `docs/AUTH_AND_ROLES.md`, `docs/ARCHITECTURE.md`.
**Profilaktika:** Windows'da native code talab qiluvchi paketlar (ATL, Win32 API, COM) qo'shishdan oldin dev-environment'ni tekshirish. Ichki business app uchun pure-Dart paketlar afzal.

## 2026-06-04 — yandex_mapkit Windows desktopni qo'llab-quvvatlamaydi
**Belgi:** `yandex_mapkit` paketi pubspec'da, lekin Windows uchun native code yo'q. Build muvaffaqiyatli, lekin xarita ko'rinmaydi.
**Sabab:** Yandex MapKit Flutter plugin faqat Android va iOS native SDK'larga bog'langan. Windows/Web/Linux uchun official implementatsiya yo'q.
**Yechim:** `flutter_map` + Yandex tile server URL'i orqali pure-Dart yo'l tanlandi. URL: `https://core-renderer-tiles.maps.yandex.net/tiles?l=map&x={x}&y={y}&z={z}&scale=1&lang=ru_RU`. Windows + Android + iOS — bir xil ko'rinish va ma'lumotlar.
**Aloqador fayllar:** `pubspec.yaml`, `lib/features/map/presentation/map_home_page.dart`, `docs/ARCHITECTURE.md` §7.
**Profilaktika:** Map provider tanlashda Flutter package'ning platform support ro'yxatini tekshirish (pub.dev sahifasidagi "Supported platforms" qatori).

## 2026-06-04 — ESLint 9: "couldn't find an eslint.config.(js|mjs|cjs) file"
**Belgi:** `firebase deploy --only functions` predeploy bosqichida `npm run lint` xato beradi:
  `ESLint couldn't find an eslint.config.(js|mjs|cjs) file. From ESLint v9.0.0, the default configuration file is now eslint.config.js.`
**Sabab:** Skelet `functions/.eslintrc.json` (legacy) bilan tuzilgan, lekin `npm install` ESLint ^9 ni o'rnatadi. ESLint 9 faqat flat config (`eslint.config.js`) qabul qiladi.
**Yechim:** `.eslintrc.json` o'chirildi, `functions/eslint.config.js` (flat config) yaratildi: `@typescript-eslint/parser` + `@typescript-eslint/eslint-plugin`. Yana `package.json` da `eslint --ext .ts src` → `eslint src` (chunki `--ext` flag ESLint 9 da yo'q).
**Aloqador fayllar:** `functions/eslint.config.js`, `functions/package.json` (scripts.lint).
**Profilaktika:** Skelet generatorlar ESLint 8 davridan qolgan — yangi `functions/` yaratilsa avval ESLint versiyasini tekshirish.
