-- Migration 009: Update Status Check Constraint
-- Allows new breeding status values
-- Date: 2025-12-25

-- Drop the old constraint
ALTER TABLE livestocks DROP CONSTRAINT IF EXISTS livestocks_status_check;

-- Create new constraint with all valid status values
ALTER TABLE livestocks ADD CONSTRAINT livestocks_status_check 
CHECK (status IN (
  -- Female breeding statuses
  'betina_muda',
  'siap_kawin', 
  'bunting',
  'menyusui',
  
  -- Male breeding statuses
  'pejantan_muda',
  'pejantan_aktif',
  
  -- Gender-neutral statuses
  'istirahat',
  'sold',
  'deceased',
  'culled',
  
  -- Legacy value (for backward compatibility)
  'active'
));

-- Update existing 'active' status to appropriate new status
-- Female active -> betina_muda (default for females)
UPDATE livestocks 
SET status = 'betina_muda' 
WHERE status = 'active' AND gender = 'female';

-- Male active -> pejantan_muda (default for males)  
UPDATE livestocks
SET status = 'pejantan_muda'
WHERE status = 'active' AND gender = 'male';
