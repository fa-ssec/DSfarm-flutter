-- Migration 008: Add Parent Tracking to Livestocks
-- Adds mother_id and father_id columns for lineage tracking and inbreeding detection
-- Date: 2025-12-25

-- Add mother_id column with foreign key to self
ALTER TABLE livestocks 
ADD COLUMN IF NOT EXISTS mother_id UUID REFERENCES livestocks(id) ON DELETE SET NULL;

-- Add father_id column with foreign key to self
ALTER TABLE livestocks 
ADD COLUMN IF NOT EXISTS father_id UUID REFERENCES livestocks(id) ON DELETE SET NULL;

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_livestocks_mother_id ON livestocks(mother_id);
CREATE INDEX IF NOT EXISTS idx_livestocks_father_id ON livestocks(father_id);

-- Comment for documentation
COMMENT ON COLUMN livestocks.mother_id IS 'Reference to mother livestock for lineage tracking';
COMMENT ON COLUMN livestocks.father_id IS 'Reference to father livestock for lineage tracking';
