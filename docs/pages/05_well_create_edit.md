# 05_well_create_edit.md — Kolodets yaratish/o'zgartirish

> Marshrut: `/wells/new`, `/wells/:wellId/edit` · Role: super_admin, admin · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad

Yangi kolodets qo'shish yoki mavjudini tahrirlash. Bir xil form, ikkala holat uchun.

## 2. UI

### AppBar
- Sarlavha:
  - Yangi: `Yangi kolodets`
  - Edit: `Kolodets B12`
- Trailing: **Saqlash** tugma (button matn sifatida yoki icon).

### Body (scrollable Form)
1. **Joylashuv** — read-only map preview (kichik harita, marker ko'rinadi)
   - Tap → `/map?picker=well` (joyni qaytadan tanlash, faza 2)
   - MVP: faqat ko'rsatadi (xaritadan kelgan koordinata o'zgartirilmaydi)
2. **Kod** (`code`) — read-only label (auto-generated B12). Yangi yaratishda placeholder "Avtomatik (B13)".
3. **Status** — segmented chip yoki RadioListTile (planned / working / done)
4. **Usta** — DropdownButton (mastersStream'dan active:true). Bo'sh bo'lsa: "Belgilanmagan" + "Usta qo'shish" link → `/masters`.
5. **O'rnatilgan sana** — DatePicker tugma. Bo'sh bo'lishi mumkin.
6. **Izoh** (notes) — multiline TextField (3-5 satr).
7. **Rasmlar** (photos) — grid:
   - Mavjud rasmlar — thumbnail (tap qilib o'chirish "X" tugmasi).
   - Oxirgi katak — "+" tugma → image_picker (camera / gallery).
   - Max 5 ta rasm (MVP).
8. **To'langan** (super_admin uchun) — Switch (default true).

### Pastki tugma
- "Saqlash" (Primary, full-width)
- "Bekor qilish" (text)

## 3. State

```dart
@riverpod
class WellFormController extends _$WellFormController {
  // wellId null → yangi yaratish
  // wellId mavjud → mavjudini tahrirlash
  @override
  WellFormState build({
    required String cityId,
    String? wellId,
    GeoPoint? initialLocation,  // /wells/new dan kelganda map'dan
  }) { ... }

  void updateStatus(WellStatus s);
  void updateMasterId(String? id);
  void updateInstalledAt(DateTime? d);
  void updateNotes(String n);
  void addPhoto(File f);   // local file → photo upload queue
  void removePhoto(int index);
  void togglePaid(bool v);  // super_admin only
  Future<void> submit();
}
```

`WellFormState` (freezed):
```dart
class WellFormState {
  final String cityId;
  final String? wellId;            // null = yangi
  final String? code;              // edit'da bor, yangida null (server tomondan beriladi)
  final GeoPoint location;
  final WellStatus status;
  final bool paid;                 // super_admin only edit
  final DateTime? installedAt;
  final String? masterId;
  final String? notes;
  final List<PhotoItem> photos;
  final bool isSubmitting;
  final String? error;
  final bool savedOk;
}

class PhotoItem {
  final String? remoteUrl;      // mavjud rasm (Storage'da)
  final File? localFile;        // hozir tanlangan, hali yuklanmagan
  final bool deleted;
}
```

## 4. Logika

### Initialize
- `wellId == null`: state.location = `initialLocation`, status = planned, paid = true (default), photos = [].
- `wellId != null`: Firestore'dan o'qiydi, state'ni to'ldiradi.

### Photo workflow
1. User "+" bosadi → `image_picker` (galereya yoki kamera).
2. `flutter_image_compress` bilan compress (max 1600px width, JPEG 80%).
3. State'ga `PhotoItem(localFile: file)` qo'shiladi (UI darrov ko'radi).
4. `submit()` paytida:
   - Yangi photos (`localFile != null`): Storage'ga upload, URL ni olib `remoteUrl` qiladi.
   - O'chirilganlar (`deleted: true`): Storage'dan delete.
5. Doc'da `photoUrls` faqat `remoteUrl` lar.

### Submit
```
1. Form validatsiya:
   - location bo'sh emas
   - status tanlangan
   - photos.length <= 5
2. Yangi: code = await WellRepository.nextCode(cityId)  // B13
3. Photo upload (parallel, Future.wait)
4. Firestore set (yangi yoki update):
   {
     id: wellId ?? newId,
     code,
     location, status, paid, installedAt, masterId, notes, photoUrls,
     createdAt: wellId == null ? serverTimestamp : existing,
     createdBy: similarly,
     updatedAt: serverTimestamp,
     updatedBy: currentUserId,
   }
5. logger.info('well.created' | 'well.updated', {wellId, cityId})
6. router.pop() yoki edit'da: well detail sahifasiga qaytish
7. Snackbar "Saqlandi"
```

### Bekor qilish
- Agar o'zgarish bor (`state.isDirty`) — confirm dialog "O'zgarishlar saqlanmagan. Chiqamizmi?"
- Tasdiq → `pop()`.

## 5. Firestore

- O'qish (edit): `cities/{cityId}/wells/{wellId}`.
- Yozish:
  - `cities/{cityId}/wells/{wellId}` set
  - `cities/{cityId}/counters/_codes` transaction (nextCode)
- Storage: `wells/{cityId}/{wellId}/{photoId}.jpg`

## 6. Permission

| Element | super_admin | admin | user |
|---|---|---|---|
| Sahifani ko'rish | ✓ | ✓ | ✗ |
| Paid switch | ✓ | yashirin | yashirin |
| Yaratganda paid majburiy=true | (xohlagan qiymat) | true (UI'da yashirin) | — |

Routerda guard: user kirsa avtomatik `/map` ga redirect.

## 7. Edge case

| Holat | Harakat |
|---|---|
| Internet yo'q | Submit'da "Faqat onlayn rejimda saqlash mumkin" snackbar |
| Storage upload qisman muvaffaqiyatsiz | Qaysi rasm yuklanmaganini ko'rsatish + "Qayta urinish" |
| Counter transaction conflict | Auto-retry 2 marta |
| Master ro'yxati bo'sh | Dropdown disabled + helper text "Hali usta qo'shilmagan" + link `/masters` |
| Edit paytida boshqa user shu doc'ni yangiladi | Firestore snapshot orqali state yangilanadi (yoki conflict dialog faza 2 — MVP'da silent overwrite "last write wins") |

## 8. Validatsiya qoidalari

- `location` — bo'sh emas (yangida `/wells/new?lat=..&lng=..` orqali keladi)
- `status` — `WellStatus` ichidan biri
- `notes` — maks 1000 chars
- `photos` — maks 5 ta
- `installedAt` — kelajakdagi sana ham ruxsat (mo'ljallangan)

## 9. Aloqador

- [04_well_detail.md](04_well_detail.md) — bu sahifaga tugma
- [09_masters_manage.md](09_masters_manage.md) — masterlar manbasi
- [../FIREBASE.md §2, §7](../FIREBASE.md) — schema + counter
- [../CODE_RULES.md §11](../CODE_RULES.md) — validatorlar

## 10. Build prompt

```
docs/README.md, docs/pages/05_well_create_edit.md, docs/FIREBASE.md §2 va §7,
docs/AUTH_AND_ROLES.md §3 ni o'qing.

Vazifa: WellCreateEditPage + WellFormController.

Joylashuv:
- lib/features/wells/presentation/well_create_edit_page.dart
- lib/features/wells/presentation/widgets/well_form.dart
- lib/features/wells/presentation/widgets/photo_grid_editor.dart (pipes uchun ham reusable bo'lsin)
- lib/features/wells/application/well_form_controller.dart
- lib/features/wells/data/well_repository.dart (nextCode + save + delete)
- lib/features/wells/data/well_storage.dart (Storage upload/delete)

Bosqichlar:
1. WellFormState (freezed) + Controller (@riverpod class) yaratish.
2. WellRepository.nextCode (transaction) va save (set with merge:false).
3. WellStorage.uploadPhoto (compress + put) va deletePhoto.
4. Form widgets: location preview, status segmented, master dropdown, date picker, notes, photo grid, paid switch (super-admin perms bilan).
5. Submit logikasi: photo upload → Firestore set → router pop.
6. Bekor qilish — confirm dialog (isDirty bo'lsa).
7. Router guard: role != admin && != super_admin → /map ga redirect.

Code rules:
- Validators (core/utils/validators.dart) ishlatish
- AppSpacing
- Logger event'lar

Tugatgach: Status DONE, INDEX.md, CHANGELOG.md
```

## Status

TODO
