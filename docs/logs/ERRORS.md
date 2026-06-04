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

<!-- Hozircha bo'sh — birinchi xato yozilganda shu yerga keladi -->
