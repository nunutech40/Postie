# 🏗️ HomeViewModel Architecture

## Overview
`HomeViewModel` adalah class utama yang mengelola state dan business logic untuk seluruh aplikasi Postie. Class ini telah di-refactor menggunakan **Extension-based Organization** untuk meningkatkan maintainability dan readability.

## Struktur Organisasi

### 1️⃣ **Main Class** (`HomeViewModel`)
Berisi:
- **State Properties** - Semua `@Published` properties yang di-observe oleh Views
- **Computed Properties** - Properties yang dihitung dari state lain
- **Constants** - Data yang tidak berubah (seperti `methods`)
- **Private Properties** - Task references untuk cancellation
- **Initialization** - Setup awal saat ViewModel dibuat

### 2️⃣ **Request Execution Extension**
**Purpose:** Mengelola eksekusi HTTP request

**Functions:**
- `runRealRequest()` - Execute HTTP request dengan konfigurasi saat ini
- `cancelRequest()` - Batalkan request yang sedang berjalan
- `parseHeaders(rawText:)` - Parse raw headers text menjadi dictionary
- `saveRequestToCache()` - Simpan request ke cache untuk persistence

**State yang Dikelola:**
- `isLoading`, `response`, `errorMessage`
- `currentRequestTask`

### 3️⃣ **Download Management Extension**
**Purpose:** Mengelola download file dengan progress tracking

**Functions:**
- `runDownload()` - Execute download dengan progress monitoring
- `cancelDownload()` - Batalkan download yang sedang berjalan

**State yang Dikelola:**
- `isDownloading`, `downloadProgress`, `downloadInfo`, `totalBytesKnown`
- `currentDownloadTask`

### 4️⃣ **History Management Extension**
**Purpose:** Mengelola request history (10 terakhir)

**Functions:**
- `addRequestToHistory(wasSuccessful:)` - Tambah request ke history
- `loadRequestFromHistory(request:)` - Load request dari history ke form

**State yang Dikelola:**
- `requestHistory`

### 5️⃣ **Collection Management Extension**
**Purpose:** Mengelola request collections (grouping & organization)

**Functions:**
- `loadCollections()` - Load collections dari file
- `saveCollections()` - Save collections ke file
- `showAddCollectionAlert()` - Show dialog untuk create collection
- `createCollection(name:)` - Buat collection baru
- `confirmDeleteCollection(id:)` - Confirm delete collection
- `performDeleteCollection()` - Delete collection
- `confirmRenameCollection(id:)` - Confirm rename collection
- `performRenameCollection()` - Rename collection
- `addCurrentRequestToCollection()` - Tambah request ke collection
- `loadRequestFromCollection(request:)` - Load request dari collection
- `deleteRequestFromCollection(id:)` - Delete request dari collection
- `deleteRequestFromCollection(at:)` - Delete request by index

**State yang Dikelola:**
- `collections`, `selectedCollectionID`, `editingCollectionID`
- `showingNewCollectionAlert`, `newCollectionName`
- `showingDeleteCollectionAlert`, `collectionToDeleteID`
- `showingRenameCollectionAlert`, `collectionToRenameID`, `newCollectionEditedName`

### 6️⃣ **Environment Management Extension**
**Purpose:** Mengelola environments dan variable substitution

**Functions:**
- `addEnvironment(_:)` - Tambah environment baru
- `updateEnvironment(_:)` - Update environment yang ada
- `deleteEnvironment(at:)` - Delete environment
- `forceSaveEnvironments()` - Save environments dan ensure valid selection
- `substituteVariables(in:)` - Replace `{{variable}}` dengan nilai dari environment

**State yang Dikelola:**
- `environments`, `selectedEnvironmentID`

### 7️⃣ **Response Actions Extension**
**Purpose:** Actions yang bisa dilakukan terhadap response

**Functions:**
- `copyResponseToClipboard()` - Copy response ke clipboard
- `exportResponse()` - Export response ke file

**State yang Dikelola:**
- `response` (read-only)

### 8️⃣ **UI Helpers Extension**
**Purpose:** Utility functions untuk UI interactions

**Functions:**
- `showToast(message:)` - Show toast notification
- `showToastMessage(_:)` - Internal toast helper dengan auto-dismiss

**State yang Dikelola:**
- `showToast`, `toastMessage`

## State Categories

### Input State
State yang diisi oleh user melalui form:
```swift
selectedMethod, urlString, authToken, rawHeaders, requestBody
```

### Output State
State yang menampilkan hasil dari operations:
```swift
response, isLoading, errorMessage
downloadProgress, isDownloading, downloadInfo, totalBytesKnown
```

### Data State
State yang menyimpan data collections:
```swift
requestHistory, collections, environments
```

### UI State
State yang mengontrol tampilan UI:
```swift
showToast, toastMessage, searchQuery, showSearch, showRawResponse
showingNewCollectionAlert, showingDeleteCollectionAlert, showingRenameCollectionAlert
```

### Selection State
State yang melacak item yang dipilih:
```swift
selectedCollectionID, selectedEnvironmentID
collectionToDeleteID, collectionToRenameID, editingCollectionID
```

## Benefits of This Architecture

### ✅ **Separation of Concerns**
Setiap extension fokus pada satu domain/fitur tertentu, membuat kode lebih mudah dipahami dan di-maintain.

### ✅ **Easy Navigation**
Developer bisa langsung jump ke extension yang relevan tanpa scroll ratusan baris kode.

### ✅ **Testability**
Setiap extension bisa di-test secara terpisah dengan mocking dependencies yang minimal.

### ✅ **Scalability**
Menambah fitur baru tinggal buat extension baru tanpa mengubah struktur yang ada.

### ✅ **Code Organization**
MARK comments membuat navigation di Xcode lebih mudah dengan jump bar.

## Usage Example

```swift
// In SwiftUI View
@StateObject var viewModel = HomeViewModel()

// Request execution
viewModel.runRealRequest()
viewModel.cancelRequest()

// Collection management
viewModel.createCollection(name: "User API")
viewModel.addCurrentRequestToCollection()

// Environment management
viewModel.addEnvironment(newEnv)
viewModel.updateEnvironment(editedEnv)

// Response actions
viewModel.copyResponseToClipboard()
viewModel.exportResponse()
```

## Future Improvements

1. **Extract to Separate ViewModels**
   - Bisa split menjadi `RequestViewModel`, `CollectionViewModel`, `EnvironmentViewModel`
   - Tapi untuk app size Postie, single ViewModel dengan extensions sudah cukup optimal

2. **Add Protocol Conformance**
   - Bisa tambah protocols untuk testing: `RequestExecuting`, `CollectionManaging`, dll

3. **Dependency Injection**
   - Services bisa di-inject untuk better testability
   - Tapi untuk simplicity, static services sudah cukup

---

**Last Updated:** 2026-01-11  
**Refactored By:** Nunu Nugraha
