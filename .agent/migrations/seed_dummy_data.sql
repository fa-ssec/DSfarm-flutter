-- ========================================================
-- SEED DATA untuk Testing DSFarm
-- ========================================================
-- PENTING: Ganti @FARM_ID dengan farm ID kamu dari database
-- Cara dapat farm ID: lihat URL saat di dashboard
-- Contoh: /dashboard/1132ae45-d9c6-4859-88e5-8c1ca15415f7
-- ========================================================

-- NOTE: Jalankan satu section per waktu di Supabase SQL Editor

-- 1. PERTAMA: Cari Farm ID kamu
-- SELECT id, name FROM farms;

-- 2. Set variabel (ganti dengan ID farm kamu)
-- Contoh: '1132ae45-d9c6-4859-88e5-8c1ca15415f7'

-- ========================================================
-- BREEDS (Ras)
-- ========================================================
INSERT INTO breeds (farm_id, name, code, description) VALUES
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'New Zealand White', 'NZW', 'Kelinci putih besar'),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Rex', 'REX', 'Bulu halus seperti velvet'),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Flemish Giant', 'FLG', 'Kelinci raksasa'),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Holland Lop', 'HLP', 'Telinga panjang menggantung')
ON CONFLICT DO NOTHING;

-- ========================================================
-- BLOCKS (Blok Kandang)
-- ========================================================
INSERT INTO blocks (farm_id, code, name, description) VALUES
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'BLOCK-A', 'Gedung Indukan', 'Kandang untuk indukan'),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'BLOCK-B', 'Kandang Anakan', 'Kandang untuk anakan lepas sapih'),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'BLOCK-C', 'Karantina', 'Kandang isolasi')
ON CONFLICT DO NOTHING;

-- ========================================================
-- HOUSINGS (Kandang) - Jalankan setelah BLOCKS
-- ========================================================
INSERT INTO housings (farm_id, code, name, capacity, housing_type, status, position, block_id) 
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7', 
  'A-' || LPAD(n::text, 2, '0'),
  'Kandang Induk ' || n,
  1,
  'individual',
  'active',
  'A-' || LPAD(n::text, 2, '0'),
  (SELECT id FROM blocks WHERE code = 'BLOCK-A' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1)
FROM generate_series(1, 10) AS n
ON CONFLICT DO NOTHING;

-- ========================================================
-- FINANCE CATEGORIES
-- ========================================================
INSERT INTO finance_categories (farm_id, name, type, icon, is_system) VALUES
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Penjualan Anakan', 'income', '🐰', true),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Penjualan Indukan', 'income', '💰', false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Pembelian Pakan', 'expense', '🥕', false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Pembelian Obat', 'expense', '💊', false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Biaya Listrik', 'expense', '💡', false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Biaya Tenaga Kerja', 'expense', '👷', false)
ON CONFLICT DO NOTHING;

-- ========================================================
-- FINANCE TRANSACTIONS (6 bulan terakhir)
-- ========================================================
-- Pemasukan bulan-bulan lalu
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'income',
  (SELECT id FROM finance_categories WHERE name = 'Penjualan Anakan' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (RANDOM() * 200000 + 50000)::int,
  (CURRENT_DATE - (n * 30 + (RANDOM() * 10)::int))::date,
  'Jual anakan batch ' || n
FROM generate_series(1, 6) AS n;

-- Pengeluaran bulan-bulan lalu
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'expense',
  (SELECT id FROM finance_categories WHERE name = 'Pembelian Pakan' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (RANDOM() * 100000 + 30000)::int,
  (CURRENT_DATE - (n * 30 + (RANDOM() * 10)::int))::date,
  'Beli pakan bulan ' || n
FROM generate_series(1, 6) AS n;

-- Tambahan pengeluaran
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'expense',
  (SELECT id FROM finance_categories WHERE name = 'Pembelian Obat' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (RANDOM() * 50000 + 10000)::int,
  (CURRENT_DATE - (n * 45))::date,
  'Beli obat preventif'
FROM generate_series(1, 4) AS n;

-- ========================================================
-- LIVESTOCK (Indukan) - Jalankan setelah BREEDS dan HOUSINGS
-- ========================================================
INSERT INTO livestocks (farm_id, code, name, gender, birth_date, status, breed_id)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'NZW-B' || LPAD(n::text, 2, '0'),
  CASE WHEN n <= 5 THEN 'Betina ' || n ELSE NULL END,
  CASE WHEN n <= 5 THEN 'female' ELSE 'male' END,
  CURRENT_DATE - (365 + n * 30),
  'active',
  (SELECT id FROM breeds WHERE code = 'NZW' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1)
FROM generate_series(1, 7) AS n
ON CONFLICT DO NOTHING;

-- ========================================================
-- OFFSPRING (Anakan)
-- ========================================================
INSERT INTO offsprings (farm_id, code, gender, birth_date, status, breed_id)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'NZW-ANK-' || LPAD(n::text, 3, '0'),
  CASE WHEN RANDOM() > 0.5 THEN 'male' ELSE 'female' END,
  CURRENT_DATE - (30 + n * 5),
  CASE 
    WHEN n <= 3 THEN 'infarm'
    WHEN n <= 6 THEN 'weaned'
    WHEN n <= 9 THEN 'ready_sell'
    ELSE 'sold'
  END,
  (SELECT id FROM breeds WHERE code = 'NZW' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1)
FROM generate_series(1, 12) AS n
ON CONFLICT DO NOTHING;

-- ========================================================
-- REMINDERS
-- ========================================================
INSERT INTO reminders (farm_id, type, title, description, due_date, is_completed) VALUES
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'vaccination', 'Vaksinasi Kelinci', 'Vaksin rutin untuk semua indukan', CURRENT_DATE + 7, false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'custom', 'Beli Pakan', 'Stok pakan hampir habis', CURRENT_DATE + 3, false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'weaning', 'Cek Anakan Sapih', 'Periksa anakan yang siap sapih', CURRENT_DATE + 1, false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'health_check', 'Pembersihan Kandang', 'Bersihkan semua kandang blok A', CURRENT_DATE + 5, false);

-- ========================================================
-- HEALTH RECORDS
-- ========================================================
INSERT INTO health_records (farm_id, livestock_id, type, title, record_date, notes)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  id,
  CASE WHEN RANDOM() > 0.5 THEN 'checkup' ELSE 'vaccination' END,
  CASE WHEN RANDOM() > 0.5 THEN 'Pemeriksaan Rutin' ELSE 'Vaksinasi' END,
  CURRENT_DATE - (RANDOM() * 30)::int,
  'Kondisi sehat'
FROM livestocks 
WHERE farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7'
LIMIT 5;

-- ========================================================
-- SELESAI!
-- ========================================================
-- Refresh browser untuk melihat data baru
