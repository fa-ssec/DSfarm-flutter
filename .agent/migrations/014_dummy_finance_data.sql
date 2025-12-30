-- ═══════════════════════════════════════════════════════════
-- DSFARM - Dummy Finance Data (12 bulan)
-- Run this in Supabase SQL Editor AFTER running 013_update_finance_categories.sql
-- ═══════════════════════════════════════════════════════════

-- Clear existing finance transactions (optional)
-- DELETE FROM finance_transactions WHERE farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7';

-- ═══════════════════════════════════════════════════════════
-- PEMASUKAN - Penjualan Anakan (12 bulan)
-- ═══════════════════════════════════════════════════════════
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'income',
  (SELECT id FROM finance_categories WHERE name = 'Penjualan Anakan' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (150000 + (RANDOM() * 250000))::int,
  (CURRENT_DATE - INTERVAL '1 month' * n + INTERVAL '1 day' * (RANDOM() * 10)::int)::date,
  'Jual anakan batch ' || (12 - n + 1)
FROM generate_series(0, 11) AS n;

-- Tambahan penjualan anakan (2x per bulan)
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'income',
  (SELECT id FROM finance_categories WHERE name = 'Penjualan Anakan' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (100000 + (RANDOM() * 200000))::int,
  (CURRENT_DATE - INTERVAL '1 month' * n + INTERVAL '1 day' * (15 + (RANDOM() * 10)::int))::date,
  'Jual anakan retail'
FROM generate_series(0, 8) AS n;

-- ═══════════════════════════════════════════════════════════
-- PEMASUKAN - Penjualan Indukan (culling, setiap 3 bulan)
-- ═══════════════════════════════════════════════════════════
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'income',
  (SELECT id FROM finance_categories WHERE name = 'Penjualan Indukan' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (300000 + (RANDOM() * 200000))::int,
  (CURRENT_DATE - INTERVAL '3 month' * n)::date,
  'Culling indukan tua'
FROM generate_series(0, 3) AS n;

-- ═══════════════════════════════════════════════════════════
-- PEMASUKAN - Penjualan Kotoran (setiap 2 bulan)
-- ═══════════════════════════════════════════════════════════
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'income',
  (SELECT id FROM finance_categories WHERE name = 'Penjualan Kotoran' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (50000 + (RANDOM() * 50000))::int,
  (CURRENT_DATE - INTERVAL '2 month' * n)::date,
  'Jual pupuk kandang'
FROM generate_series(0, 5) AS n;

-- ═══════════════════════════════════════════════════════════
-- PENGELUARAN - Pakan (tiap bulan, 2-3x)
-- ═══════════════════════════════════════════════════════════
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'expense',
  (SELECT id FROM finance_categories WHERE name = 'Pakan' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (75000 + (RANDOM() * 75000))::int,
  (CURRENT_DATE - INTERVAL '1 month' * n + INTERVAL '1 day' * (RANDOM() * 10)::int)::date,
  'Beli pelet kelinci'
FROM generate_series(0, 11) AS n;

INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'expense',
  (SELECT id FROM finance_categories WHERE name = 'Pakan' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (30000 + (RANDOM() * 40000))::int,
  (CURRENT_DATE - INTERVAL '1 month' * n + INTERVAL '1 day' * 15)::date,
  'Beli sayuran segar'
FROM generate_series(0, 11) AS n;

-- ═══════════════════════════════════════════════════════════
-- PENGELUARAN - Obat & Vaksin (tiap 2 bulan)
-- ═══════════════════════════════════════════════════════════
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'expense',
  (SELECT id FROM finance_categories WHERE name = 'Obat & Vaksin' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (25000 + (RANDOM() * 75000))::int,
  (CURRENT_DATE - INTERVAL '2 month' * n)::date,
  'Vaksin dan vitamin'
FROM generate_series(0, 5) AS n;

-- ═══════════════════════════════════════════════════════════
-- PENGELUARAN - Listrik & Air (tiap bulan)
-- ═══════════════════════════════════════════════════════════
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'expense',
  (SELECT id FROM finance_categories WHERE name = 'Listrik & Air' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (35000 + (RANDOM() * 25000))::int,
  (CURRENT_DATE - INTERVAL '1 month' * n + INTERVAL '1 day' * 5)::date,
  'Tagihan bulan ' || to_char(CURRENT_DATE - INTERVAL '1 month' * n, 'Mon')
FROM generate_series(0, 11) AS n;

-- ═══════════════════════════════════════════════════════════
-- PENGELUARAN - Perawatan Kandang (tiap 3 bulan)
-- ═══════════════════════════════════════════════════════════
INSERT INTO finance_transactions (farm_id, type, category_id, amount, transaction_date, description)
SELECT 
  '1132ae45-d9c6-4859-88e5-8c1ca15415f7',
  'expense',
  (SELECT id FROM finance_categories WHERE name = 'Perawatan Kandang' AND farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7' LIMIT 1),
  (50000 + (RANDOM() * 100000))::int,
  (CURRENT_DATE - INTERVAL '3 month' * n)::date,
  'Perbaikan dan desinfektan'
FROM generate_series(0, 3) AS n;

-- ═══════════════════════════════════════════════════════════
-- VERIFY
-- ═══════════════════════════════════════════════════════════
SELECT 
  type,
  COUNT(*) as jumlah,
  SUM(amount) as total
FROM finance_transactions 
WHERE farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7'
GROUP BY type;
