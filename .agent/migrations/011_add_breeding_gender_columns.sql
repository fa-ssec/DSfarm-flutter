-- ═══════════════════════════════════════════════════════════
-- DSFARM SUPABASE MIGRATION - BREEDING GENDER BREAKDOWN
-- Run this in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════

-- Add gender breakdown columns for birth
ALTER TABLE breeding_records 
  ADD COLUMN IF NOT EXISTS male_born INTEGER,
  ADD COLUMN IF NOT EXISTS female_born INTEGER;

-- Add gender breakdown columns for weaning
ALTER TABLE breeding_records 
  ADD COLUMN IF NOT EXISTS male_weaned INTEGER,
  ADD COLUMN IF NOT EXISTS female_weaned INTEGER;

-- ═══════════════════════════════════════════════════════════
-- VERIFY
-- ═══════════════════════════════════════════════════════════

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'breeding_records' 
AND column_name IN ('male_born', 'female_born', 'male_weaned', 'female_weaned');
