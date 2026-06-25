# Task Reminder App 📋

Aplikasi Flutter lengkap untuk manajemen tugas dengan notifikasi deadline.

## ✨ Fitur

| Fitur | Deskripsi / Status |
|-------|--------------------|
| 🔐 **Autentikasi Supabase** | Login dan Daftar via Email/Password serta integrasi Login Google. |
| 👤 **Profil Pengguna** | Melihat detail profil, update Nama Lengkap, serta kustomisasi avatar (pilihan emoji & warna latar). |
| 📋 **Manajemen Tugas** | Tambah tugas, ubah status (To Do, On Progress, Done), deskripsi, dan hapus tugas. |
| 🔔 **Notifikasi Deadline** | Pengingat otomatis terjadwal yang memicu notifikasi lokal 1 jam sebelum deadline tugas. |
| 🗑️ **Hapus Akun Permanen** | Menghapus seluruh data tugas, jadwal notifikasi, dan data autentikasi secara permanen dari Supabase. |
| 🎨 **UI Gelap Premium** | Antarmuka modern (Dark Theme) dengan animasi halus dari `flutter_animate` dan font Plus Jakarta Sans. |
| 💾 **Sinkronisasi Cloud** | Data tersinkronisasi secara real-time dengan Supabase Backend. |

## 🗂 Struktur Proyek

```
lib/
├── main.dart                         # Entry point + Provider setup + Auth wrapper
├── models/
│   └── task.dart                     # Model Task + enum TaskStatus
├── services/
│   ├── auth_service.dart             # Layanan autentikasi Google & Supabase
│   ├── notification_service.dart     # Local notification (flutter_local_notifications)
│   ├── task_storage_service.dart     # Simpan/load cadangan lokal dari SharedPreferences
│   └── task_provider.dart            # State management tugas (ChangeNotifier)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # Layar masuk akun (Email / Google)
│   │   └── register_screen.dart      # Layar daftar akun baru (Nama, Email, Password)
│   ├── settings/
│   │   ├── delete_account_screen.dart # Konfirmasi hapus akun permanen
│   │   └── profile_screen.dart       # Pengaturan profil, nama lengkap, & kustomisasi avatar
│   ├── home_screen.dart              # Halaman utama dengan sapaan personal & tab tugas
│   ├── privacy_policy_screen.dart    # Kebijakan privasi aplikasi
│   └── task_detail_screen.dart       # Halaman detail tugas
├── widgets/
│   ├── task_card.dart                # Kartu tugas reusable
│   ├── add_task_sheet.dart           # Bottom sheet tambah/edit tugas
│   └── google_sign_in_button.dart    # Tombol masuk dengan Google
└── theme/
    └── app_theme.dart                # Tema gelap + warna
```

## 🚀 Cara Menjalankan

### 1. Prasyarat
- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code
- Perangkat Android / emulator (SDK ≥ 21)
- Kredensial akun Supabase terkonfigurasi di file `.env`

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
| `supabase_flutter` | SDK integrasi database & autentikasi cloud Supabase |
| `google_sign_in` | Otentikasi pihak ketiga menggunakan akun Google |
| `flutter_local_notifications` | Notifikasi lokal & terjadwal |
| `shared_preferences` | Penyimpanan data persisten cadangan secara lokal |
| `provider` | State management |
| `flutter_animate` | Menambahkan animasi transisi UI yang halus |
| `google_fonts` | Tipografi premium (Plus Jakarta Sans) |
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
