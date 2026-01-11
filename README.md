# 🚀 Postie — API Client Native macOS yang Super Ringan

> **HTTP client yang super cepat dan hemat memori, dibangun 100% native untuk developer macOS yang menghargai kecepatan dan kesederhanaan.**

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS-blue" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9-orange" alt="Swift">
  <img src="https://img.shields.io/badge/RAM-<50MB-green" alt="RAM Usage">
  <img src="https://img.shields.io/badge/Dependencies-Zero-brightgreen" alt="Dependencies">
</p>

---

## 📖 Daftar Isi

- [Kenapa Postie?](#-kenapa-postie)
- [Untuk Siapa?](#-untuk-siapa)
- [Fitur Utama](#-fitur-utama)
- [Teknologi](#-teknologi)
- [Cara Pakai](#-cara-pakai)
- [Highlight Fitur](#-highlight-fitur)
- [Arsitektur](#-arsitektur)
- [Performa](#-performa)

---

## 🎯 Kenapa Postie?

Kebanyakan API client modern (Postman, Insomnia) dibangun pakai Electron, yang ngabisin **500MB+ RAM** cuma buat kirim request GET sederhana. Postie hadir sebagai alternatif yang lebih masuk akal.

**Postie itu:**
- ✅ **100% Native** — Dibangun pakai SwiftUI & AppKit, tanpa bloat Electron
- ✅ **Super Ringan** — Konsisten di bawah 50MB RAM
- ✅ **Langsung Jalan** — Tanpa splash screen, siap dalam milidetik
- ✅ **Zero Dependencies** — Tanpa library pihak ketiga, murni Apple SDK

**Hasilnya:** Tool testing API profesional yang menghargai resource sistem dan waktu kamu.

---

## 👥 Untuk Siapa?

Postie dirancang untuk developer yang:

- 🏃 **Butuh Kecepatan** — Testing API nggak boleh bikin workflow lambat
- 💻 **Menghargai Performa Native** — Lebih suka tool yang dioptimasi untuk macOS
- 🧠 **Kerja dengan Resource Terbatas** — Jalanin banyak dev tools sekaligus
- 🎯 **Suka Kesederhanaan** — Interface bersih tanpa fitur yang overwhelming
- 🔒 **Peduli Privacy** — Tanpa telemetry, tanpa cloud sync, data kamu tetap lokal

**Cocok untuk:**
- Backend developer yang testing REST API
- Frontend developer yang integrasi dengan API
- Mobile developer yang debugging API endpoint
- DevOps engineer yang validasi API response
- Siapa aja yang bosen sama aplikasi Electron yang berat

---

## ✨ Fitur Utama

### 🚀 **Fungsi Inti**
- **Full HTTP Methods** — Support GET, POST, PUT, DELETE, PATCH
- **Smart Request Builder** — URL, headers, body dengan validasi syntax
- **Bearer Token Shortcut** — Autentikasi cepat tanpa setting header manual
- **Dynamic JSON Beautifier** — Auto-format response biar mudah dibaca
- **Response Rendering** — JSON, HTML (WebView), Gambar, Plain Text

### 🔍 **Tool Produktivitas**
- **Search in Response** — `⌘F` buat cari apa aja dengan highlighting real-time
- **Quick Clear Buttons** — Satu klik buat clear URL, headers, body
- **Copy to Clipboard** — `⌘C` buat copy response langsung
- **Export Response** — Simpan response sebagai file
- **Raw/Formatted Toggle** — Switch antara JSON yang di-format atau raw

### 📁 **Organisasi**
- **Request Collections** — Organisir API ke dalam folder
- **Request History** — 10 request terakhir dengan indikator status visual
- **Preset System** — Save/load request sebagai file `.json` yang portable
- **Environment Management** — Switch antara dev/staging/prod dengan variabel kayak `{{baseURL}}`

### ⚡ **Fitur Performa**
- **Request Cancellation** — Stop request yang lama langsung
- **Download Progress** — Progress visual untuk download file besar
- **Smart Download Engine** — Auto-detect tipe konten dan save dengan benar
- **Latency Evaluator** — Indikator waktu response dengan warna (Excellent/Good/Average/Slow)

### 🛠️ **Developer Experience**
- **Interactive Onboarding** — Tutorial visual 4-slide yang muncul saat first launch, bisa diakses ulang dari toolbar
- **Error Dictionary** — Penjelasan ramah untuk HTTP status code
- **Smart Error Mapping** — Error teknis diterjemahin jadi pesan yang actionable
- **Keyboard Shortcuts** — `⌘F` search, `⌘C` copy, dan lainnya
- **Toast Notifications** — Feedback yang nggak mengganggu untuk setiap aksi

---

## 🏗️ Teknologi

### **Kenapa Teknologi Ini?**

| Teknologi | Fungsi | Alasan Dipilih |
|-----------|--------|----------------|
| **SwiftUI** | UI Framework | Performa native, syntax deklaratif, memory management otomatis |
| **AppKit** | Komponen UI Advanced | Kontrol detail untuk text rendering (`NSTextView`) dan file dialog |
| **URLSession** | Networking | HTTP client dari Apple yang sudah teruji dengan support async/await |
| **Swift Concurrency** | Operasi Async | Modern async/await untuk kode yang bersih dan maintainable |
| **MVVM Pattern** | Arsitektur | Pemisahan concern yang jelas, business logic yang testable |
| **UserDefaults** | Storage Ringan | Cepat dan simple untuk persistence history dan settings |
| **NSSavePanel/NSOpenPanel** | File Operations | Compliant dengan sandboxing, file access yang user-initiated |

### **Yang Sengaja Dihindari**

❌ **Electron** — Terlalu berat, performa jelek  
❌ **Third-Party Libraries** — Dependency hell, risiko security  
❌ **Cloud Sync** — Masalah privacy, kompleksitas tinggi  
❌ **Telemetry** — Data kamu ya punya kamu

---

## 🚀 Cara Pakai

### **Requirements**
- macOS 13.0 (Ventura) atau lebih baru
- Xcode 15.0+ (untuk build dari source)

### **Instalasi**
1. Download dari Mac App Store *(segera hadir)*
2. Atau build dari source:
   ```bash
   git clone https://github.com/yourusername/postie.git
   cd postie
   open Postie.xcodeproj
   ```

### **Request Pertama**
1. Pilih HTTP method (GET, POST, dll)
2. Masukkan URL (contoh: `https://jsonplaceholder.typicode.com/posts`)
3. Tambahkan headers atau body kalau perlu
4. Klik **Send** atau tekan `⌘↵`
5. Lihat response yang sudah di-format dengan syntax highlighting

---

## 🎨 Highlight Fitur

### **1. Search & Highlight** 🔍
Tekan `⌘F` untuk cari dalam response JSON yang besar. Semua hasil di-highlight kuning dengan auto-scroll ke hasil pertama.

### **2. Environment Variables** 🌍
Definisikan environment (Development, Staging, Production) dengan variabel:
```
{{baseURL}} = https://api.staging.example.com
{{apiKey}} = sk_test_12345
```
Pakai di request: `{{baseURL}}/users?key={{apiKey}}`

### **3. Collections** 📚
Organisir request yang related ke dalam collection:
- User API → Get User, Create User, Update User
- Product API → List Products, Get Product Details

### **4. Smart Download Engine** 📥
Otomatis deteksi tipe file dan save dengan extension yang benar:
- JSON → `.json`
- Images → `.png`, `.jpg`
- PDFs → `.pdf`

### **5. Request History** 🕐
10 request terakhir disimpan otomatis. Request yang gagal dibedakan secara visual untuk debugging cepat.

### **6. Interactive Onboarding** 🎓
Tutorial visual 4-slide yang muncul otomatis saat first launch:
- **Slide 1:** Pengenalan interface dan cara kirim request
- **Slide 2:** Cara organisir request dengan Collections
- **Slide 3:** Manfaat Request History dan Environment Management
- **Slide 4:** Keunggulan native app (performa, RAM usage)

Bisa diakses ulang kapan saja lewat tombol tutorial (▶️) di toolbar.


---

## 🏛️ Arsitektur

### **MVVM + Service Layer**

```
┌─────────────────┐
│   SwiftUI Views │ ← User Interface
└────────┬────────┘
         │
┌────────▼────────┐
│   HomeViewModel │ ← State Management
└────────┬────────┘
         │
┌────────▼────────┐
│    Services     │ ← Business Logic
│  - Network      │
│  - File         │
│  - Collection   │
│  - Environment  │
└─────────────────┘
```

### **Keputusan Design Utama**

**1. Stateless Services**  
Service nggak nyimpen state—ViewModel yang manage semua UI state biar behavior predictable.

**2. Optimasi Memori**  
Pakai `NSTextView` daripada SwiftUI `Text` untuk payload besar biar nggak bloat. Cache di-clear explicit setelah tiap response.

**3. User-Initiated File Access**  
Semua operasi file pakai `NSSavePanel`/`NSOpenPanel` biar compliant dengan sandboxing dan aman.

**4. Async/Await First**  
Swift concurrency modern di mana-mana—tanpa completion handler atau callback.

---

## ⚡ Performa

### **Benchmark Memori**

| Aplikasi | RAM Idle | Setelah 10 Request | Setelah JSON Besar (5MB) |
|----------|----------|-------------------|--------------------------|
| **Postie** | 36 MB | 42 MB | 48 MB |
| Postman | 520 MB | 680 MB | 850 MB |
| Insomnia | 450 MB | 590 MB | 720 MB |

### **Waktu Startup**

| Aplikasi | Cold Start | Warm Start |
|----------|------------|------------|
| **Postie** | 0.3s | 0.1s |
| Postman | 3.2s | 1.8s |
| Insomnia | 2.8s | 1.5s |

### **Gimana Caranya?**

1. **Native Compilation** — Tanpa overhead JavaScript runtime
2. **Lazy Loading** — Komponen load cuma pas dibutuhin
3. **Memory Management** — Deallocation explicit untuk text buffer besar
4. **Efficient Rendering** — `NSTextView` untuk text, native image rendering

---

## 📝 Roadmap

### **v1.1 (Rilis Berikutnya)**
- [ ] Support GraphQL
- [ ] Testing WebSocket
- [ ] Request chaining
- [ ] Code generation (curl, JavaScript, Python)

### **v1.2 (Masa Depan)**
- [ ] Generator dokumentasi API
- [ ] Mock server
- [ ] Fitur kolaborasi tim
- [ ] Plugin system

---

## 🤝 Kontribusi

Kontribusi sangat welcome! Silakan baca [Contributing Guide](CONTRIBUTING.md) dulu ya.

---

## 📄 Lisensi

MIT License - lihat file [LICENSE](LICENSE) untuk detail.

---

## 💬 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/postie/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/postie/discussions)
- **Email:** support@postie.app

---

## ❤️ Dukung Development

Postie dibangun oleh solo indie developer. Kalau tool ini ngeh emat waktu kamu, consider untuk support developmentnya:

- ☕ [Buy Me a Coffee](https://www.buymeacoffee.com/nunutech401)
- 💰 [Saweria](https://saweria.co/nunugraha17)

Setiap kontribusi membantu Postie tetap gratis, bebas iklan, dan terus berkembang!

---

<p align="center">
  Dibuat dengan ❤️ oleh <a href="https://github.com/yourusername">Nunu Nugraha</a>
</p>

<p align="center">
  <sub>© 2025 Nunu Nugraha Logic Inc. All rights reserved.</sub>
</p>
