# 🛡️ DSFarm Flutter - Context Checkpoint

> **Generated:** 2025-12-20 02:50 JST  
> **Session:** Initial Architecture & Planning

---

## A. DIAGNOSTIK STATUS (SNAPSHOT)

### 1. Fase Aktif
`Week 01: Foundation & Auth` - 🟡 In Progress

### 2. File Penting
```
.agent/
├── agents.md           # AI collaboration SOP
├── ARCHITECTURE.md     # Technical design (multi-animal)
├── ROADMAP.md          # 12-week timeline
└── devlogs/
    └── Week-01-Foundation.md  # Current week checklist
```

### 3. GitHub Repository
- URL: https://github.com/fashrifsetiandi/DSfarm-flutter.git
- Branch: `main`
- Commits: 2

---

## B. KEPUTUSAN ARSITEKTUR YANG SUDAH DIBUAT

### 1. Product Vision
- **Nama:** DSFarm - Multi-Animal Farm Management
- **Target:** Commercial (Freemium model)
- **One account = Multiple farms** (bisa kelinci + kambing + ikan)

### 2. Animal Priority
1. 🐰 **Kelinci** (usaha sendiri sekarang) - Week 3-5
2. 🐐 **Kambing/Domba** (rencana kedepan) - Week 6-8
3. 🐟 **Ikan Gabus/Chana** (investasi breeding) - Week 9-11
4. 🐔 **Unggas** (future) - Post-launch

### 3. Development Strategy
- **Hybrid approach**: Sequential per-animal, tapi foundation multi-animal dari awal
- Config-driven architecture (AnimalConfig class)
- Generic models (Livestock, Offspring, Housing) yang bisa dipakai semua hewan

### 4. Tech Stack
- Flutter + Dart
- Supabase (Auth + Database)
- Riverpod (State Management)
- GoRouter (Navigation)

### 5. Subscription Tiers (Planned)
| Tier | Farms | Livestock | Price |
|------|-------|-----------|-------|
| Free | 1 | 50 max | Rp 0 |
| Pro | 3 | Unlimited | Rp 50K/bln |
| Enterprise | ∞ | + Team | Rp 200K/bln |

---

## C. PROGRESS WEEK 1

### ✅ Sudah Selesai
- [x] Flutter project created
- [x] agents.md added (AI collaboration SOP)
- [x] ARCHITECTURE.md created (database schema, folder structure)
- [x] ROADMAP.md created (12-week plan)
- [x] GitHub repo connected & pushed

### 🚧 Belum Dikerjakan
- [ ] Add dependencies (supabase_flutter, riverpod, go_router)
- [ ] Create folder structure (core/, models/, features/)
- [ ] Setup Supabase client
- [ ] Login/Register screens
- [ ] Auth state management

---

## D. INSTRUKSI UNTUK SESSION BERIKUTNYA

### Langkah Lanjutan (Next Actions)

1. **Baca context ini dulu** untuk refresh memory

2. **Update pubspec.yaml** dengan dependencies:
   ```yaml
   dependencies:
     supabase_flutter: ^2.0.0
     flutter_riverpod: ^2.4.0
     go_router: ^13.0.0
   ```

3. **Buat folder structure:**
   ```
   lib/
   ├── core/
   ├── models/
   ├── repositories/
   ├── providers/
   ├── features/
   └── animal_modules/
   ```

4. **Setup Supabase client** di `lib/core/services/supabase_service.dart`

5. **Refer ke ARCHITECTURE.md** untuk database schema dan detailed structure

---

## E. FILES TO READ ON RESUME

| Priority | File | Purpose |
|----------|------|---------|
| 🥇 | `.agent/CHECKPOINT.md` | This file - current state |
| 🥈 | `.agent/ARCHITECTURE.md` | Technical design |
| 🥉 | `.agent/ROADMAP.md` | Timeline & milestones |
| 4 | `.agent/devlogs/Week-01-Foundation.md` | Current week tasks |
| 5 | `.agent/agents.md` | AI collaboration rules |

---

## F. CATATAN PENTING

- Supabase URL & Key: **Sama dengan PWA RubyFarm yang sudah ada**
- Database tables: Perlu **migrasi** untuk support multi-farm (add `farms` table, update foreign keys)
- Existing data: Kelinci PWA data bisa di-migrate nanti

---

**🔖 Untuk melanjutkan session baru, copy isi file ini dan paste sebagai context!**
