# Flutter GetX Code Generator v2.0.0

<p align="center">
  <img src="https://img.shields.io/badge/version-2.0.0-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/dart-%3E%3D3.0.0-brightgreen.svg" alt="Dart">
  <img src="https://img.shields.io/badge/flutter-%3E%3D3.0.0-blue.svg" alt="Flutter">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
</p>

Generator kode otomatis untuk struktur project Flutter dengan arsitektur **GetX + Clean Architecture**. Alat ini membantu developer menghasilkan boilerplate code secara cepat, konsisten, dan mengikuti best practices.

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🏗️ **Page Generator** | Generate halaman lengkap dengan Clean Architecture |
| 📱 **Screen Generator** | Generate screen di dalam page yang sudah ada |
| 🎮 **Controller Generator** | Generate standalone controller |
| 📦 **Model Generator** | Generate model dengan JSON serialization |
| ❄️ **Freezed Support** | Generate model dengan Freezed annotation |
| 🔧 **Widget Generator** | Generate reusable widget |
| 🔌 **Service Generator** | Generate GetxService untuk dependency injection |
| 📚 **Repository Generator** | Generate repository pattern (abstrak + implementasi) |
| 🎯 **Usecase Generator** | Generate usecase untuk business logic |
| 📋 **Entity Generator** | Generate domain entity |
| 🗑️ **Delete Command** | Hapus page beserta update routes otomatis |
| 📂 **List Command** | Lihat semua page yang tersedia |
| ⚙️ **Init Command** | Setup struktur project secara otomatis |

## 📥 Instalasi

### Metode 1: Clone Repository

```bash
# Clone repository
git clone https://github.com/cahyo40/getx-generator.git

# Copy file ke project Flutter
cp getx-generator/generate.dart your_flutter_project/
cp -r getx-generator/.vscode your_flutter_project/
```

### Metode 2: Download Manual

```bash
# Download langsung ke project
cd your_flutter_project

# Download generate.dart
curl -O https://raw.githubusercontent.com/cahyo40/getx-generator/main/generate.dart

# Download VSCode tasks (opsional)
mkdir -p .vscode
curl -o .vscode/tasks.json https://raw.githubusercontent.com/cahyo40/getx-generator/main/.vscode/tasks.json
```

### Metode 3: Script Installer

Buat file `install_generator.sh` di root project:

```bash
#!/bin/bash
echo "📥 Installing Flutter GetX Generator..."

curl -O https://raw.githubusercontent.com/cahyo40/getx-generator/main/generate.dart
mkdir -p .vscode
curl -o .vscode/tasks.json https://raw.githubusercontent.com/cahyo40/getx-generator/main/.vscode/tasks.json

echo "✅ Generator installed successfully!"
echo "🚀 Run: dart generate.dart --help"
```

## 🔧 Konfigurasi Awal

### 1. Dependencies (pubspec.yaml)

Pastikan dependencies berikut ada di `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  dio: ^5.4.0
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  # Untuk Freezed (opsional)
  freezed: ^2.4.6
  freezed_annotation: ^2.4.1
  json_serializable: ^6.7.1
  build_runner: ^2.4.8
```

### 2. Inisialisasi Project

```bash
dart generate.dart init
```

Perintah ini akan:
- ✅ Membuat struktur folder Clean Architecture
- ✅ Generate file-file skeleton (Failure, Theme, Constants)
- ✅ Setup routing dasar
- ✅ Update pubspec.yaml dengan dependencies
- ✅ Generate main.dart dengan GetMaterialApp

## 📖 Penggunaan

### Help & Info

```bash
# Tampilkan bantuan lengkap
dart generate.dart --help

# Lihat versi
dart generate.dart --version

# Lihat semua page yang ada
dart generate.dart list
```

### Generate Page

```bash
# Full page dengan Clean Architecture
dart generate.dart page:home

# Dengan nested naming (settings/profile)
dart generate.dart page:settings.profile

# Presentation only (tanpa data/domain layer)
dart generate.dart page:onboarding --presentation-only

# Force overwrite file yang sudah ada
dart generate.dart page:home --force
```

