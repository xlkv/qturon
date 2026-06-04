# 04_well_detail.md — Kolodets detallari

> Marshrut: `/wells/:wellId` · Role: hammada (paid:true bo'lsa) · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Bitta kolodets haqida to'liq ma'lumot. Read-only (user) yoki edit imkoniyatli (admin, super_admin).

Edit sahifasi alohida — [05_well_create_edit.md](05_well_create_edit.md). Bu sahifa **detail-view** rejimida.

## 2. UI

### AppBar
- Sarlavha: `Kolodets B12` (kod).
- Trailing:
  - **Edit** icon (admin, super_admin uchun) → `/wells/:id/edit`
  - **Menu** (3 nuqta):
    - Xaritada ko'rsatish (`/map?focus=:id`)
    - O'chirish (admin, super_admin) — confirm dialog bilan

### Body
- Yuqorida foto carousel (agar `photoUrls` bo'sh emas).
  - Bo'sh bo'lsa placeholder (kichik "Rasm yo'q" ikoni).
- Quyida `ListTile` lar bo'yicha ma'lumotlar:
  - **Kod**: `B12`
  - **Status**: chip (planned/working/done — rangli)
  - **Joylashuv**: `41.31, 69.27` (tap → xaritada ochish)
  - **Usta**: master ismi (yoki "Belgilanmagan")
  - **O'rnatilgan sana**: `12.04.2026` yoki "Hali yo'q"
  - **Yaratilgan**: createdAt + createdBy ism (kichik shrift)
  - **Oxirgi o'zgarish**: updatedAt + updatedBy
  - **Izoh**: notes (uzun matn, o'qiluvchan)
  - **To'langan** ✓/✗ — **faqat super_admin uchun**

### Bo'sh hollar
- Master null → "Belgilanmagan" (kulrang).
- installedAt null → "Hali o'rnatilmagan" (kulrang).
- notes null/bo'sh → matn ko'rsatilmaydi (yashirin).

## 3. State

```dart
@riverpod
Stream<Well?> well(WellRef ref, String cityId, String wellId);

@riverpod
Future<Master?> masterById(MasterByIdRef ref, String cityId, String? masterId);
```

## 4. Logika

### Yuklanish
- `wellStreamProvider(cityId, wellId).when(...)` bilan ko'rsatamiz.
- `well` null bo'lsa → "Topilmadi" (perms yo'q yoki o'chirilgan).

### Foto
- `photoUrls` element'lar — Storage path (`wells/.../photo1.jpg`). Birinchi marta ko'rganda `FirebaseStorage.refFromURL(...)` orqali signed URL olish; `cached_network_image` cache qiladi.

### O'chirish
```
Tugma → ConfirmDialog ("Kolodets B12 ni o'chirasizmi?")
→ tasdiq → WellRepository.delete(cityId, wellId)
→ Storage: photoUrls ham o'chirish (Cloud Function trigger yoki client)
→ Logger.info('well.delete', {wellId, cityId})
→ context.pop() → snackbar "O'chirildi"
```

### Xaritada ko'rsatish
```
context.go('/map', extra: {'focusWellId': wellId})
```
MapHomePage `extra` ni qabul qilib kameranı joylashuvga animatsiyalaydi.

## 5. Firestore

- O'qish: `cities/{cityId}/wells/{wellId}` (single doc stream).
- Yozish: yo'q (edit alohida sahifa).
- O'chirish: doc delete + Storage photo cleanup.

## 6. Permission

| Element | super_admin | admin | user |
|---|---|---|---|
| Sahifani ko'rish | ✓ | ✓ (paid:true) | ✓ (paid:true) |
| Edit tugmasi | ✓ | ✓ | ✗ |
| O'chirish | ✓ | ✓ | ✗ |
| "To'langan" satri ko'rinishi | ✓ | ✗ | ✗ |

## 7. Edge case

| Holat | Harakat |
|---|---|
| wellId mavjud emas / o'chirilgan | "Topilmadi" + tugma "Xaritaga qaytish" |
| photoUrls signed URL xato | Placeholder ikoni + console warn |
| User ko'rishga ruxsati yo'q (paid:false va admin) | Router rendirini `/map` ga (snackbar "Ko'rish mumkin emas") |

## 8. Aloqador

- [05_well_create_edit.md](05_well_create_edit.md) — edit
- [../FIREBASE.md §2](../FIREBASE.md) — well schema + Storage paths
- [../AUTH_AND_ROLES.md §3.1](../AUTH_AND_ROLES.md) — permissions

## 9. Build prompt

```
docs/README.md, docs/pages/04_well_detail.md, docs/AUTH_AND_ROLES.md §3 ni o'qing.

Vazifa: WellDetailPage qurish.

Joylashuv:
- lib/features/wells/presentation/well_detail_page.dart
- lib/features/wells/presentation/widgets/photo_carousel.dart (reusable, pipes ham ishlatadi)
- lib/features/wells/presentation/widgets/well_info_list.dart
- lib/features/wells/application/well_provider.dart
- lib/features/wells/application/master_by_id_provider.dart
- lib/features/wells/data/well_repository.dart (agar yo'q bo'lsa)
- lib/features/masters/data/master_repository.dart (agar yo'q bo'lsa)

Talab:
1. wellStreamProvider — single doc snapshot.
2. masterByIdProvider — agar masterId null bo'lsa null qaytaradi.
3. PhotoCarousel — page indicator, tap → fullscreen viewer (interactive_viewer).
4. AppBar Edit tugmasi: permissions.canEditWell bo'lsa ko'rsatiladi.
5. Menu (3 nuqta): "Xaritada ko'rsatish", "O'chirish" (perms bilan).
6. "To'langan" satri: permissions.canSeePaidField bo'lganda chiqaring.
7. Status chip — rang xaritasi: planned=kulrang, working=ko'k, done=yashil.
8. installedAt formatlash: dd.MM.yyyy (intl paketi bilan).
9. O'chirish: ConfirmDialog → WellRepository.delete → photoUrls Storage'dan o'chirish → context.pop().

Code rules: Riverpod codegen, AppSpacing, logger.info per action.

Tugatgach:
- Status: DONE pages/04_well_detail.md + INDEX.md
- logs/CHANGELOG.md
```

## Status

TODO
