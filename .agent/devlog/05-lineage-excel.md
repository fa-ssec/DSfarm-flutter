# DevLog 05 - Lineage Tree & Excel Export

> **Tanggal:** 24 Desember 2024  
> **Fokus:** Visualisasi Silsilah Ternak & Export Laporan ke Excel

---

## 🎓 Yang Dipelajari Hari Ini

### 1. Recursive Data Structure untuk Family Tree
```dart
class LineageNode {
  final String id;
  final String code;
  final LineageNode? dam;  // Mother (recursive)
  final LineageNode? sire; // Father (recursive)
  
  /// Total depth of tree (untuk sizing)
  int get depth {
    int damDepth = dam?.depth ?? 0;
    int sireDepth = sire?.depth ?? 0;
    return 1 + (damDepth > sireDepth ? damDepth : sireDepth);
  }
}
```
**Lesson:** Recursive data structure untuk tree, dengan computed property untuk calculate depth.

---

### 2. CustomPaint untuk Menggambar Lines
```dart
class _ConnectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Horizontal line
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width / 2, size.height / 2);
    
    // Vertical line
    path.moveTo(size.width / 2, 20);
    path.lineTo(size.width / 2, size.height - 20);
    
    canvas.drawPath(path, paint);
  }
}
```
**Lesson:** CustomPaint memungkinkan menggambar custom shapes dengan Canvas API.

---

### 3. Excel Package untuk Generate Spreadsheet
```dart
import 'package:excel/excel.dart';

final excel = Excel.createExcel();
final sheet = excel['Sheet Name'];

// Styling cell
final headerStyle = CellStyle(
  bold: true,
  backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
  fontColorHex: ExcelColor.white,
);

// Set value
sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Title');
sheet.cell(CellIndex.indexByString('A1')).cellStyle = headerStyle;

// Merge cells
sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));

// Set column width
sheet.setColumnWidth(0, 20);

// Encode to bytes
final bytes = excel.encode()!;
```
**Lesson:** Package `excel` untuk generate .xlsx file dengan styling lengkap.

---

### 4. Share Plus untuk Share File
```dart
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// Save to temp file
final tempDir = await getTemporaryDirectory();
final filePath = '${tempDir.path}/report.xlsx';
final file = File(filePath);
await file.writeAsBytes(bytes);

// Share file
await Share.shareXFiles(
  [XFile(filePath)],
  text: 'Report dari DSFarm',
);
```
**Lesson:** `share_plus` + `path_provider` untuk share file ke app lain.

---

### 5. GoRouter Query Parameters
```dart
// Define route
GoRoute(
  path: '/lineage',
  builder: (context, state) {
    final offspringId = state.uri.queryParameters['offspringId'];
    final livestockId = state.uri.queryParameters['livestockId'];
    return LineageScreen(
      offspringId: offspringId,
      livestockId: livestockId,
    );
  },
),

// Navigate with query params
context.push('/lineage?offspringId=${offspring.id}');
```
**Lesson:** Query parameters memungkinkan passing data tanpa route params.

---

### 6. Recursive Widget Building
```dart
Widget _buildTree(BuildContext context, LineageNode node, int generation) {
  if (!node.hasParents) {
    // Base case - leaf node
    return _NodeCard(node: node);
  }

  // Recursive case - node with parents
  return Row(
    children: [
      _NodeCard(node: node),
      CustomPaint(...), // Connection lines
      Column(
        children: [
          _buildTree(context, node.sire!, generation + 1),  // Recursive
          _buildTree(context, node.dam!, generation + 1),   // Recursive
        ],
      ),
    ],
  );
}
```
**Lesson:** Recursive function untuk build tree widget, dengan generation untuk scaling.

---

## 📁 Files Dibuat/Diubah

| File | Aksi | Purpose |
|------|------|---------| 
| `lib/services/lineage_service.dart` | NEW | Fetch & build family tree dari Supabase |
| `lib/services/excel_generator.dart` | NEW | Generate Excel reports |
| `lib/widgets/lineage_tree_widget.dart` | NEW | CustomPaint tree visualization |
| `lib/features/lineage/screens/lineage_screen.dart` | NEW | Screen untuk tampilkan silsilah |
| `lib/app_router.dart` | EDIT | Tambah route /lineage |
| `lib/features/reports/screens/reports_screen.dart` | EDIT | Tambah Excel export options |
| `lib/features/offspring/screens/offspring_list_screen.dart` | EDIT | Tambah tombol "Lihat Silsilah" |
| `pubspec.yaml` | EDIT | Tambah excel, path_provider, share_plus |

---

## 🔗 Dependencies Baru

```yaml
excel: ^4.0.6          # Generate Excel files
path_provider: ^2.1.5  # Access filesystem
share_plus: ^10.1.4    # Share files
```

---

## ✅ Progress

- **Total Features:** 49/77 done (~64%)
- **Fitur Baru:**
  - ✅ Lineage Tree Visualization
  - ✅ Excel Export (Sales & Finance)
  
---

## 📸 Struktur Lineage Tree

```
              ┌── Sire (Pejantan kakek)
      ┌── Sire ┤
      │       └── Dam (Induk kakek)
Anakan ┤
      │       ┌── Sire (Pejantan kakek)
      └── Dam ┤
              └── Dam (Induk nenek)
```

Scroll horizontal untuk lihat generasi lebih lanjut (maks 3 generasi).

---

## ⏭️ Next Steps

1. **Health Reminders** - Auto-reminder vaksinasi per umur
2. **Inbreeding Warning** - Detect breeding antar kerabat dekat
3. **Dashboard Analytics** - Summary charts di dashboard
