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

## 2026-06-04 — ESLint 9: "couldn't find an eslint.config.(js|mjs|cjs) file"
**Belgi:** `firebase deploy --only functions` predeploy bosqichida `npm run lint` xato beradi:
  `ESLint couldn't find an eslint.config.(js|mjs|cjs) file. From ESLint v9.0.0, the default configuration file is now eslint.config.js.`
**Sabab:** Skelet `functions/.eslintrc.json` (legacy) bilan tuzilgan, lekin `npm install` ESLint ^9 ni o'rnatadi. ESLint 9 faqat flat config (`eslint.config.js`) qabul qiladi.
**Yechim:** `.eslintrc.json` o'chirildi, `functions/eslint.config.js` (flat config) yaratildi: `@typescript-eslint/parser` + `@typescript-eslint/eslint-plugin`. Yana `package.json` da `eslint --ext .ts src` → `eslint src` (chunki `--ext` flag ESLint 9 da yo'q).
**Aloqador fayllar:** `functions/eslint.config.js`, `functions/package.json` (scripts.lint).
**Profilaktika:** Skelet generatorlar ESLint 8 davridan qolgan — yangi `functions/` yaratilsa avval ESLint versiyasini tekshirish.
