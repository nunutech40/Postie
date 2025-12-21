# 🧭 RequestLab / Postie — Development Battle Plan

Arsitektur: **MVVM + Service Layer**  
Goal: HTTP Client ringan, bersih, dan mudah di-extend (mirip Postman versi minimal).

---

## 🧱 PHASE 1 — THE BLUEPRINT (Models)

_Definisi struktur data sebagai kontrak antara UI ↔ Logic._

### ✅ Tasks

- [ ] Create `HTTPMethod` enum
  - [ ] Case: `.get`
  - [ ] Case: `.post`
  - [ ] Case: `.put`
  - [ ] Case: `.delete`
  - [ ] Computed property: `var title: String`

- [ ] Create `APIResponse` struct
  - [ ] `statusCode: Int`
  - [ ] `latency: Double`
  - [ ] `headers: [AnyHashable: Any]?`
  - [ ] `body: String`

---

## ⚙️ PHASE 2 — THE ENGINE (Service Layer)

_Ruang mesin. Semua urusan networking terjadi di sini._

### ✅ Tasks

- [ ] Create `NetworkService`
  - [ ] Function:
    ```swift
    sendRequest(
      url: String,
      method: HTTPMethod,
      headers: [String: String],
      body: String?
    ) async throws -> APIResponse
    ```

### URLRequest Setup

- [ ] Validasi URL String → `URL`
- [ ] Set `httpMethod`
- [ ] Inject default header:
  - `Content-Type: application/json`
- [ ] Inject custom headers
- [ ] Convert body String → `Data`

### URLSession Execution

- [ ] Use `URLSession.shared.data(for: request)`
- [ ] Capture start time (`Date()`)
- [ ] Capture end time (`Date()`)
- [ ] Calculate latency

### Response Handling

- [ ] Cast response → `HTTPURLResponse`
- [ ] Extract `statusCode`
- [ ] Convert response `Data` → `String`
- [ ] Wrap result into `APIResponse`

---

## 🧠 PHASE 3 — THE BRAIN (ViewModel)

_Jembatan antara UI dan Service. Semua logic hidup di sini._

### ✅ Tasks

- [ ] Create `RequestViewModel : ObservableObject`

### Input Properties (`@Published`)

- [ ] `url: String`
- [ ] `selectedMethod: HTTPMethod`
- [ ] `token: String`
- [ ] `rawHeaders: String`
- [ ] `requestBody: String`

### Output Properties (`@Published`)

- [ ] `response: APIResponse?`
- [ ] `isLoading: Bool`
- [ ] `errorMessage: String?`

### Logic Functions

- [ ] `parseHeaders() -> [String: String]`
  - Parse format:
    ```
    Key: Value
    Key2: Value2
    ```

- [ ] `send()`
  - [ ] Set `isLoading = true`
  - [ ] Merge token header
  - [ ] Call `NetworkService`
  - [ ] Handle success / error
  - [ ] Set `isLoading = false`

- [ ] `prettyPrintJSON(_ raw: String) -> String`

---

## 🎨 PHASE 4 — THE FACE (View / UI)

_SwiftUI layer. Binding langsung ke ViewModel._

### ✅ Tasks

- [ ] Create `MainView`
  - [ ] Inject:
    ```swift
    @StateObject var viewModel = RequestViewModel()
    ```

### UI — Input Section

- [ ] Picker: HTTP Method
- [ ] TextField: URL
- [ ] TextField: Bearer Token
- [ ] TextEditor: Raw Headers
- [ ] Conditional TextEditor: Body (POST / PUT only)

### UI — Trigger Section

- [ ] Button: **SEND**
- [ ] Overlay `ProgressView` when `isLoading == true`

### UI — Output Section

- [ ] Status Code indicator (Green / Red)
- [ ] Latency text
- [ ] ScrollView:
  - [ ] Response body
  - [ ] Monospaced font

---

## 🔄 DATA FLOW (Mental Model)