**Struktur yang dihasilkan:**
```
lib/apps/features/home/
├── data/
│   ├── datasource/
│   │   ├── home_network_datasource.dart
│   │   └── home_offline_datasource.dart
│   ├── models/
│   └── repositories/
│       └── home_repository_impl.dart
├── domain/
│   ├── entities/
│   ├── repositories/
│   │   └── home_repository.dart
│   └── usecase/
│       └── home_usecase.dart
└── presentation/
    ├── binding/
    │   └── home_binding.dart
    ├── controller/
    │   └── home_controller.dart
    └── view/
        ├── home_view.dart
        └── screen/
```

### Generate Screen

Screen adalah sub-view di dalam page yang sudah ada:

```bash
dart generate.dart screen dashboard on home
dart generate.dart screen profile on settings
```

### Generate Repository

```bash
dart generate.dart repository:user on home
dart generate.dart repository:product on catalog
```

Menghasilkan:
- `domain/repositories/user_repository.dart` (abstract)
- `data/repositories/user_repository_impl.dart` (implementation)

### Generate Usecase

```bash
dart generate.dart usecase:getuser on home
dart generate.dart usecase:login on auth
```

### Generate Entity

```bash
dart generate.dart entity:user on home
dart generate.dart entity:product on catalog
```

### Generate Standalone Components

```bash
# Controller
dart generate.dart controller:theme

# Widget
dart generate.dart widget:loading

# Model biasa
dart generate.dart model:user

# Model dengan Freezed
dart generate.dart model:user --freezed

# Service
dart generate.dart service:storage
```

### Delete Page

```bash
dart generate.dart delete:page:home
```

Perintah ini akan:
- 🗑️ Hapus folder page
- 📝 Update route_names.dart
- 📝 Update route_app.dart

## 🖥️ VSCode Integration

Setelah meng-copy `.vscode/tasks.json`, gunakan shortcut:

1. **Windows/Linux:** `Ctrl+Shift+P` → "Tasks: Run Task"
2. **macOS:** `Cmd+Shift+P` → "Tasks: Run Task"

Tasks yang tersedia:
- GetX: Initialize Project
- GetX: Generate Page
- GetX: Generate Page (Presentation Only)
- GetX: Generate Screen on Page
- GetX: Generate Repository on Page
- GetX: Generate Usecase on Page
- GetX: Generate Entity on Page
- GetX: Generate Controller
- GetX: Generate Model
- GetX: Generate Freezed Model
- GetX: Generate Widget
- GetX: Generate Service
- GetX: Delete Page
- GetX: List Pages
- GetX: Show Help

## 📁 Struktur Project

Setelah `init`, struktur project Anda akan terlihat seperti ini:

```
lib/
├── main.dart
└── apps/
    ├── core/
    │   ├── constants/
    │   │   └── app_constants.dart
    │   ├── error/
    │   │   └── failure.dart
    │   ├── network/
    │   │   └── api_constants.dart
    │   ├── services/
    │   ├── theme/
    │   │   └── app_theme.dart
    │   └── utils/
    ├── controller/          # Standalone controllers
    ├── data/
    │   └── model/          # Global models
    ├── features/
    │   ├── home/           # Feature modules
    │   ├── auth/
    │   └── settings/
    ├── routes/
    │   ├── route_names.dart
    │   └── route_app.dart
    └── widget/             # Reusable widgets

test/
├── unit/
└── widget/

integration_test/

assets/
├── fonts/
├── icons/
└── images/
```

## 🎯 Best Practices

### Naming Convention

| Type | Format | Example |
|------|--------|---------|
| Page | lowercase | `home`, `settings`, `user_profile` |
| Nested Page | dot notation | `settings.profile`, `auth.login` |
| Controller | PascalCase | `HomeController` |
| Repository | PascalCase + suffix | `UserRepository`, `UserRepositoryImpl` |
| Usecase | PascalCase + suffix | `GetUserUsecase` |
| Entity | PascalCase + suffix | `UserEntity` |

### Clean Architecture Flow

```
View → Controller → Usecase → Repository → Datasource
         ↑                        ↓
       State                   Entity/Model
```

### Controller Best Practice

