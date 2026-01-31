# Radius Selector untuk Bengkel Terdekat - Dokumentasi

## Overview

Telah menambahkan fitur radius selector untuk pencarian bengkel terdekat di Home Page. User sekarang dapat memilih radius pencarian dari 5km, 10km, 20km, hingga 50km.

## Features yang Ditambahkan

### 1. UI Components

- **FilterChip dengan Radius Options**: Menampilkan pilihan radius (5km, 10km, 20km, 50km)
- **Icon Lokasi**: Menambahkan visual indicator untuk section radius
- **Visual Feedback**: Chip yang dipilih akan memiliki styling berbeda (warna accent, border, elevation)

### 2. User Experience

- **Auto Refresh**: Ketika user memilih radius baru, data bengkel terdekat otomatis refresh
- **Toast Notification**: Memberikan feedback kepada user bahwa sedang mencari bengkel dengan radius yang dipilih
- **Loading State**: Menampilkan loading indicator saat data sedang di-fetch

### 3. Technical Implementation

- **State Management**: Menggunakan `_selectedRadius` untuk track radius yang dipilih
- **API Integration**: Parameter radius dikirim ke API backend melalui `BengkelViewmodel().bengkelNearby()`
- **Error Handling**: Tetap menggunakan error handling yang sudah ada

## Code Changes

### Variables yang Sudah Ada (tidak perlu ditambah)

```dart
final List<int> _radiusOptions = [5, 10, 20, 50];
int _selectedRadius = 10;
```

### UI Component yang Ditambahkan

```dart
// Radius selector dengan icon dan label
Container(
  height: 45,
  padding: const EdgeInsets.only(left: 16.0),
  child: Row(
    children: [
      Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
      Text('Radius:', style: TextStyle(...)),
      Expanded(
        child: ListView.builder(
          // FilterChip untuk setiap radius option
        ),
      ),
    ],
  ),
),
```

### Method yang Sudah Ada (sudah support radius)

```dart
Future<void> getBengkelNearby() async {
  // Method ini sudah menggunakan _selectedRadius
  final value = await BengkelViewmodel().bengkelNearby(
    lat: position.latitude,
    long: position.longitude,
    radius: _selectedRadius, // ✅ Sudah support radius
  );
}
```

## Design Specifications

### Visual Design

- **Default Radius**: 10km (sesuai backend default)
- **Color Scheme**: Menggunakan `Color(0xFF4A6B6B)` untuk consistency dengan app theme
- **Typography**: Font size 13px untuk chip labels, 14px untuk "Radius:" label
- **Spacing**: Proper padding dan margin untuk visual hierarchy

### Interactive Design

- **Selected State**:
  - Background color dengan opacity 0.2
  - Border dan checkmark dengan accent color
  - Font weight 600
  - Elevation 2

- **Unselected State**:
  - Light gray background
  - Gray border
  - Normal font weight
  - No elevation

## Backend Integration

Fitur ini terintegrasi dengan endpoint yang sudah ada:

```
GET /api/bengkel/nearby
Parameters:
- latitude (required)
- longitude (required)
- radius (optional, default: 10)
```

## How It Works

1. User melihat section "Bengkel Terdekat" dengan chip selector di atasnya
2. Default radius adalah 10km (chip 10km ter-select)
3. User dapat tap chip radius lain (5km, 20km, 50km)
4. Toast notification muncul "Mencari bengkel dalam radius {X} km..."
5. Loading indicator tampil di area list bengkel
6. API dipanggil dengan parameter radius baru
7. List bengkel ter-update sesuai radius yang dipilih

## Notes

- Radius selector responsive dan scrollable horizontal
- Toast duration 2 detik untuk feedback yang tidak mengganggu
- Error handling tetap menggunakan pattern yang sudah ada
- UI consistency dengan design system aplikasi
