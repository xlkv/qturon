# 07_pipe_create_edit.md — Turba yaratish/o'zgartirish

> Marshrut: `/pipes/new`, `/pipes/:pipeId/edit` · Role: super_admin, admin · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Yangi turba qo'shish yoki tahrirlash. Polyline'ni xaritadan chizib kelganidan keyin ushbu sahifa to'ldiriladi.

## 2. UI

### AppBar
- Sarlavha: `Yangi turba` yoki `Turba P5`.
- Trailing: **Saqlash**.

### Body
1. **Polyline preview** + "Qayta chizish" tugmasi (faza 2 — MVP'da qaytarib chizish faqat bekor qilish + xaritaga qaytish).
2. **Kod** — read-only auto-generated `P5`.
3. **Diametri (mm)** — `TextFormField` numeric (50, 75, 110, 125, ... dropdown bilan ham bo'lishi mumkin lekin MVP'da text + suggestion chip lar).
4. **Uzunlik (m)** — numeric `TextFormField` + helper "Geo-uzunlik: 38.2 m" (tap qilsa to'ldiradi).
5. **Status** — segmented chip.
6. **Usta** — DropdownButton.
7. **O'rnatilgan sana** — DatePicker.
8. **Izoh** — multiline.
9. **Rasmlar** — grid (reusable PhotoGridEditor).
10. **To'langan** (super_admin) — Switch.

### Pastki tugma
- "Saqlash" + "Bekor qilish".

## 3. State

```dart
@riverpod
class PipeFormController extends _$PipeFormController {
  @override
  PipeFormState build({
    required String cityId,
    String? pipeId,
    List<GeoPoint>? initialPoints,   // /pipes/new dan keladi (xaritada chizilgan)
  }) { ... }

  void updateDiameter(int mm);
  void updateLength(double m);
  void useGeoLength();
  // qolgan setter'lar wells'dagi kabi
  Future<void> submit();
}
```

`PipeFormState` (freezed):
- cityId, pipeId, code?, points, diameterMm, lengthM, status, paid, installedAt?, masterId?, notes?, photos, isSubmitting, error, savedOk

## 4. Logika

Wells'dagi 05'ga juda yaqin. Farqlar:

- `points` minimum 2 ta nuqta — yangi yaratishda `initialPoints` `/pipes/new` query'dan keladi (`?points=lat,lng;lat,lng;...`).
- `code` — auto `P${nextCounter}`.
- `lengthM` — user kiritadi; "Geo-uzunlik" suggestion (Haversine) — tap'da to'ldiradi.

### Submit
1. Validate (points >= 2, diameter > 0, length > 0, status tanlangan, photos <= 5).
2. nextCode (transaction).
3. Photos upload (parallel).
4. Firestore set.
5. Logger event.
6. pop().

## 5. Firestore

- O'qish (edit): `cities/{cityId}/pipes/{pipeId}`.
- Yozish: doc set + counter transaction.
- Storage: `pipes/{cityId}/{pipeId}/{photoId}.jpg`.

## 6. Permission

| Element | super_admin | admin | user |
|---|---|---|---|
| Sahifa | ✓ | ✓ | ✗ |
| Paid switch | ✓ | yashirin | — |

## 7. Edge case

[05_well_create_edit.md §7](05_well_create_edit.md) bilan bir xil + qo'shimcha:

| Holat | Harakat |
|---|---|
| points.length < 2 | "Kamida 2 nuqta kerak" — pastdagi tugma disabled |
| points juda ko'p (>50) | OK, lekin warning: "Juda ko'p nuqta. Optimallashtirishni o'ylab ko'ring" |
| Diametri/uzunligi raqamsiz | Validatsiya xato |

## 8. Aloqador

- [06_pipe_detail.md](06_pipe_detail.md)
- [03_map_home.md](03_map_home.md) — chizish bu yerdan keladi
- [../FIREBASE.md §2](../FIREBASE.md) — schema
- [05_well_create_edit.md](05_well_create_edit.md) — sister page

## 9. Build prompt

```
docs/README.md, docs/pages/07_pipe_create_edit.md,
docs/pages/05_well_create_edit.md (reusable widget'lar uchun),
docs/FIREBASE.md §2 ni o'qing.

Vazifa: PipeCreateEditPage + PipeFormController.

Joylashuv:
- lib/features/pipes/presentation/pipe_create_edit_page.dart
- lib/features/pipes/presentation/widgets/pipe_form.dart
- lib/features/pipes/application/pipe_form_controller.dart
- lib/features/pipes/data/pipe_repository.dart (nextCode + save + delete)
- lib/features/pipes/data/pipe_storage.dart
- (reuse) lib/features/wells/presentation/widgets/photo_grid_editor.dart

Talab:
1. Yangi/edit ikkalasini bitta sahifa.
2. initialPoints — /pipes/new query'dan parse (lat,lng;lat,lng;...).
3. Geo-length helper text + "Foydalanish" tugma.
4. Diameter chips uchun: [50, 75, 110, 125, 160] suggestions.
5. Submit/validate/logger — wells bilan parallel.

Tugatgach: Status DONE + INDEX + CHANGELOG.
```

## Status

TODO
