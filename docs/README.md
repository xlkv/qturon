# Turon Suv — Loyiha Hujjati (KIRISH NUQTASI)

> **AI o'qiy boshlasangiz, shu yerdan boshlang.**
> Bu fayl butun loyihaning **kompasi**. Quyidagi barcha MD fayllar bir-biriga link orqali bog'langan. Hech qachon link tashqarisidagi taxminga tayanmang — har doim havola berilgan faylga o'tib o'qing.

---

## 1. Loyiha qisqacha

**Nomi:** Turon Suv (ish nomi)
**Maqsadi:** Shaharlarga toza suv yetkazib berish kompaniyasi uchun **kolodets** (suv quduqlari) va **turba** (suv quvurlari) tarmog'ini boshqarish ilovasi.
**Platformalar:** Android va Windows (Flutter). iOS keyinroq.
**Stack:** Flutter + Yandex Maps + Firebase (Firestore + Storage + Cloud Functions).
**Til:** O'zbekcha (lotin), faqat. i18n hozir kerak emas.
**Multi-city:** Ha, boshidan. Har shahar — alohida Firestore subcollection.

## 2. Asosiy iborlar (terminologiya)

| Inglizcha (kodda) | O'zbekcha (UI'da) | Izoh |
|---|---|---|
| `well` | kolodets | Suv qudug'i (yumaloq marker, kod: `B1`, `B2`, ...) |
| `pipe` | turba | Suv quvuri (polyline, kod: `P1`, `P2`, ...) |
| `master` | usta | Quruvchi (dropdown bilan tanlanadi) |
| `city` | shahar | Geografik birlik |
| `pass-key` | kirish kodi | 6 xonali raqam, har userning o'ziga xos |
| `paid` | to'langan | Pul kelganini belgilash (faqat super-admin ko'radi/o'zgartiradi) |

## 3. Hujjatlar xaritasi

### Asosiy qoidalar
- [ARCHITECTURE.md](ARCHITECTURE.md) — Folder strukturasi, layer'lar, state management, packages
- [FIREBASE.md](FIREBASE.md) — Firestore schema, Storage, Security Rules, Cloud Functions
- [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md) — Pass-key login, role permission matrix, super-admin yaratish
- [CODE_RULES.md](CODE_RULES.md) — Naming, comments, error handling, lints
- [WORKFLOW.md](WORKFLOW.md) — Dev workflow, AI handoff, CHANGELOG/ERRORS yozish

### Sahifalar (har biri alohida MD)
- [pages/INDEX.md](pages/INDEX.md) — Barcha sahifalar ro'yxati
- Har bir sahifa: maqsad, role ruxsatlari, layout, state, Firestore read/write, build prompt

### Promptlar
- [prompts/PROMPT_TEMPLATE.md](prompts/PROMPT_TEMPLATE.md) — Yangi sahifa qurish uchun shablon

### Loglar (har o'zgarishdan keyin yangilanadi)
- [logs/CHANGELOG.md](logs/CHANGELOG.md) — Nima qilingan, qachon
- [logs/ERRORS.md](logs/ERRORS.md) — Xatolar va yechimlar

## 4. Roles (qisqacha — to'liq matritsa AUTH_AND_ROLES.md'da)

| Role | Qisqa ta'rif |
|---|---|
| **super_admin** | Hammasini ko'radi, hammasini o'zgartiradi. Pul/users/cities mavzulari faqat unda. |
| **admin** | `paid: true` kolodets/turbalarni ko'radi va to'liq boshqaradi. `paid` field umuman ko'rinmaydi. Yangi qo'shganlari avtomatik `paid: true`. |
| **user** | `paid: true` kolodets/turbalarni faqat **o'qiydi**. Hech narsa o'zgartirmaydi. `paid` field ko'rinmaydi. |

> Pul (`paid`) — super-admin'ning shaxsiy filtri. Admin/user uchun bu field umuman mavjud emasdek.

## 5. Vibe coding qoidalari (HAR DOIM o'qing)

1. **Hech qachon "yangi pattern" ixtiro qilmang.** Avval [ARCHITECTURE.md](ARCHITECTURE.md) va [CODE_RULES.md](CODE_RULES.md) ga qarang. Agar shu yerda yo'q bo'lsa — to'xtang va menga ayting.
2. **Har bir page o'z MD'siga ega.** Sahifa qurishdan oldin [pages/](pages/) ichidagi tegishli MD'ni to'liq o'qing.
3. **Firestore'ga yozish/o'qish — faqat [FIREBASE.md](FIREBASE.md) dagi schema bo'yicha.** Yangi field qo'shsangiz, schema'ni ham yangilang.
4. **Har sezilarli o'zgarishdan keyin** [logs/CHANGELOG.md](logs/CHANGELOG.md) ga 1-2 qator yozing.
5. **Bug yoki diqqat talab qiluvchi xato** uchraganda [logs/ERRORS.md](logs/ERRORS.md) ga sababi + yechimi.
6. **Tugatilmagan ish qoldirmang.** Yarim implementatsiya — texnik qarz. Agar ulgurmasangiz, `pages/<page>.md` da `Status: WIP` deb qoldiring.
7. **Comment yozish:** kod o'zi gapiradi. Faqat **nima uchun** noaniq joylarga 1 qator izoh.
8. **Backwards-compat shim qo'shmang.** Hozir loyiha bo'sh — to'g'ridan-to'g'ri to'g'ri qiling.

## 6. AI handoff (yangi sessiya boshlanganda)

Yangi Claude Code (yoki boshqa vibe-coding tool) sessiyasi boshlanganda ushbu prompt'ni yuboring:

```
docs/README.md ni to'liq o'qing. Keyin docs/WORKFLOW.md dagi "Sessiya boshlash"
bo'limini bajaring. Faqat shundan keyin men so'ragan vazifaga o'ting.
```

To'liq handoff protokoli: [WORKFLOW.md#sessiya-boshlash](WORKFLOW.md)

## 7. Tez sandiq (TL;DR har bir narsani topish)

| Savol | Javob qaerda |
|---|---|
| Kod qaysi papkada yashaydi? | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Firestore qanday tartibda? | [FIREBASE.md](FIREBASE.md) |
| Kim nimani ko'ra oladi? | [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md) |
| Yangi page qanday quriladi? | [WORKFLOW.md](WORKFLOW.md) + [prompts/PROMPT_TEMPLATE.md](prompts/PROMPT_TEMPLATE.md) |
| Super-admin yaratish? | [AUTH_AND_ROLES.md](AUTH_AND_ROLES.md) ning oxirgi bo'limi |
| Konkret sahifa speci? | [pages/](pages/) |
| Oldingi xatolar? | [logs/ERRORS.md](logs/ERRORS.md) |
| Yaqinda nima o'zgardi? | [logs/CHANGELOG.md](logs/CHANGELOG.md) |

---

**Status:** PLANLASH BOSQICHI. Kod hali yozilmagan.
**Keyingi qadam:** [WORKFLOW.md](WORKFLOW.md) → "Birinchi sprint" bo'limi.
