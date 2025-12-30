-- ═══════════════════════════════════════════════════════════
-- DSFARM SUPABASE MIGRATION - Add offspring_id to weight_records
-- Run this in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════

-- Make livestock_id nullable (optional)
ALTER TABLE weight_records 
  ALTER COLUMN livestock_id DROP NOT NULL;

-- Add offspring_id column
ALTER TABLE weight_records 
  ADD COLUMN IF NOT EXISTS offspring_id UUID REFERENCES offsprings(id) ON DELETE CASCADE;

-- Create index for offspring_id
CREATE INDEX IF NOT EXISTS idx_weight_records_offspring_id ON weight_records(offspring_id);

-- Add check constraint: must have either livestock_id or offspring_id
ALTER TABLE weight_records 
  ADD CONSTRAINT weight_records_entity_check 
  CHECK (livestock_id IS NOT NULL OR offspring_id IS NOT NULL);

-- Update RLS Policy to include offsprings
DROP POLICY IF EXISTS "Users can manage own weight records" ON weight_records;

CREATE POLICY "Users can manage own weight records" ON weight_records
  FOR ALL USING (
    livestock_id IN (
      SELECT l.id FROM livestocks l 
      JOIN farms f ON l.farm_id = f.id 
      WHERE f.user_id = auth.uid()
    )
    OR
    offspring_id IN (
      SELECT o.id FROM offsprings o 
      JOIN farms f ON o.farm_id = f.id 
      WHERE f.user_id = auth.uid()
    )
  );

-- ═══════════════════════════════════════════════════════════
-- VERIFY
-- ═══════════════════════════════════════════════════════════

SELECT 'offspring_id added to weight_records successfully' as status;
