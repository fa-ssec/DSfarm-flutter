-- ═══════════════════════════════════════════════════════════
-- DSFARM SUPABASE MIGRATION - Weight Records
-- Run this in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════
-- WEIGHT_RECORDS TABLE (Riwayat Berat Ternak)
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS weight_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  livestock_id UUID NOT NULL REFERENCES livestocks(id) ON DELETE CASCADE,
  weight DECIMAL(8,2) NOT NULL,        -- Berat dalam kg (max 999999.99)
  age_days INTEGER,                     -- Umur dalam hari saat pengukuran
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- Waktu pengukuran
  notes TEXT,                           -- Catatan opsional
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_weight_records_livestock_id ON weight_records(livestock_id);
CREATE INDEX IF NOT EXISTS idx_weight_records_recorded_at ON weight_records(recorded_at);

-- Enable Row Level Security
ALTER TABLE weight_records ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access weight records for their own livestock
CREATE POLICY "Users can manage own weight records" ON weight_records
  FOR ALL USING (
    livestock_id IN (
      SELECT l.id FROM livestocks l 
      JOIN farms f ON l.farm_id = f.id 
      WHERE f.user_id = auth.uid()
    )
  );

-- ═══════════════════════════════════════════════════════════
-- VERIFY
-- ═══════════════════════════════════════════════════════════

SELECT 'weight_records table created successfully' as status;
