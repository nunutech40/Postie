# 🚀 Postie — The Ultra-Lightweight API Client

**Postie** adalah aplikasi native macOS yang dirancang sebagai alternatif ringan untuk API testing (seperti Postman atau Insomnia). Fokus utama aplikasi ini adalah **performa maksimal dengan jejak memori minimal**, tanpa mengorbankan fungsionalitas inti yang dibutuhkan developer.

---

## 🎯 Mengapa Postie?

Sebagian besar API client modern berbasis Electron, yang dapat mengonsumsi ratusan megabyte RAM hanya untuk melakukan satu `GET` request sederhana.

Postie dibangun **100% native menggunakan SwiftUI & AppKit**, dengan tujuan:

- **RAM Usage:** < 50 MB (Postman rata-rata > 500 MB)
- **Instant Start:** Tanpa splash screen, aplikasi siap digunakan seketika
- **Zero Dependencies:** Tidak menggunakan library pihak ketiga (No CocoaPods / SPM), murni Apple SDK

Pendekatan ini memastikan aplikasi tetap **ringan, cepat, dan stabil** bahkan saat digunakan berjam-jam.

---

## ✨ Fitur Utama

- **Full HTTP Methods Support**  
  Mendukung `GET`, `POST`, `PUT`, `DELETE`, dan `PATCH`.

- **Bearer Token Shortcut**  
  Slot khusus untuk autentikasi cepat tanpa konfigurasi header manual.

- **Dynamic JSON Beautifier**  
  Respon JSON otomatis di-*pretty print* agar mudah dibaca dan dianalisis.

- **Latency Evaluator**  
  Indikator visual berbasis durasi request (Excellent, Good, Average, Slow).

- **Preset System**  
  Simpan dan buka konfigurasi request dalam format `.json` yang portabel.

- **Smart Error Mapping**  
  Error teknis dipetakan menjadi pesan manusiawi (Timeout, No Internet, Invalid URL).

---

## 🛠️ Arsitektur & Teknologi  

Postie dibangun dengan pola **MVVM + Service Layer** yang terpisah jelas, memastikan kode mudah dirawat, diuji, dan dikembangkan.

---

### 1. Advanced Networking (`URLSession`)

Menggunakan `URLSessionConfiguration` kustom untuk kontrol penuh terhadap performa:

- **Custom Timeout**  
  Dibatasi 30 detik untuk mencegah UI *freezing*.

- **Cache Policy Disabled**  
  Memastikan setiap request selalu mengambil data terbaru (*fresh data*).

- **Connectivity Handling**  
  `waitsForConnectivity` diaktifkan untuk stabilitas pada jaringan yang tidak konsisten.

---

### 2. Concurrency Management

- Implementasi penuh **Swift Concurrency (async/await)**.
- Semua update UI diamankan dengan `@MainActor`.
- Eksekusi berbasis `Task`, memungkinkan pembatalan request secara efisien.

---

### 3. Logic-Driven Unit Testing

Postie tidak hanya fokus pada UI, tetapi juga fondasi logic yang kuat dan teruji:

- **PresetServiceTests**  
  Menjamin integritas data saat proses baca/tulis file preset.

- **NetworkServiceTests**  
  Menguji validasi URL, parsing response, dan JSON pretty-print dari berbagai edge case.

- **RequestViewModelTests**  
  Menguji parsing header kompleks dan sinkronisasi state UI menggunakan Combine expectations.

---

## 📊 Performance Benchmark

| Metric | Postman (Electron) | Postie (Native Swift) |
|------|-------------------|----------------------|
| **Idle RAM** | ~450 MB | **~35 MB** |
| **Startup Time** | ~5–10 detik | **< 1 detik** |
| **Dependencies** | Heavy (Node.js) | **None (Pure Native)** |

---

## 🚀 Instalasi

1. Clone repository ini.
2. Buka `Postie.xcodeproj` menggunakan Xcode.
3. Pada **Signing & Capabilities**, atur **App Sandbox**:
   - Enable **Read/Write** untuk *User Selected Files*.
4. Build & Run (`Cmd + R`).

---

## 👨‍💻 Author

** Nunu Nugraha 
*iOS Developer* yang percaya bahwa aplikasi hebat adalah aplikasi yang **cepat, stabil, dan tepat guna** — bukan yang paling banyak dependency.

---

## 💡 Catatan

- Letakkan file ini di root project dengan nama `README.md`.
- Disarankan menambahkan **screenshot aplikasi** di bagian paling atas untuk *visual hook*.
- Struktur ini dirancang agar mudah dibaca oleh **Recruiter, Engineering Manager, maupun CTO**.

