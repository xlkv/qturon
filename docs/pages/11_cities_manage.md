# 11_cities_manage.md — Shaharlar boshqaruvi (super_admin)

> Marshrut: `/cities` · Role: super_admin · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Super-admin shaharlarni yaratadi, edit qiladi, deactivate qiladi. Har shahar — alohida wells/pipes/masters scope.

## 2. UI

### AppBar
- Sarlavha: `Shaharlar`
- Trailing: **Yangi** (+)

### Body
- `ListView`:
  - Har item: shahar nomi, marker count (kolodets soni), active/inactive, 3 nuqta menyu (Edit, Deactivate, Delete).

### Yangi/Edit dialog
- **Nom** (required)
- **Markaz nuqta** — `LocationPickerField`: tap → kichik xarita ochiladi, joyni tanlanadi
- **Default zoom** — Slider (10–15, default 12)
- **Active** switch (edit)

## 3. State

```dart
@riverpod
Stream<List<City>> citiesStream(CitiesStreamRef ref);

@riverpod
Future<int> wellsCount(WellsCountRef ref, String cityId);
@riverpod
Future<int> pipesCount(PipesCountRef ref, String cityId);

@riverpod
class CityFormController extends _$CityFormController {
  @override
  CityFormState build(String? cityId);
  void updateName(String s);
  void updateCenter(GeoPoint p);
  void updateZoom(double z);
  void toggleActive(bool v);
  Future<void> submit();
}
```

`CityRepository`:
- `watchAll()`
- `save(city)`
- `deactivate(cityId)`
- `delete(cityId)` — agar bo'sh bo'lsa (wells/pipes count == 0)

## 4. Logika

- List — yengil, count'lar lazy.
- Yangi: dialog → form → submit → list refresh.
- Delete: faqat bo'sh shaharlar uchun. Aks holda "Avval kolodets/turbalarni o'chiring".
- Deactivate: faqat ko'rinmasin, ma'lumotlar saqlangan.

## 5. Firestore

- O'qish: `cities` collection.
- Yozish: doc set/update.
- Delete — agar wells/pipes/masters subcollection bo'lsa rad etiladi (rules emas, biznes logikasi).

## 6. Active super-admin city pinleri

Active shaharni o'zgartirish — drawer'dagi dropdown ([03_map_home.md](03_map_home.md)). Super-admin tomonidan tanlangan shahar `SharedPreferences`'da saqlanadi (`active_city_id`).

## 7. Permission

Faqat super_admin. Router guard.

## 8. Edge case

| Holat | Harakat |
|---|---|
| Bo'sh ro'yxat (birinchi run) | Empty state: "Birinchi shahar qo'shing" + Splash'dan yo'naltirilgan bo'lishi mumkin |
| Delete'da wells > 0 | Confirm rad etiladi, xabar bilan |
| Center tanlanmagan | Validatsiya xato |

## 9. Aloqador

- [../FIREBASE.md §2](../FIREBASE.md) — cities schema
- [03_map_home.md](03_map_home.md) — shahar dropdown
- [10_users_manage.md](10_users_manage.md) — user'ga shahar tayinlash

## 10. Build prompt

```
docs/README.md, docs/pages/11_cities_manage.md, docs/FIREBASE.md §2 ni o'qing.

Vazifa: CitiesManagePage + CityRepository + CityFormController.

Joylashuv:
- lib/features/cities/presentation/cities_manage_page.dart
- lib/features/cities/presentation/widgets/city_form_sheet.dart
- lib/features/cities/presentation/widgets/location_picker_field.dart (reuse for wells if kerak bo'lsa)
- lib/features/cities/application/cities_stream.dart
- lib/features/cities/application/city_form_controller.dart
- lib/features/cities/application/active_city_provider.dart (super-admin uchun)
- lib/features/cities/data/city_repository.dart
- lib/features/cities/domain/city.dart (freezed)

Talab:
1. Router guard.
2. List items + counts (lazy load wellsCount/pipesCount).
3. Form: nom + LocationPickerField (kichik xarita modal) + zoom slider.
4. Delete: bo'sh emas bo'lsa rad et.
5. ActiveCityProvider — SharedPreferences orqali persistent.
6. Empty state.

Code rules: standart.

Tugatgach: Status DONE + INDEX + CHANGELOG.
```

## Status

TODO
