# DSFarm - UI Design Prompt

> **Objective**: Generate a modern, elegant, minimalist UI design for DSFarm, a rabbit farm management application.

---

## 🎨 Design Requirements

### Visual Style
- **Modern**: Clean lines, generous white space, flat design with subtle shadows
- **Elegant**: Premium feel, sophisticated color palette, refined typography
- **Minimalist**: Focus on essential elements, remove visual clutter, clear hierarchy

### Color Palette Recommendation
| Usage | Color |
|-------|-------|
| Primary | Green (#4CAF50) - represents agriculture/growth |
| Accent | Soft gold or amber for premium feel |
| Female indicator | Pink (#E91E63) |
| Male indicator | Blue (#2196F3) |
| Success | Green |
| Warning | Orange |
| Error | Red |
| Background | Off-white or very light gray |
| Surface | White |

### Typography
- **Font Family**: Inter, Poppins, or SF Pro Display
- **Weights**: 400 (body), 500 (medium), 600 (semibold), 700 (bold)
- **Sizes**: Responsive, 12-16px body, 18-24px headers

### Layout
- **Desktop**: Sidebar navigation (260px) + Content area
- **Mobile**: Hamburger menu + Bottom navigation optional
- **Breakpoint**: 900px for responsive switch

---

## 📱 Application Screens

### 1. Login Screen (`/login`)
**Description**: Authentication page for user login

**Elements**:
- Logo: DSFarm with rabbit icon
- Email input field
- Password input field
- "Login" primary button
- "Register" link
- Google OAuth button (optional)

**Style Notes**:
- Center aligned on large screens
- Full width on mobile
- Subtle gradient or illustration background

---

### 2. Register Screen (`/register`)
**Description**: New user registration

**Elements**:
- Logo
- Name input
- Email input
- Password input
- Confirm password input
- "Register" button
- "Already have account? Login" link

---

### 3. Farm Selector Screen (`/farms`)
**Description**: List of farms owned by user

**Elements**:
- Header: "Peternakan Saya" (My Farms)
- Add Farm FAB button
- Farm cards:
  - Farm name
  - Location
  - Total livestock count
  - Created date
- Empty state with illustration

---

### 4. Dashboard / Overview (`/dashboard/:farmId`)
**Description**: Main dashboard with farm statistics and summary

**Elements**:
- **Header Section**:
  - Farm name
  - Date/time
  - User avatar

- **Hero Card** (Full width):
  - Total asset value (IDR)
  - Monthly trend indicator
  - Value from livestock + offspring

- **Statistics Row** (4 cards):
  | Stat | Icon | Description |
  |------|------|-------------|
  | Total Indukan | 🐰 | Parent livestock count |
  | Total Anakan | 🐣 | Offspring count |
  | Bunting | 🤰 | Pregnant females |
  | Profit/Loss | 💰 | Monthly revenue |

- **Chart Section**:
  - Monthly Financial Trend (Line chart)
  - Income vs Expense comparison
  - 6-month view

---

### 5. Ternak / Livestock List (`/dashboard/:farmId/livestock`)
**Description**: List of all breeding livestock (parents)

**Elements**:
- **Header**: "Ternak" with Add button
- **Filter chips**: All, Betina (Female), Jantan (Male)
- **View toggle**: Card view / Table view

**Livestock Card**:
```
┌─────────────────────────────────┐
│ [Avatar]  CODE - NZW001         │
│           Ras: New Zealand White│
│           Umur: 8bln 15hr       │
│ ♀ Betina  [Status Badge]        │
│           Berat: 3.2 kg         │
└─────────────────────────────────┘
```

**Status Types** (Female):
- `Betina Muda` - Young female (< 4 months)
- `Siap Kawin` - Ready to breed (4+ months)
- `Bunting` - Pregnant
- `Menyusui` - Nursing
- `Istirahat` - Resting

**Status Types** (Male):
- `Pejantan Muda` - Young male
- `Pejantan Aktif` - Active stud

**General Status**:
- `Terjual` (Sold)
- `Mati` (Deceased)
- `Culled`

**Livestock Detail Modal** (Bottom Sheet):
- **Tabs**: Informasi, Pertumbuhan, Kesehatan, Breeding (females only)
- **Tab 1 - Informasi**:
  - Basic info (gender, birth date, age, weight)
  - Acquisition info (source, price, date)
  - Status selector dropdown
  - Silsilah (lineage) popup

- **Tab 2 - Pertumbuhan**:
  - Weight history line chart
  - Add weight record button
  - Weight records table

- **Tab 3 - Kesehatan**:
  - Health records list
  - Add health record button
  - Record type, medication, notes

- **Tab 4 - Breeding** (females only):
  - Breeding history
  - Mating records
  - Birth records

---

### 6. Anakan / Offspring List (`/dashboard/:farmId/offspring`)
**Description**: List of all offspring from breeding

**Elements**:
- Header: "Anakan" with Add and Batch Sell buttons
- Filter chips: Semua, Di Farm, Siap Jual, Terjual
- Statistics row: Total, Di Farm count, Siap Jual count, Terjual count

**Offspring Card**:
```
┌─────────────────────────────────┐
│ [♀/♂]  CODE - ANK-2024-001     │
│        Umur: 45 hari            │
│        Induk: NZW001 x NZW-M02  │
│        [Status Badge]           │
└─────────────────────────────────┘
```

**Status Types**:
- `Di Farm` (infarm) - Still in farm
- `Lepas Sapih` (weaned) - Weaned
- `Siap Jual` (ready_sell) - Auto: age ≥ 90 days
- `Terjual` (sold) - Sold
- `Mati` (deceased) - Deceased
- `Jadi Indukan` (promoted) - Promoted to breeding stock

**Offspring Detail Modal**:
- Basic info (code, gender, birth date, age)
- Parent info (dam code, sire code)
- Weight and notes
- Status change actions
- Lineage tree view

**Batch Sell Feature**:
- Select multiple offspring
- Input buyer name, price per kg, total weight
- Generate sale receipt
- Print/share receipt

---

### 7. Keuangan / Finance (`/dashboard/:farmId/finance`)
**Description**: Financial management with transactions and charts

**Elements**:
- **Filter Section**:
  - Period chips: 7 Hari, 30 Hari, Tahun Ini, Custom
  - Date range picker

- **Summary Cards** (3 columns):
  | Card | Color | Value |
  |------|-------|-------|
  | Income | Green | Total pemasukan |
  | Expense | Red | Total pengeluaran |
  | Profit | Blue/Orange | Net profit/loss |

- **Chart Section**:
  - Monthly trend line chart
  - Income line (green) vs Expense line (red)

- **Transaction Table**:
  ```
  | Tanggal | Kategori | Deskripsi | Jumlah |
  |---------|----------|-----------|--------|
  | 15 Dec  | Penjualan| 5 ekor    | +Rp X  |
  | 12 Dec  | Pakan    | Pellet    | -Rp X  |
  ```

- **Add Transaction FAB**:
  - Type selector: Pemasukan / Pengeluaran
  - Category dropdown
  - Amount input
  - Date picker
  - Description textarea

**Transaction Categories**:
- Pemasukan: Penjualan, Hibah, Lainnya
- Pengeluaran: Pakan, Obat, Peralatan, Utilitas, Lainnya

---

### 8. Inventaris / Inventory (`/dashboard/:farmId/inventory`)
**Description**: Stock management for supplies

**Elements**:
- Header: "Inventaris" with Add button
- Tab view: Pakan (Feed), Obat (Medicine), Peralatan (Equipment)

**Inventory Card**:
```
┌─────────────────────────────────┐
│ [Icon]  Pelet Rabbit Gold       │
│         Stok: 25 kg             │
│         Min: 10 kg              │
│         [Low Stock Warning]     │
└─────────────────────────────────┘
```

**Item Detail**:
- Name, category, unit
- Current stock
- Minimum stock threshold
- Last updated
- Add/Remove stock buttons
- Stock history

---

### 9. Kesehatan / Health (`/dashboard/:farmId/health`)
**Description**: Health records for all livestock

**Elements**:
- Header with Add button
- Filter by livestock
- Health records timeline

**Health Record Card**:
```
┌─────────────────────────────────┐
│ 📅 15 Dec 2024                  │
│ Ternak: NZW001                  │
│ Tipe: Vaksinasi                 │
│ Obat: Ivermectin                │
│ Catatan: Dosis 0.2ml            │
└─────────────────────────────────┘
```

**Record Types**:
- Pemeriksaan (Checkup)
- Vaksinasi (Vaccination)
- Pengobatan (Treatment)
- Pertolongan (First aid)

---

### 10. Pengingat / Reminders (`/dashboard/:farmId/reminders`)
**Description**: Task and reminder management

**Elements**:
- Header with Add button
- Filter: Semua, Aktif, Selesai
- Reminders list sorted by due date

**Reminder Card**:
```
┌─────────────────────────────────┐
│ ⏰ Vaksinasi NZW001             │
│    Due: 20 Dec 2024             │
│    [Recurring icon if repeat]   │
│    [Complete] [Edit] [Delete]   │
└─────────────────────────────────┘
```

**Reminder Types**:
- Breeding related
- Health related
- Feeding schedule
- Custom reminders

---

### 11. Laporan / Reports (`/dashboard/:farmId/reports`)
**Description**: Analytics and exportable reports

**Elements**:
- Export button (PDF/Excel)

**Report Cards**:

1. **Populasi (Population)**:
   - Total livestock
   - Male vs Female breakdown
   - Total offspring by status

2. **Performa Breeding**:
   - Total breeding records
   - Active pregnancies
   - Average litter size

3. **Penjualan (Sales)**:
   - Total sold
   - This month revenue
   - Average price per unit

4. **Keuangan (Finance)**:
   - Total income
   - Total expense
   - Profit/Loss percentage

**Export Options**:
- Laporan Penjualan (PDF)
- Laporan Keuangan (PDF)
- Penjualan (Excel)
- Keuangan (Excel)

---

### 12. Pengaturan / Settings (`/dashboard/:farmId/settings`)
**Description**: Application and farm settings

**Elements**:
- **Data Master Section**:
  - Ras (Breeds management)
  - Kandang (Housing units)
  - Kategori Keuangan (Finance categories)
  - Jenis Pakan (Feed types)

- **Preferences Section**:
  - Theme toggle (Light/Dark)
  - Language selector
  - Notification settings

- **Account Section**:
  - Profile edit
  - Change password
  - Logout

---

### 13. Silsilah / Lineage (`/lineage`)
**Description**: Family tree visualization

**Elements**:
- Interactive tree view
- Current animal at center
- Parents above
- Offspring below (if applicable)
- Click to navigate to detail

---

## 🧩 Common Components

### Sidebar Navigation (Desktop)
```
┌──────────────────────┐
│ 🐰 DSFarm            │
│                      │
│ [User Avatar]        │
│ Username             │
│ Farm Name            │
├──────────────────────┤
│ 📊 Overview          │
│ 🐰 Ternak            │
│ 🐣 Anakan            │
│ 💰 Keuangan          │
│ 📦 Inventaris        │
│ ─────────────────    │
│ ❤️ Kesehatan         │
│ 🔔 Pengingat         │
│ 📈 Laporan           │
├──────────────────────┤
│ ⚙️ Pengaturan        │
│ 🚪 Keluar            │
└──────────────────────┘
```

### Mobile App Bar
```
┌─────────────────────────────────┐
│ ☰  🐰 DSFarm      [Farm Name]  │
└─────────────────────────────────┘
```

### Modal Bottom Sheet Pattern
- Handle bar at top (drag indicator)
- Header with title and close button
- Scrollable content
- Bottom action buttons

### Card Pattern
- Rounded corners (12-16px)
- Subtle shadow or border
- Padding: 16px
- Clear typography hierarchy

### Status Badge Pattern
- Rounded pill shape
- Color coded by status
- Icon + text
- Small size (12-14px font)

### FAB (Floating Action Button)
- Bottom right position
- Primary color
- Plus icon for add actions
- Elevation with shadow

---

## 📐 Responsive Breakpoints

| Screen | Width | Layout |
|--------|-------|--------|
| Mobile | < 600px | Single column, hamburger menu |
| Tablet | 600-900px | Collapsible sidebar |
| Desktop | > 900px | Full sidebar (260px) + content |

---

## 🌓 Theme Support

### Light Theme
- Background: #FAFAFA
- Surface: #FFFFFF
- Primary: #4CAF50
- On Surface: #212121

### Dark Theme
- Background: #121212
- Surface: #1E1E1E
- Primary: #66BB6A
- On Surface: #FFFFFF

---

## 🔄 Animations & Transitions

1. **Page Transitions**: None (instant switch) for dashboard sub-routes
2. **Modal**: Slide up from bottom
3. **Cards**: Subtle hover elevation on desktop
4. **FAB**: Scale on tap
5. **List items**: Fade in on load
6. **Charts**: Animated drawing on load

---

## 💡 UX Guidelines

1. **Empty States**: Always show helpful illustration + CTA
2. **Loading States**: Skeleton loaders, not spinners
3. **Error States**: Clear message + retry action
4. **Success Feedback**: Snackbar with action undo option
5. **Destructive Actions**: Confirmation dialog required
6. **Forms**: Inline validation, clear error messages
7. **Mobile**: Touch targets minimum 44x44px

---

## 📦 Data Models Reference

### Livestock (Indukan/Pejantan)
```
- id, farm_id, housing_id
- code (unique identifier, e.g., "NZW001")
- name (optional nickname)
- gender (male/female)
- breed_id, breed_name
- birth_date, age
- acquisition_type (born/purchased/gifted)
- purchase_price, acquisition_date
- status (see status types above)
- weight, notes
- mother_code, father_code (lineage)
```

### Offspring (Anakan)
```
- id, farm_id, breeding_record_id
- code (e.g., "ANK-2024-001")
- gender (male/female/unknown)
- birth_date, weaning_date
- breed_id, breed_name
- status (infarm/weaned/ready_sell/sold/deceased/promoted)
- weight, sale_price, sale_date
- dam_code, sire_code (parent codes)
```

### Finance Transaction
```
- id, farm_id
- type (income/expense)
- category_id, category_name
- amount
- transaction_date
- description
```

### Inventory Item
```
- id, farm_id
- category (feed/medicine/equipment)
- name, unit
- quantity (current stock)
- min_quantity (low stock threshold)
```

---

**Note**: This prompt is designed for AI image generators or UI design tools. Use this as context when requesting specific screen designs.
