# ✨ Postie — Rencana Pengembangan Fitur Selanjutnya

Berdasarkan MVP saat ini dan keunggulannya (native, ringan, performa tinggi), berikut adalah rekomendasi fitur prioritas untuk meningkatkan kemampuan dan pengalaman pengguna Postie.

---

## ✅ Refactoring & Improvements (Selesai)

### 1. HomeViewModel Refactoring
-   [x] **Mengapa:** HomeViewModel adalah class yang paling gemuk dengan fungsi dan state untuk hampir semua view dan feature. Perlu restrukturisasi untuk maintainability.
-   [x] **Implementasi:**
    -   [x] Reorganisasi dengan extension-based structure berdasarkan fitur
    -   [x] Kategori: Request Execution, Download Management, History, Collections, Environment, Response Actions, UI Helpers
    -   [x] Dokumentasi arsitektur di `HomeViewModel-Architecture.md`
    -   [x] Build verification: ✅ SUCCESS

### 2. Onboarding Documentation
-   [x] **Mengapa:** Fitur onboarding sudah diimplementasikan tapi belum terdokumentasi di README
-   [x] **Implementasi:**
    -   [x] Tambah ke section "Developer Experience" di README
    -   [x] Tambah highlight fitur #6 dengan detail 4-slide onboarding flow
    -   [x] Dokumentasi cara akses ulang dari toolbar

---


## 🚀 Fitur Kritis (Dukungan MVP & Dampak Langsung)

Fitur-fitur ini penting untuk melengkapi fungsionalitas yang ada, meningkatkan alur kerja inti, dan memenuhi ekspektasi dasar pengguna terhadap klien API modern.

### 1. Mekanisme Pembatalan Request/Download

-   [*] **Mengapa:** UI untuk pembatalan download sudah ada, tetapi logika dasar untuk menghubungkannya ke `Task.cancel()` di `HomeViewModel` masih hilang. Memberikan kontrol kepada pengguna untuk menghentikan request yang lambat, salah, atau tidak lagi diperlukan adalah fundamental untuk pengalaman pengguna yang lancar.
-   [*] **Implementasi:**
    -   [*] Tambahkan metode `cancelRequest()` dan `cancelDownload()` di `HomeViewModel.swift` yang memanggil `currentRequestTask?.cancel()` dan `currentDownloadTask?.cancel()` masing-masing.
    -   [*] Hubungkan metode-metode ini ke tombol "Cancel" di `HomeView.swift` (khususnya `DownloadProgressView` dan berpotensi tombol "Send" utama selama request aktif).

### 2. Riwayat Request (Request History)

-   [*] **Mengapa:** Meskipun preset berbasis file menawarkan portabilitas, riwayat singkat request yang baru saja dieksekusi adalah fitur standar dan sangat dihargai di klien API. Ini secara signifikan meningkatkan produktivitas developer dengan memungkinkan eksekusi ulang atau modifikasi yang mudah dari panggilan terakhir.
-   [*] **Implementasi:**
    -   [*] Terapkan mekanisme untuk menyimpan request yang berhasil terakhir (misalnya, 20-50 request unik terakhir, mungkin versi sederhana dari `RequestPreset`) di `UserDefaults` atau file JSON ringan.
    -   [*] Buat komponen UI baru (misalnya, tab atau popover) untuk menampilkan dan berinteraksi dengan riwayat ini.

### 3. Manajemen Environment & Variabel

-   [*] **Mengapa:** Developer jarang bekerja dengan satu URL statis. Kemampuan untuk mendefinisikan dan beralih antara environment (development, staging, production) dan menggunakan variabel (misalnya, `{{baseUrl}}`, `{{authToken}}`) adalah landasan alur kerja pengujian API modern. Fitur ini secara drastis mengurangi perubahan manual dan potensi kesalahan.
-   [*] **Implementasi:**
    -   [*] Definisikan struktur data untuk `Environment` (nama, pasangan key-value).
    -   [*] Buat UI pengaturan untuk mengelola environment dan variabel.
    -   [*] Terapkan langkah pra-pemrosesan request di `HomeViewModel` untuk mengganti variabel di URL, header, dan body sebelum `NetworkService.performRequest` dipanggil.

---

## ✨ Fitur Penting (Langkah Evolusi Selanjutnya)

Fitur-fitur ini dapat dipertimbangkan untuk pembaruan selanjutnya, lebih meningkatkan kemampuan Postie tanpa menyimpang dari filosofi ringannya.

### 4. Pencarian dalam Body Respon

-   [x] **Mengapa:** Untuk respons JSON yang besar, kemampuan untuk mencari key atau value tertentu (seperti `Cmd+F` di editor teks) sangat penting untuk debugging dan inspeksi data yang efisien.
-   [x] **Implementasi:**
    -   [x] Perluas `NativeTextView` dengan Coordinator pattern untuk search functionality
    -   [x] Tambahkan SearchBarView dengan real-time highlighting
    -   [x] Keyboard shortcut `⌘F` untuk quick access
    -   [x] Auto-scroll ke hasil pertama dengan visual indicator
-   [x] **Bonus:** Quick clear buttons untuk semua input fields (URL, Token, Headers, Body)

### 5. Koleksi/Pengelompokan Request dalam Aplikasi

-   [x] **Mengapa:** Mengatur request ke dalam grup atau folder logis (misalnya, "User API", "Product API") di dalam aplikasi itu sendiri, daripada hanya sebagai file individual, mengubah Postie menjadi alat manajemen proyek yang lebih kuat untuk pengujian API.
-   [x] **Implementasi:**
    -   [x] Terapkan model data untuk `Collection` (nama, array referensi `RequestPreset`).
    -   [x] Kembangkan UI khusus untuk mengelola koleksi di sidebar atau tampilan terpisah.

### 6. Render Respon yang Ditingkatkan (HTML, Gambar)

-   [x] **Mengapa:** Tidak semua respons API adalah JSON. Mendukung rendering langsung HTML (melalui `WebView`) atau menampilkan gambar (PNG, JPEG) berdasarkan header `Content-Type` akan membuat Postie lebih serbaguna untuk berbagai jenis API.
-   [x] **Implementasi:**
    -   [x] Modifikasi `ResponsePanel` untuk merender tipe konten yang berbeda secara kondisional berdasarkan `APIResponse.headers["Content-Type"]`.

---

Rekomendasi ini bertujuan untuk membangun kekuatan Postie yang ada, memenuhi kebutuhan developer umum, dan secara signifikan meningkatkan kegunaannya untuk berbagai skenario pengujian API.