-- ═══════════════════════════════════════════════════════════
-- DSFARM SUPABASE MIGRATION - WEEK 4
-- Run this in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════
-- BREEDING RECORDS TABLE
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS breeding_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  dam_id UUID NOT NULL REFERENCES livestocks(id) ON DELETE CASCADE,
  sire_id UUID REFERENCES livestocks(id) ON DELETE SET NULL,
  mating_date DATE NOT NULL,
  palpation_date DATE,
  is_palpation_positive BOOLEAN,
  expected_birth_date DATE,
  actual_birth_date DATE,
  birth_count INTEGER,
  alive_count INTEGER,
  dead_count INTEGER,
  weaning_date DATE,
  weaned_count INTEGER,
  status TEXT DEFAULT 'mated',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  
  CONSTRAINT breeding_status_check CHECK (
    status IN ('mated', 'palpated', 'pregnant', 'birthed', 'weaned', 'failed')
  )
);

CREATE INDEX IF NOT EXISTS idx_breeding_farm_id ON breeding_records(farm_id);
CREATE INDEX IF NOT EXISTS idx_breeding_dam_id ON breeding_records(dam_id);
CREATE INDEX IF NOT EXISTS idx_breeding_status ON breeding_records(status);
ALTER TABLE breeding_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own breeding records" ON breeding_records
  FOR ALL USING (
    farm_id IN (SELECT id FROM farms WHERE user_id = auth.uid())
  );

-- ═══════════════════════════════════════════════════════════
-- OFFSPRINGS TABLE (Anakan)
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS offsprings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  breeding_record_id UUID REFERENCES breeding_records(id) ON DELETE SET NULL,
  housing_id UUID REFERENCES housings(id) ON DELETE SET NULL,
  breed_id UUID REFERENCES breeds(id) ON DELETE SET NULL,
  code TEXT NOT NULL,
  name TEXT,
  gender TEXT NOT NULL,
  birth_date DATE NOT NULL,
  weaning_date DATE,
  status TEXT DEFAULT 'infarm',
  weight DECIMAL(8,2),
  sale_price DECIMAL(12,2),
  sale_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  
  CONSTRAINT offspring_gender_check CHECK (
    gender IN ('male', 'female')
  ),
  CONSTRAINT offspring_status_check CHECK (
    status IN ('infarm', 'weaned', 'ready_sell', 'sold', 'deceased', 'promoted')
  ),
  UNIQUE(farm_id, code)
);

CREATE INDEX IF NOT EXISTS idx_offspring_farm_id ON offsprings(farm_id);
CREATE INDEX IF NOT EXISTS idx_offspring_breeding_id ON offsprings(breeding_record_id);
CREATE INDEX IF NOT EXISTS idx_offspring_status ON offsprings(status);
CREATE INDEX IF NOT EXISTS idx_offspring_birth_date ON offsprings(birth_date);
ALTER TABLE offsprings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own offsprings" ON offsprings
  FOR ALL USING (
    farm_id IN (SELECT id FROM farms WHERE user_id = auth.uid())
  );

-- ═══════════════════════════════════════════════════════════
-- VERIFY
-- ═══════════════════════════════════════════════════════════

SELECT 'Tables created successfully' as status;