```dart
class HomeController extends GetxController {
  // State
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final users = <UserEntity>[].obs;

  // Dependencies (inject via binding)
  final GetUsersUsecase _getUsersUsecase;
  
  HomeController(this._getUsersUsecase);

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final result = await _getUsersUsecase();
      result.fold(
        (failure) => error.value = failure.message,
        (data) => users.assignAll(data),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
```

### Binding Best Practice

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Datasources
    Get.lazyPut(() => HomeNetworkDatasource());
    Get.lazyPut(() => HomeOfflineDatasource());
    
    // Repository
    Get.lazyPut<HomeRepository>(
      () => HomeRepositoryImpl(Get.find(), Get.find()),
    );
    
    // Usecases
    Get.lazyPut(() => GetUsersUsecase(Get.find()));
    
    // Controller
    Get.lazyPut(() => HomeController(Get.find()));
  }
}
```

## ⚠️ Troubleshooting

### Error: Dart command not found

Pastikan Dart SDK terinstall dan ada di PATH:

```bash
# Check instalasi
dart --version

# Jika belum ada, install via Flutter
flutter doctor
```

### Error: Page does not exist

Pastikan page sudah dibuat sebelum generate screen/repository/usecase:

```bash
# Lihat page yang tersedia
dart generate.dart list

# Buat page dulu
dart generate.dart page:home
```

### Error: File already exists

Gunakan flag `--force` untuk overwrite:

```bash
dart generate.dart page:home --force
```

### Routes tidak terupdate

Pastikan struktur file `route_app.dart` dan `route_names.dart` sesuai format yang diharapkan generator.

### Freezed tidak generate

Jalankan build_runner setelah generate model:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📋 Command Reference

| Command | Description |
|---------|-------------|
| `init` | Initialize project structure |
| `page:<name>` | Generate full page |
| `page:<name> --presentation-only` | Generate page without data/domain |
| `controller:<name>` | Generate standalone controller |
| `model:<name>` | Generate basic model |
| `model:<name> --freezed` | Generate Freezed model |
| `widget:<name>` | Generate reusable widget |
| `service:<name>` | Generate GetxService |
| `screen <name> on <page>` | Generate screen on page |
| `repository:<name> on <page>` | Generate repository on page |
| `usecase:<name> on <page>` | Generate usecase on page |
| `entity:<name> on <page>` | Generate entity on page |
| `delete:page:<name>` | Delete page and update routes |
| `list` | List all available pages |
| `--help`, `-h` | Show help |
| `--version`, `-v` | Show version |
| `--force`, `-f` | Force overwrite files |

## 🔄 Changelog

### v2.0.0 (2024-12-22)
- ✨ **New:** Entity generator
- ✨ **New:** Usecase generator (standalone)
- ✨ **New:** Service generator
- ✨ **New:** Freezed model support
- ✨ **New:** Delete page command
- ✨ **New:** List pages command
- ✨ **New:** Help command
- ✨ **New:** Force overwrite flag
- 🐛 **Fix:** Input validation untuk nama
- 🐛 **Fix:** toCamelCase dan toSnakeCase handle edge cases
- 🐛 **Fix:** updateRoutes insert position yang benar
- 🐛 **Fix:** Widget syntax error
- 🐛 **Fix:** tasks.json invalid JSON comments
- 🔧 **Improve:** Error handling dengan safe file write
- 🔧 **Improve:** Better console output dengan emoji
- 🔧 **Improve:** Controller template dengan loading/error state
- 🔧 **Improve:** Model template dengan copyWith dan equality
- 📚 **Docs:** README lengkap dengan contoh

### v1.0.0
- 🎉 Initial release
- Page generator dengan Clean Architecture
- Screen generator
- Controller generator
- Model generator
- Widget generator
- Repository generator
- VSCode tasks integration

## 📄 License

MIT License - lihat file [LICENSE](LICENSE) untuk detail.

## 🤝 Contributing

Kontribusi sangat diterima! Silakan buat issue atau pull request.

1. Fork repository
2. Buat branch fitur (`git checkout -b feature/amazing`)
3. Commit perubahan (`git commit -m 'Add amazing feature'`)
4. Push ke branch (`git push origin feature/amazing`)
5. Buat Pull Request

## 👨‍💻 Author

**Cahyo** - [GitHub](https://github.com/cahyo40)

---

<p align="center">
  Made with ❤️ for Flutter Community
</p>