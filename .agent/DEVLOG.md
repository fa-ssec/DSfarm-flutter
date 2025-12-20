# DEVLOG - DSFarm Flutter

## Week 6+ (2025-12-21)

### ✅ Block Kandang System
- **Struktur**: Farm → Block → Kandang (Position)
- **Auto-position**: Otomatis generate posisi dalam block (A-01, A-02, dst)
- **Model/Repo/Provider**: Lengkap dengan CRUD
- **Settings UI**: Kelola block via Settings → Block Kandang

### ✅ Breeding → Offspring Integration
- Auto-create offspring saat catat kelahiran
- Offspring code format: `[DAM_BREED]-[SIRE_SEQ].[DAM_SEQ]-[YYMMDD]-[SEQ]`
- Auto-create reminders (palpasi, perkiraan lahir, weaning)

### ✅ Livestock Auto-Code
- Format: `[BREED]-[J/B][SEQ]` (contoh: NZW-B01)
- Sequence per breed + gender
- Breed model/repo/provider untuk manage ras

### ✅ Settings Page
- Block Kandang management
- Breeds (Ras) management
- Finance Categories management

---

## Week 5 (2025-12-20)

### ✅ Finance & Inventory
- Finance transactions with categories (income/expense)
- Inventory items with stock movements
- Equipment tracking

---

## Week 4 (2025-12-19)

### ✅ Breeding & Offspring
- Breeding records with mating → birth → weaning flow
- Offspring tracking with status progression
- Lineage tracking (parent links)

---

## Week 3 (2025-12-18)

### ✅ Housing & Livestock
- Housing/Kandang management
- Livestock with gender, age, status
- Housing assignment

---

## Week 2 (2025-12-17)

### ✅ Multi-Farm Architecture
- Farm selection
- All data scoped to current farm
- RLS for multi-tenancy

---

## Week 1 (2025-12-16)

### ✅ Auth Foundation
- Login/Register with Supabase Auth
- GoRouter navigation
- Riverpod state management
