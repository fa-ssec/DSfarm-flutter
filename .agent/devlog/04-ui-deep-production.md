# DevLog 04 - UI Deep & Production

> **Tanggal:** 21 Desember 2025  
> **Fokus:** Kandang Deep, PDF Export, Production Deploy

---

## 🎓 Yang Dipelajari Hari Ini

### 1. Batch Create Pattern
```dart
// Loop untuk create batch dengan sequence
for (int i = 0; i < count; i++) {
  final num = startNum + i;
  final code = '${blockCode}-${num.toString().padLeft(2, '0')}';
  await repository.create(code: code, ...);
}
```
**Lesson:** Gunakan `padLeft` untuk format angka dengan leading zero.

---

### 2. Input Formatter Custom
```dart
class _UpperCaseLettersFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(oldValue, newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), ''),
      selection: newValue.selection,
    );
  }
}
```
**Lesson:** `TextInputFormatter` untuk validasi real-time input.

---

### 3. Auto-Load State dari URL
```dart
// Di Dashboard, check if farm null lalu load dari URL
if (farm == null) {
  final farmAsync = ref.watch(farmByIdProvider(farmId));
  return farmAsync.when(
    loading: () => LoadingWidget(),
    data: (loadedFarm) {
      // Set state via post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentFarmProvider.notifier).state = loadedFarm;
      });
      return LoadingWidget();
    },
  );
}
```
**Lesson:** Gunakan `addPostFrameCallback` untuk update state saat build.

---

### 4. Color-Coded UI Pattern
```dart
Color _getLevelColor() {
  final level = housing.level?.toUpperCase() ?? '';
  if (level.startsWith('A')) return Colors.blue;
  if (level.startsWith('T')) return Colors.orange;
  if (level.startsWith('B')) return Colors.green;
  return Colors.grey;
}
```
**Lesson:** Pattern sederhana untuk color-coding berdasarkan data.

---

### 5. PDF Generation dengan `pdf` Package
```dart
import 'package:pdf/widgets.dart' as pw;

final pdf = pw.Document();
pdf.addPage(pw.MultiPage(
  header: (context) => _buildHeader(),
  build: (context) => [
    pw.Text('Title'),
    pw.Table(...),
  ],
));

await Printing.layoutPdf(onLayout: (_) => pdf.save());
```
**Lesson:** `pw.` prefix karena ada konflik dengan Flutter widgets.

---

### 6. Vercel Deploy Flutter Web
```bash
# Build Flutter web
flutter build web --release

# Deploy dengan npx (tanpa install global)
cd build/web && npx vercel --prod
```
**Lesson:** Gunakan `npx` jika `npm install -g` permission denied.

---

## 📁 Files Dibuat/Diubah

| File | Aksi | Purpose |
|------|------|---------|
| `batch_sell_screen.dart` | NEW | Multi-select jual anakan |
| `pdf_generator.dart` | NEW | Service untuk generate PDF |
| `common_widgets.dart` | NEW | Shimmer loading, empty state |
| `housing_list_screen.dart` | EDIT | Color-coded cards |
| `create_housing_screen.dart` | EDIT | Level input dengan max length |

---

## 🔗 Commits Hari Ini

```
4537581 feat: color-coded housing by level/location
f4190c2 feat: add common UI widgets and production build
73c1c19 feat: batch sell offspring and PDF export reports
d6578af fix: auto-load farm from URL on dashboard reload
64fd451 fix: block and lokasi inputs accept uppercase letters only
01e7b3e feat: unified kandang form with batch create and compact grid view
```

---

## ✅ Progress

- **Total Features:** 32/45+ done
- **Production:** https://dsfarm-kelinci.vercel.app
