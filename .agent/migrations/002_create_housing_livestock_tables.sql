-- ═══════════════════════════════════════════════════════════
-- DSFARM SUPABASE MIGRATION - WEEK 3
-- Run this in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════
-- BREEDS TABLE (Master data per farm)
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS breeds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(farm_id, code)
);

CREATE INDEX IF NOT EXISTS idx_breeds_farm_id ON breeds(farm_id);
ALTER TABLE breeds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own breeds" ON breeds
  FOR ALL USING (
    farm_id IN (SELECT id FROM farms WHERE user_id = auth.uid())
  );

-- ═══════════════════════════════════════════════════════════
-- HOUSINGS TABLE (Kandang)
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS housings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  name TEXT,
  block TEXT,
  capacity INTEGER DEFAULT 1,
  housing_type TEXT DEFAULT 'individual',
  status TEXT DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  
  CONSTRAINT housings_type_check CHECK (
    housing_type IN ('individual', 'colony', 'pond')
  ),
  CONSTRAINT housings_status_check CHECK (
    status IN ('active', 'maintenance', 'inactive')
  ),
  UNIQUE(farm_id, code)
);

CREATE INDEX IF NOT EXISTS idx_housings_farm_id ON housings(farm_id);
CREATE INDEX IF NOT EXISTS idx_housings_block ON housings(block);
ALTER TABLE housings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own housings" ON housings
  FOR ALL USING (
    farm_id IN (SELECT id FROM farms WHERE user_id = auth.uid())
  );

-- ═══════════════════════════════════════════════════════════
-- LIVESTOCKS TABLE (Indukan/Pejantan)
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS livestocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  housing_id UUID REFERENCES housings(id) ON DELETE SET NULL,
  breed_id UUID REFERENCES breeds(id) ON DELETE SET NULL,
  code TEXT NOT NULL,
  name TEXT,
  gender TEXT NOT NULL,
  birth_date DATE,
  acquisition_date DATE,
  acquisition_type TEXT DEFAULT 'purchased',
  purchase_price DECIMAL(12,2),
  status TEXT DEFAULT 'active',
  generation INTEGER DEFAULT 1,
  weight DECIMAL(8,2),
  notes TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  
  CONSTRAINT livestocks_gender_check CHECK (
    gender IN ('male', 'female')
  ),
  CONSTRAINT livestocks_acquisition_check CHECK (
    acquisition_type IN ('born', 'purchased', 'gifted')
  ),
  CONSTRAINT livestocks_status_check CHECK (
    status IN ('active', 'sold', 'deceased', 'culled')
  ),
  UNIQUE(farm_id, code)
);

CREATE INDEX IF NOT EXISTS idx_livestocks_farm_id ON livestocks(farm_id);
CREATE INDEX IF NOT EXISTS idx_livestocks_housing_id ON livestocks(housing_id);
CREATE INDEX IF NOT EXISTS idx_livestocks_gender ON livestocks(gender);
CREATE INDEX IF NOT EXISTS idx_livestocks_status ON livestocks(status);
ALTER TABLE livestocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own livestocks" ON livestocks
  FOR ALL USING (
    farm_id IN (SELECT id FROM farms WHERE user_id = auth.uid())
  );

-- ═══════════════════════════════════════════════════════════
-- VERIFY
-- ═══════════════════════════════════════════════════════════

SELECT 'Tables created successfully' as status;
