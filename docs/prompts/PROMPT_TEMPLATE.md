# PROMPT_TEMPLATE.md

> Yangi sahifa, feature yoki refactor uchun shablon prompt.
> Kirish: [../README.md](../README.md)

---

## 1. Maqsad

Bu fayl — AI'ga vazifa berishda **standart format**. Maqsad: AI har doim oldindan **kerakli hujjatlarni o'qib**, **qoidalarga binoan** kod yozsin, **logni yozib** qo'ysin.

## 2. Sahifa qurish promptlari

Har sahifaning o'z MD'sida (`docs/pages/NN_<name>.md`) "Build prompt" bo'limi bor. Ushbu fayldagi shablon yangi sahifa MD'si yaratganda **MD ichiga** kiritiladi.

### 2.1 Sahifa MD shabloni (yangi sahifa yaratish)

```markdown
# NN_<name>.md — <O'zbek nomi>

> Marshrut: `/<path>` · Role: <kim> · Status: TODO
> Index: [INDEX.md](INDEX.md)

---

## 1. Maqsad
<1-2 jumla — bu sahifa nima uchun>

## 2. UI
<AppBar, Body, FAB, Drawer — qisqa bo'limlarga bo'lib>

## 3. State
<Riverpod providers va state class'lari>

## 4. Logika
<Flow, async ish, edge case'lar bilan bog'liq>

## 5. Firestore o'qish/yozish
<Qaysi collection/doc'lar>

## 6. Permission
<Jadval: action × role>

## 7. Edge case
<Jadval: holat × harakat>

## 8. Aloqador hujjatlar
<Linklar boshqa MD'larga>

## 9. Build prompt
<AI uchun konkret topshiriq, quyidagi shablon bo'yicha>

## Status
TODO | WIP | DONE | BLOCKED
```

### 2.2 Build prompt shabloni

Sahifa MD ichiga "Build prompt" bo'limiga yoziladi:

```
docs/README.md ni o'qing va so'ngra docs/pages/<page>.md ni to'liq o'qing.
docs/<related>.md fayllariga ham qarang: ...

Vazifa: <PageName> ni qurish.

Joylashuv:
- lib/features/<feature>/presentation/<page>_page.dart
- lib/features/<feature>/presentation/widgets/<widget>.dart
- lib/features/<feature>/application/<controller>.dart
- lib/features/<feature>/data/<repository>.dart
- lib/features/<feature>/domain/<entity>.dart
- (qo'shimcha: routes, lokalizatsiya, dependencies)

Talab:
1. <Qadam 1 - konkret>
2. <Qadam 2 - konkret>
   - sub-detail
3. <Qadam 3 - konkret>

Code rules:
- Riverpod codegen (annotation + generator)
- Freezed states
- AppSpacing ishlatish (no hardcoded EdgeInsets)
- Validators core/utils/validators.dart dan
- Logger event'lar — har asosiy action uchun

Tugatgach:
- docs/pages/<page>.md → Status: DONE
- docs/pages/INDEX.md jadvalda statusni yangilang
- docs/logs/CHANGELOG.md ga 1-2 qator yozing
- Agar xato uchragan bo'lsa: docs/logs/ERRORS.md ga sabab va yechim yozing
```

## 3. Refactor promptlari

```
docs/README.md ni o'qing. Keyin docs/CODE_RULES.md va docs/ARCHITECTURE.md ni qayta tekshiring.

Vazifa: <refactor turi>

Aniqlash:
- Qaysi fayllar ta'sirlanadi
- Test mavjudmi (bo'lsa qaysi)
- Bu o'zgarish Firestore schema'ga ta'sir qiladimi
- Permission matrisasiga ta'sir qiladimi

Bajaring:
1. ...
2. ...
3. ...

Tugatgach:
- O'zgartirilgan MD'lar ham yangilanadimi (FIREBASE, AUTH_AND_ROLES, ARCHITECTURE)?
- CHANGELOG.md
```

## 4. Bug fix promptlari

```
docs/README.md ni o'qing. docs/logs/ERRORS.md ga qarang — shu yoki shunga o'xshash bug avval bo'lganmi?

Bug:
<simptom + nima qilinganda chiqadi>

Kerak bo'lgan ma'lumot:
- Reproducible steps
- Console log
- Aloqador fayllar (siz topdingiz)

Bajaring:
1. Root cause topish (yo'lda emas, root)
2. Fix qo'yish
3. Test qo'shish (agar feasible)

Tugatgach:
- CHANGELOG.md ga fix qatori
- ERRORS.md ga sabab+yechim
```

## 5. Yangi MD yaratish (boshqa MD'lar bilan integratsiya)

Agar siz yangi `docs/<topic>.md` yaratdingiz:

1. Tepada nav qatori: `> Oldingi: [X.md] · Keyingi: [Y.md]`.
2. Eski MD'larga yangi MD'ga link qo'shing (`README.md` "Hujjatlar xaritasi" qismida).
3. Yangi MD ichida tegishli eski MD'larga linklar.
4. `CHANGELOG.md`'ga 1 qator: "docs: yangi <topic>.md qo'shildi".

## 6. Promptlar ichidagi best-practice

- **Aniq joylashuv (fayl yo'li)** ko'rsating. AI taxmin qilmasin.
- **Tartib bilan** qadamlarni qo'ying. Parallel emas — sequential.
- **Code rules**ni eslatib turing (lekin har sef CODE_RULES.md ni o'qing deyiladi).
- **Tugatish kriteriylari**ni aniq ko'rsating (status, log, INDEX).
- **Linklar** bilan bog'liq MD'larni eslating.

## 7. AI'ga umumiy ko'rsatma (har sessiya boshida)

```
Siz Turon Suv loyihasidagi Flutter ilovasi ustida ishlayotgan AI dasturchisiz.

QOIDALAR:
1. docs/README.md ni boshlanishda to'liq o'qing.
2. Vazifaga aloqador docs/pages/*.md va docs/<topic>.md ni o'qing.
3. docs/CODE_RULES.md qoidalariga rioya qiling (no extra comments, no future-proofing).
4. Riverpod codegen, Freezed, go_router — qat'iy.
5. Firestore schema docs/FIREBASE.md ga mos bo'lsin.
6. Permission docs/AUTH_AND_ROLES.md jadvaliga mos bo'lsin.
7. Tugatganingizda docs/logs/CHANGELOG.md ga yozing.

NO:
- Hech qachon mavjud kodga zid pattern qo'shmang.
- Hech qachon backward-compat shim qo'ymang.
- Hech qachon comment yozmang (faqat noaniq "nima uchun" uchun 1 qator).
- Hech qachon TODO qoldirmang — yo bajarish, yo aniq belgilash (TODO(handoff): ...).

QILING:
- Vazifani 1 sentence bilan boshlang ("X.dart yaratyapman").
- Asosiy qadamlardan keyin 1 sentence update.
- Tugagandan keyin oxirgi 1-2 sentence — nima o'zgardi va keyingisi nima.
```

Bu blok'ni har yangi sessiya boshida user'ga yuborishni eslatib qo'ying.
