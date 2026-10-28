# 🪙 ARTOKU V2

Aplikasi pencatatan keuangan pribadi offline-first modern berbasis Flutter. Dirancang dengan desain elegan bertema Emerald & Mint, mendukung manajemen multi-dompet, pelacakan anggaran, dan statistik arus kas real-time.

---

## ✨ Fitur Utama

- **Dashboard Kekayaan & Privasi**:
  - Tampilan Total Saldo dengan toggle privasi sembunyikan/tampilkan saldo (`••••••••`).
  - Ringkasan arus kas bulanan (Pemasukan vs Pengeluaran).
  - Akses cepat: *Catat*, *+ Dompet*, *Transfer*, dan *Anggaran*.
- **Manajemen Multi-Dompet**:
  - Mendukung tipe dompet: *Tunai*, *Bank*, *E-Wallet*, dan *Tabungan*.
  - Dukungan CRUD lengkap: Tambah, Ubah, Hapus, dan Riwayat transaksi khusus dompet.
  - Kartu dompet bergaya kartu bank warna-warni.
- **Pencatatan Transaksi Fleksibel**:
  - Catat *Pengeluaran*, *Pemasukan*, dan *Transfer* antar-dompet.
  - Pemilihan tanggal kustom (*Date Picker*).
  - Format mata uang Rupiah otomatis (*live thousand separator*) dan chip nominal cepat.
- **Riwayat & Pencarian Transaksi**:
  - Pencarian instan berdasarkan catatan, kategori, atau nama dompet.
  - Filter chip (*Semua, Pengeluaran, Pemasukan, Transfer*).
  - Pengelompokan tanggal cerdas (*Hari ini, Kemarin, dsb.*).
  - Swipe-to-delete dengan tombol *Batalkan (Undo)*.
- **Batas Anggaran (*Budgeting*)**:
  - Atur batas pengeluaran bulanan (Semua pengeluaran atau per kategori).
  - Indikator progres visual dengan status adaptif (Aman, Peringatan, Melebihi kuota).
- **Statistik & Analisis Keuangan**:
  - Navigator periode bulan (`< Bulan Tahun >`).
  - Ringkasan arus kas (Surplus / Defisit).
  - Rincian pengeluaran per kategori dengan persentase dan bar visual proporsional.
  - Sebaran alokasi dana di setiap dompet aktif.
- **Offline-First & Aman**:
  - Data tersimpan lokal di perangkat menggunakan `shared_preferences`. Tidak memerlukan koneksi internet.

---

## 🚀 Memulai

### Prasyarat
- Flutter SDK (3.27+)
- Dart SDK (3.6+)

### Menjalankan Aplikasi
```bash
# Clone repositori
git clone https://github.com/Wildans29/artoku_v2.git
cd artoku_v2

# Unduh dependensi
flutter pub get

# Jalankan di Google Chrome
flutter run -d chrome

# Jalankan sebagai aplikasi Windows Desktop
flutter run -d windows
```

### Membangun File APK (Android)
```bash
flutter build apk --debug
```

---

## 🛠️ Tech Stack
- **Framework**: Flutter & Dart (Material 3)
- **State Management**: `ChangeNotifier` (Native Flutter)
- **Local Storage**: `shared_preferences`
- **Formatting**: `intl`
