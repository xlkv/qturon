# 09_masters_manage.md — Ustalar boshqaruvi

> Marshrut: `/masters` · Role: super_admin, admin (CRUD); user (read-only) · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Tanlangan shahar uchun ustalar ro'yxati. Yangi qo'shish, edit, deactivate.

## 2. UI

### AppBar
- Sarlavha: `Ustalar — Toshkent` (shahar nomi)
- Trailing: **Yangi** (+) tugma — super_admin, admin uchun

### Body
- `ListView` (yoki `SliverList`):
  - Har item: `ListTile`
    - leading: avatar (ism birinchi harfi)
    - title: ism
    - subtitle: tel + status (active/inactive)
    - trailing: 3 nuqta menyu (Edit, Deactivate) — perms bilan
- Search bar yuqorida (ism bo'yicha filter).
- Empty state: "Hali usta qo'shilmagan" + "+ Yangi" tugma (perms bilan).

### Yangi/Edit dialog
- AlertDialog yoki BottomSheet:
  - Ism (TextFormField, required, min 2 chars)
  - Telefon (TextFormField, ixtiyoriy, format `+998 90 123 45 67`)
  - Active switch (faqat edit'da; yangida default true)
  - "Saqlash" / "Bekor qil"

## 3. State

```dart
@riverpod
Stream<List<Master>> mastersStream(MastersStreamRef ref, String cityId, {bool activeOnly = false});

@riverpod
class MasterFormController extends _$MasterFormController {
  @override
  MasterFormState build(String cityId, String? masterId);
  void updateName(String s);
  void updatePhone(String s);
  void toggleActive(bool v);
  Future<void> submit();
}
```

`MasterRepository`:
- `watchAll(cityId, {activeOnly})`
- `save(cityId, master)` — yangi yoki update
- `deactivate(cityId, masterId)` — `active=false`
- (super_admin only) `delete(cityId, masterId)` — hard delete

## 4. Logika

- List — `mastersStream`'dan kelgan, search + active filter (client-side).
- Yangi: bottom sheet → form → submit → Firestore add.
- Edit: bottom sheet (existing data) → form → submit.
- Deactivate: confirm → `active=false`. Eski yozuvlardagi masterId saqlanadi.
- Delete (super_admin): confirm "Bu master bilan bog'liq yozuvlar ham bo'lishi mumkin. Davom etamizmi?"

## 5. Firestore

- O'qish: `cities/{cityId}/masters` stream.
- Yozish: add, update, delete shu collectionda.

## 6. Permission

| Element | super_admin | admin | user |
|---|---|---|---|
| Sahifa | ✓ | ✓ | ✓ (read-only) |
| + Yangi | ✓ | ✓ | ✗ |
| Edit | ✓ | ✓ | ✗ |
| Deactivate | ✓ | ✓ | ✗ |
| Hard delete | ✓ | ✗ | ✗ |

## 7. Edge case

| Holat | Harakat |
|---|---|
| Telefon format noto'g'ri | Validator xato (ixtiyoriy bo'lsa ham, bo'sh emas + noto'g'ri format → xato) |
| Bir xil ism bor | Ogohlantirish (lekin ruxsat — fname/lname har xil) |

## 8. Aloqador

- [05_well_create_edit.md](05_well_create_edit.md), [07_pipe_create_edit.md](07_pipe_create_edit.md) — master tanlash dropdown
- [../FIREBASE.md §2](../FIREBASE.md)

## 9. Build prompt

```
docs/README.md, docs/pages/09_masters_manage.md, docs/AUTH_AND_ROLES.md §3.2 ni o'qing.

Vazifa: MastersManagePage + MasterFormController + MasterRepository.

Joylashuv:
- lib/features/masters/presentation/masters_manage_page.dart
- lib/features/masters/presentation/widgets/master_form_sheet.dart
- lib/features/masters/presentation/widgets/master_tile.dart
- lib/features/masters/application/masters_stream.dart
- lib/features/masters/application/master_form_controller.dart
- lib/features/masters/data/master_repository.dart
- lib/features/masters/domain/master.dart (freezed)

Talab:
1. List + search + filter (active only switch).
2. + tugma → bottom sheet (yangi yaratish).
3. Tile tap (yoki Edit menu) → bottom sheet (existing).
4. Deactivate — confirm + active=false.
5. Hard delete super_admin uchun.
6. Phone validator — ixtiyoriy lekin format check.

Code rules: Riverpod codegen, AppSpacing, Logger.

Tugatgach: Status DONE + INDEX + CHANGELOG.
```

## Status

TODO
