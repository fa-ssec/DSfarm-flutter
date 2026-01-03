# DSFarm - Feature & UI Improvement Roadmap

*Created: 2026-01-03*

## 🚀 Priority Features

### 1. Dashboard Ringkasan
- Statistik harian: kelinci siap kawin, bunting mendekati lahir
- Reminder vaksin & jadwal penting
- Quick overview setiap buka app

### 2. Push Notifications
- Reminder otomatis: palpasi, perkiraan lahir, sapih, vaksin
- Tidak lupa jadwal penting

### 3. Print Label/Stiker
- Cetak label kandang dengan QR code
- Support printer thermal
- Manajemen kandang lebih efisien

### 4. Laporan Export
- Export PDF/Excel
- Laporan penjualan, breeding performance, inventori
- Dokumentasi & analisis

### 5. Search Global
- Cari kelinci by kode, ras, kandang dari anywhere
- Navigasi cepat

---

## ✨ Nice-to-Have Features

### 6. Foto Kelinci
- Attach foto ke profil kelinci
- Gallery per kelinci

### 7. Family Tree Visual
- Diagram silsilah interaktif
- Visualisasi breeding lineage

### 8. Jadwal Vaksin
- Tracking vaksin dengan reminder
- Riwayat vaksinasi

### 9. Kalkulator Pakan
- Estimasi kebutuhan pakan per populasi
- Berdasarkan umur dan fase

### 10. Grafik Berat
- Chart pertumbuhan berat per kelinci
- Trend analysis

---

## 🎨 UI Improvements

### Dashboard
- [ ] Cards dengan animasi
- [ ] Skeleton loading
- [ ] Real-time stats

### List View
- [ ] Pull-to-refresh animation
- [ ] Infinite scroll
- [ ] Better empty states

### Theme
- [ ] Dark mode toggle
- [ ] Custom color themes

### Mobile
- [ ] Bottom navigation untuk quick access
- [ ] Swipe gestures

### Micro-interactions
- [ ] Haptic feedback
- [ ] Smooth transitions
- [ ] Success/error animations

### Loading States
- [ ] Shimmer effect instead of spinner
- [ ] Progressive loading

---

## 📋 RLS Policies Pending (Supabase)

```sql
DROP POLICY IF EXISTS "public_read_housings" ON housings;
DROP POLICY IF EXISTS "public_read_livestocks" ON livestocks;
DROP POLICY IF EXISTS "public_read_breeding_records" ON breeding_records;

ALTER TABLE housings ENABLE ROW LEVEL SECURITY;
ALTER TABLE livestocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE breeding_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_read_housings" ON housings FOR SELECT TO anon USING (true);
CREATE POLICY "public_read_livestocks" ON livestocks FOR SELECT TO anon USING (true);
CREATE POLICY "public_read_breeding_records" ON breeding_records FOR SELECT TO anon USING (true);
```
