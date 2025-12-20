# 06 - Block & Position System

## Konsep Hierarki Kandang

```
Farm
└── Block (Gedung/Area)
    └── Housing (Kandang dengan Position)
```

## Model Block

```dart
class Block {
  final String id;
  final String farmId;
  final String code;      // "BLOCK-A"
  final String? name;     // "Gedung Utama"
  final String? type;     // "indukan", "anakan", "karantina"
}
```

## Model Housing dengan Block

```dart
class Housing {
  final String? blockId;  // Reference ke block
  final String? position; // Posisi dalam block: "A-01-ATAS"
  final String code;      // Legacy code
}
```

## Auto-Generate Position

```dart
// Repository method
Future<String> getNextPosition(String blockId, String blockCode) async {
  // Query existing positions in block
  // Find max number
  // Return next: BLOCK-CODE-XX
}
```

## Format Position dengan Tingkat

Untuk kandang bertingkat (atas/tengah/bawah):

```
BLOCK-A-01-A  → Kolom 1, Tingkat Atas
BLOCK-A-01-T  → Kolom 1, Tingkat Tengah  
BLOCK-A-01-B  → Kolom 1, Tingkat Bawah
BLOCK-A-02-A  → Kolom 2, Tingkat Atas
```

## Batch Create Kandang

```dart
// Create multiple housings at once
Future<List<Housing>> batchCreate({
  required String blockId,
  required int columns,      // Jumlah kolom
  required int levels,       // Jumlah tingkat (1-3)
  required int capacity,
  required HousingType type,
}) async {
  final positions = <String>[];
  for (int col = 1; col <= columns; col++) {
    for (int lvl = 0; lvl < levels; lvl++) {
      final levelCode = ['A', 'T', 'B'][lvl];
      positions.add('$blockCode-${col.padLeft(2)}-$levelCode');
    }
  }
  // Insert all
}
```

## Database Schema

```sql
-- Blocks table
CREATE TABLE blocks (
  id UUID PRIMARY KEY,
  farm_id UUID REFERENCES farms(id),
  code VARCHAR(20) NOT NULL,
  name VARCHAR(100),
  type VARCHAR(20), -- 'indukan', 'anakan', 'karantina'
  UNIQUE(farm_id, code)
);

-- Housings with block reference
ALTER TABLE housings 
  ADD COLUMN block_id UUID REFERENCES blocks(id),
  ADD COLUMN position VARCHAR(20);
```

## Keuntungan System Ini

1. **Organisasi fisik** - Sesuai layout fisik kandang
2. **Pencarian cepat** - Filter by block
3. **Scalable** - Mudah tambah block baru
4. **Fleksibel** - Position format bisa custom
