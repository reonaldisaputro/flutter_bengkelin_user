# Dokumentasi Forgot Password Feature

## Overview

Fitur Forgot Password telah diimplementasikan sesuai dengan dokumentasi API yang diberikan. Sistem ini terdiri dari 3 tahap:

1. **Send OTP** - Mengirim kode OTP ke email user
2. **Verify OTP** - Memverifikasi kode OTP yang diterima
3. **Reset Password** - Mereset password dengan password baru

## Files Created/Modified

### 1. Model Files

- `lib/model/forgot_password_model.dart` - Model untuk request dan response forgot password

### 2. API Endpoints (Modified)

- `lib/config/endpoint.dart` - Ditambahkan 3 endpoint baru:
  - `/api/user/forgot-password/send-otp`
  - `/api/user/forgot-password/verify-otp`
  - `/api/user/forgot-password/reset-password`

### 3. ViewModel (Modified)

- `lib/viewmodel/auth_viewmodel.dart` - Ditambahkan 3 method baru:
  - `sendOtp(String email)`
  - `verifyOtp(String email, String otp)`
  - `resetPassword(String email, String password, String passwordConfirmation)`

### 4. UI Pages

- `lib/views/forgot_password_send_otp_page.dart` - Halaman input email untuk mengirim OTP
- `lib/views/forgot_password_verify_otp_page.dart` - Halaman input OTP dan verifikasi
- `lib/views/forgot_password_reset_password_page.dart` - Halaman reset password
- `lib/views/login_page.dart` - Ditambahkan tombol "Lupa Kata Sandi?"

## Flow Penggunaan

### 1. User mengklik "Lupa Kata Sandi?" di halaman login

- Akan membuka `ForgotPasswordSendOtpPage`

### 2. Di halaman Send OTP

- User memasukkan email
- Validasi format email
- Kirim OTP ke email via API `POST /api/user/forgot-password/send-otp`
- Jika berhasil, navigate ke halaman Verify OTP

### 3. Di halaman Verify OTP

- User memasukkan 6 digit kode OTP
- Auto-focus ke field berikutnya setelah input
- Countdown timer 10 menit (600 detik)
- Tombol "Kirim Ulang" muncul setelah countdown selesai
- Verifikasi OTP via API `POST /api/user/forgot-password/verify-otp`
- Jika berhasil, navigate ke halaman Reset Password

### 4. Di halaman Reset Password

- User memasukkan password baru dan konfirmasi
- Validasi minimum 8 karakter
- Validasi password dan konfirmasi harus sama
- Reset password via API `POST /api/user/forgot-password/reset-password`
- Jika berhasil, tampil dialog sukses dan navigate ke login

## Features Implemented

### Security Features

- Email validation dengan regex
- OTP expire dalam 10 menit
- Password minimum 8 karakter
- Password confirmation validation

### UI/UX Features

- Loading indicators untuk semua API calls
- Toast messages untuk feedback user
- Auto-focus antar OTP input fields
- Countdown timer dengan format MM:SS
- Success dialog dengan navigasi otomatis
- Consistent design dengan app theme (Color: #4A6B6B)

### Error Handling

- Email tidak terdaftar (404)
- OTP tidak valid atau expired (400)
- OTP belum diverifikasi saat reset password (400)
- Network errors dengan pesan user-friendly
- Form validation errors

## API Integration

### 1. Send OTP Request

```json
{
  "email": "user@example.com"
}
```

### 2. Verify OTP Request

```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

### 3. Reset Password Request

```json
{
  "email": "user@example.com",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

## How to Use

1. Pastikan backend API sudah running dengan endpoint sesuai dokumentasi
2. Run aplikasi Flutter
3. Di halaman login, klik "Lupa Kata Sandi?"
4. Ikuti flow 3 tahap seperti dijelaskan di atas

## Notes

- Semua response API menggunakan format standard dengan meta dan data
- Error handling menggunakan response.success untuk cek status
- UI menggunakan color scheme yang konsisten dengan aplikasi (#4A6B6B)
- Toast menggunakan function showToast yang sudah ada di aplikasi
