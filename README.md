# Task Reminder App 📋

Aplikasi Flutter lengkap untuk manajemen tugas dengan notifikasi deadline.

## ✨ Fitur

| Fitur | Status |
|-------|--------|
| ✅ Tambah tugas baru | ✔ |
| ✅ Checkbox selesai | ✔ |
| ✅ Hapus tugas | ✔ |
| ✅ Waktu & deadline | ✔ |
| ✅ Notifikasi lokal | ✔ |
| ✅ Deskripsi tugas | ✔ |
| ✅ Status: Todo / On Progress / Done | ✔ |
| ✅ Persistent storage | ✔ |

## 🗂 Struktur Proyek

```
lib/
├── main.dart                         # Entry point + Provider setup
├── models/
│   └── task.dart                     # Model Task + enum TaskStatus
├── services/
│   ├── notification_service.dart     # Local notification (flutter_local_notifications)
│   ├── task_storage_service.dart     # Simpan/load dari SharedPreferences
│   └── task_provider.dart            # State management (ChangeNotifier)
├── screens/
│   ├── home_screen.dart              # Halaman utama dengan TabBar
│   └── task_detail_screen.dart       # Halaman detail tugas
├── widgets/
│   ├── task_card.dart                # Kartu tugas reusable
│   └── add_task_sheet.dart           # Bottom sheet tambah/edit tugas
└── theme/
    └── app_theme.dart                # Tema gelap + warna
```

## 🚀 Cara Menjalankan

### 1. Prasyarat
- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code
- Perangkat Android / emulator (SDK ≥ 21)

### 2. Install Dependensi
```bash
flutter pub get
```

### 3. Jalankan Aplikasi
```bash
flutter run
```

### 4. Build APK
```bash
flutter build apk --release
```
APK tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

## 📦 Dependensi Utama

| Paket | Kegunaan |
|-------|----------|
| `flutter_local_notifications` | Notifikasi lokal & terjadwal |
| `shared_preferences` | Penyimpanan data persisten |
| `provider` | State management |
| `google_fonts` | Tipografi (Plus Jakarta Sans) |
| `intl` | Format tanggal Bahasa Indonesia |
| `uuid` | Generate ID unik untuk tugas |
| `timezone` | Zona waktu untuk notifikasi |

## 🎨 Desain

- **Tema**: Dark mode dengan palet ungu / neon
- **Font**: Plus Jakarta Sans (Google Fonts)
- **Status warna**:
  - 🟣 To Do → Ungu (`#6C63FF`)
  - 🟡 On Progress → Oranye (`#FFB347`)
  - 🟢 Done → Hijau (`#43E97B`)

## 🔔 Cara Kerja Notifikasi

Saat tugas dibuat dengan deadline:
1. Notifikasi dijadwalkan **1 jam sebelum deadline**
2. Notifikasi dibatalkan otomatis jika tugas dihapus
3. Notifikasi diperbarui jika deadline diubah

## 📱 Permission Android

Di `AndroidManifest.xml`:
- `POST_NOTIFICATIONS` — menampilkan notifikasi (Android 13+)
- `SCHEDULE_EXACT_ALARM` — notifikasi tepat waktu
- `RECEIVE_BOOT_COMPLETED` — notifikasi bertahan setelah restart
