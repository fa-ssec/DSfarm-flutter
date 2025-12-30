-- ═══════════════════════════════════════════════════════════
-- DSFARM - Update Finance Categories
-- Run this in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════

-- Delete existing categories (optional - only if you want fresh start)
-- DELETE FROM finance_categories WHERE farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7';

-- ═══════════════════════════════════════════════════════════
-- PEMASUKAN (Income) Categories
-- ═══════════════════════════════════════════════════════════
INSERT INTO finance_categories (farm_id, name, type, icon, is_system) VALUES
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Penjualan Anakan', 'income', '🐰', true),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Penjualan Indukan', 'income', '🐇', true),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Penjualan Kotoran', 'income', '💩', false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Pemasukan Lainnya', 'income', '💰', false)
ON CONFLICT DO NOTHING;

-- ═══════════════════════════════════════════════════════════
-- PENGELUARAN (Expense) Categories
-- ═══════════════════════════════════════════════════════════
INSERT INTO finance_categories (farm_id, name, type, icon, is_system) VALUES
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Pakan', 'expense', '🌾', true),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Obat & Vaksin', 'expense', '💊', true),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Perawatan Kandang', 'expense', '🏠', false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Listrik & Air', 'expense', '💡', false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Pembelian Indukan', 'expense', '🛒', false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Peralatan', 'expense', '🛠️', false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Transportasi', 'expense', '🚚', false),
  ('1132ae45-d9c6-4859-88e5-8c1ca15415f7', 'Pengeluaran Lainnya', 'expense', '💰', false)
ON CONFLICT DO NOTHING;

-- ═══════════════════════════════════════════════════════════
-- VERIFY
-- ═══════════════════════════════════════════════════════════
SELECT name, type, icon FROM finance_categories 
WHERE farm_id = '1132ae45-d9c6-4859-88e5-8c1ca15415f7'
ORDER BY type, name;
