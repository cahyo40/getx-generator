# Flutter GetX Code Generator

Generator kode otomatis untuk struktur project Flutter dengan arsitektur GetX yang terorganisir. Alat ini membantu developer menghasilkan boilerplate code secara cepat dan konsisten.

## 📥 Cara Menambahkan ke Project Flutter

### Metode 1: Clone/Download Manual

1. **Download file dari GitHub:**
   ```bash
   # Download kedua file secara manual atau
   git clone https://github.com/cahyo40/getx-generator.git
   ```

2. **Letakkan file di root project Flutter:**
   ```
   your_flutter_project/
   ├── generate.dart          # File generator
   ├── tasks.json            # VSCode tasks configuration
   ├── lib/                  # Existing Flutter code
   ├── pubspec.yaml          # Existing Flutter config
   └── ...
   ```

3. **Pastikan struktur folder sesuai:**
   ```bash
   # Jika folder apps belum ada, buat struktur dasar
   mkdir -p lib/apps/routes
   ```

### Metode 2: Using Git Submodule (Advanced)

```bash
# Tambahkan sebagai submodule
git submodule add https://github.com/username/flutter-getx-generator.git tools/generator

# Copy file ke root project
cp tools/generator/generate.dart .
cp tools/generator/tasks.json .
```

### Metode 3: Using Script Installer

Buat file `install_generator.sh`:
```bash
#!/bin/bash
echo "📥 Installing Flutter GetX Generator..."

# Download files
curl -o generate.dart https://raw.githubusercontent.com/username/repo/main/generate.dart
curl -o tasks.json https://raw.githubusercontent.com/username/repo/main/tasks.json

# Create necessary directories
mkdir -p lib/apps/routes
mkdir -p lib/apps/features
mkdir -p lib/apps/widget
mkdir -p lib/apps/controller
mkdir -p lib/apps/data/model

echo "✅ Generator installed successfully!"
echo "🚀 Usage: dart generate.dart page:home"
```

## 🔧 Prerequisites

Pastikan dependencies yang diperlukan sudah ada di `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6    # GetX state management

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

## 🚀 Setup dan Konfigurasi

### 1. **Setup Awal Project**

```bash
# Pastikan di root project Flutter
cd your_flutter_project

# Test generator bekerja
dart generate.dart

# Output yang diharapkan:
# Usage: dart generate.dart <command>:<name>
# Available commands: page, controller, model, widget
```

### 2. **Konfigurasi VSCode (Opsional)**

File `tasks.json` akan otomatis bekerja jika diletakkan di folder `.vscode/`:

```bash
# Jika folder .vscode belum ada
mkdir .vscode

# Pindahkan tasks.json ke folder .vscode
mv tasks.json .vscode/tasks.json
```

### 3. **Update Main Dart File**

Pastikan `lib/main.dart` menggunakan GetMaterialApp:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'apps/routes/route_app.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Flutter App',
      initialRoute: '/',
      getPages: RouteApp.routes,
      home: HomePage(), // Ganti dengan home page Anda
    );
  }
}
```

## 🧪 Testing Installation

### Test 1: Generate Page Pertama

```bash
dart generate.dart page:home
```

**Output yang diharapkan:**
```
Created directory: lib/apps/features/home/presentation/view
Created directory: lib/apps/features/home/presentation/view/screen
...
Generated view: lib/apps/features/home/presentation/view/home_view.dart
Updated routes for Home
```

### Test 2: Generate Screen

```bash
dart generate.dart screen dashboard on home
```

### Test 3: Test VSCode Tasks

1. Buka VSCode
2. `Ctrl+Shift+P` → "Tasks: Run Task"
3. Pilih "Generate Page"
4. Masukkan nama page: `settings`

## 📁 Struktur Project Setelah Install

```
your_flutter_project/
├── generate.dart              # Generator script
├── .vscode/tasks.json         # VSCode tasks
├── lib/
│   ├── main.dart              # Updated dengan GetMaterialApp
│   └── apps/
│       ├── routes/
│       │   ├── route_names.dart
│       │   └── route_app.dart
│       ├── features/
│       │   ├── home/
│       │   └── settings/
│       ├── widget/            # Custom widgets
│       ├── controller/        # Standalone controllers
│       └── data/model/        # Global models
└── pubspec.yaml
```

## 🔄 Update Generator

```bash
# Untuk update generator ke versi terbaru
curl -o generate.dart https://raw.githubusercontent.com/username/repo/main/generate.dart
curl -o tasks.json https://raw.githubusercontent.com/username/repo/main/tasks.json
```

## ⚠️ Troubleshooting Installation

**Error: Dart command not found**
- Pastikan Dart SDK terinstall dan ada di PATH

**Error: File not found**
- Pastikan berada di root project Flutter
- Pastikan `pubspec.yaml` ada di directory saat ini

**Error: GetX not found**
- Pastikan GetX sudah ditambahkan di `pubspec.yaml`
- Run `flutter pub get`

**VSCode tasks tidak muncul**
- Pastikan `tasks.json` ada di folder `.vscode/`
- Restart VSCode

**Routes error**
- Pastikan import path di `main.dart` sesuai struktur project

## 🎯 Quick Start Commands

Setelah installasi berhasil, gunakan perintah berikut:

```bash
# Setup project structure dasar
dart generate.dart page:splash
dart generate.dart page:login --presentation-only
dart generate.dart page:home
dart generate.dart screen profile on home

# Generate supporting files
dart generate.dart repository:user on home
dart generate.dart widget:loading
dart generate.dart model:user
```

## 📝 Notes

- Generator ini optimized untuk project dengan struktur feature-based
- Semua generated code mengikuti best practices GetX dan Clean Architecture
- File routes akan terupdate otomatis setiap generate page baru
- Support untuk nested pages: `page:settings.profile`

Dengan mengikuti panduan ini, Anda akan memiliki code generator yang powerful untuk mempercepat development Flutter project! 🚀