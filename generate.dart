// ignore_for_file: avoid_print

import 'dart:io';

// ============================================================================
// CONSTANTS
// ============================================================================
const String version = '2.0.0';
const String appName = 'GetX Generator';

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================
void main(List<String> arguments) {
  if (arguments.isEmpty) {
    _printUsage();
    exit(1);
  }

  final command = arguments[0];

  // Handle special commands first
  switch (command) {
    case '--help':
    case '-h':
      _printHelp();
      return;
    case '--version':
    case '-v':
      print('$appName v$version');
      return;
    case 'init':
      _cmdInit(arguments);
      generatePage('home');
      return;
    case 'list':
      _listPages();
      return;
  }

  // Handle screen command: screen <name> on <page>
  if (command == 'screen' && arguments.length >= 4 && arguments[2] == 'on') {
    final screenName = arguments[1];
    final pageName = arguments[3];
    if (!_validateName(screenName) || !_validateName(pageName)) return;
    generateScreenOnPage(screenName, pageName);
    return;
  }

  // Handle entity command: entity:<name> on <page>
  if (command.startsWith('entity:') &&
      arguments.length >= 3 &&
      arguments[1] == 'on') {
    final entityParts = command.split(':');
    if (entityParts.length != 2) {
      _printError('Invalid entity format. Use: entity:<name> on <page>');
      exit(1);
    }
    final entityName = entityParts[1];
    final pageName = arguments[2];
    if (!_validateName(entityName) || !_validateName(pageName)) return;
    generateEntityOnPage(entityName, pageName);
    return;
  }

  // Handle usecase command: usecase:<name> on <page>
  if (command.startsWith('usecase:') &&
      arguments.length >= 3 &&
      arguments[1] == 'on') {
    final usecaseParts = command.split(':');
    if (usecaseParts.length != 2) {
      _printError('Invalid usecase format. Use: usecase:<name> on <page>');
      exit(1);
    }
    final usecaseName = usecaseParts[1];
    final pageName = arguments[2];
    if (!_validateName(usecaseName) || !_validateName(pageName)) return;
    generateUsecaseOnPage(usecaseName, pageName);
    return;
  }

  // Handle repository command: repository:<name> on <page>
  if (command.startsWith('repository:') &&
      arguments.length >= 3 &&
      arguments[1] == 'on') {
    final repoParts = command.split(':');
    if (repoParts.length != 2) {
      _printError(
        'Invalid repository format. Use: repository:<name> on <page>',
      );
      exit(1);
    }
    final repoName = repoParts[1];
    final pageName = arguments[2];
    if (!_validateName(repoName) || !_validateName(pageName)) return;
    generateRepositoryOnPage(repoName, pageName);
    return;
  }

  // Handle delete command: delete:page:<name>
  if (command.startsWith('delete:')) {
    final deleteParts = command.split(':');
    if (deleteParts.length != 3) {
      _printError('Invalid delete format. Use: delete:page:<name>');
      exit(1);
    }
    final type = deleteParts[1];
    final name = deleteParts[2];
    if (!_validateName(name)) return;
    _handleDelete(type, name);
    return;
  }

  // Handle service command: service:<name>
  if (command.startsWith('service:')) {
    final serviceParts = command.split(':');
    if (serviceParts.length != 2) {
      _printError('Invalid service format. Use: service:<name>');
      exit(1);
    }
    final serviceName = serviceParts[1];
    if (!_validateName(serviceName)) return;
    generateService(serviceName);
    return;
  }

  // Handle standard command:name format
  final parts = command.split(':');
  if (parts.length != 2) {
    _printError('Invalid command format. Use: <command>:<name>');
    exit(1);
  }

  final type = parts[0];
  final name = parts[1];

  if (!_validateName(name)) return;

  final hasForce = arguments.contains('--force') || arguments.contains('-f');
  final hasPresentationOnly = arguments.contains('--presentation-only');
  final hasFreezed = arguments.contains('--freezed');

  switch (type) {
    case 'page':
      if (hasPresentationOnly) {
        generatePagePresentationOnly(name, force: hasForce);
      } else {
        generatePage(name, force: hasForce);
      }
      break;
    case 'controller':
      generateController(name, force: hasForce);
      break;
    case 'model':
      if (hasFreezed) {
        generateFreezedModel(name, force: hasForce);
      } else {
        generateModel(name, force: hasForce);
      }
      break;
    case 'widget':
      generateWidget(name, force: hasForce);
      break;
    case 'repository':
      _printError('For repository, use: repository:<name> on <page>');
      break;
    default:
      _printError('Unknown command: $type');
      _printUsage();
      exit(1);
  }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Print basic usage
void _printUsage() {
  print('Usage: dart generate.dart <command>:<name> [options]');
  print('');
  print('Run "dart generate.dart --help" for more information.');
}

/// Print full help
void _printHelp() {
  print('''
$appName v$version
=====================

A powerful code generator for Flutter projects using GetX pattern.

USAGE:
  dart generate.dart <command>:<name> [options]

COMMANDS:
  init                           Initialize project structure
  page:<name>                    Generate a full feature page
  page:<name> --presentation-only Generate page without data/domain layers
  controller:<name>              Generate a standalone controller
  model:<name>                   Generate a basic model
  model:<name> --freezed         Generate a Freezed model
  widget:<name>                  Generate a reusable widget
  service:<name>                 Generate a core service
  screen <name> on <page>        Generate a screen inside a page
  repository:<name> on <page>    Generate a repository for a page
  usecase:<name> on <page>       Generate a usecase for a page
  entity:<name> on <page>        Generate an entity for a page
  delete:page:<name>             Delete a page and update routes
  list                           List all available pages

OPTIONS:
  --force, -f      Overwrite existing files
  --help, -h       Show this help message
  --version, -v    Show version number

EXAMPLES:
  dart generate.dart init
  dart generate.dart page:home
  dart generate.dart page:auth.login
  dart generate.dart screen dashboard on home
  dart generate.dart repository:user on home
  dart generate.dart model:user --freezed
  dart generate.dart delete:page:home

STRUCTURE:
  lib/apps/
  ├── features/<page_name>/
  │   ├── data/
  │   │   ├── datasource/
  │   │   ├── models/
  │   │   └── repositories/
  │   ├── domain/
  │   │   ├── entities/
  │   │   ├── repositories/
  │   │   └── usecase/
  │   └── presentation/
  │       ├── binding/
  │       ├── controller/
  │       └── view/
  │           └── screen/
  ├── routes/
  ├── core/
  ├── widget/
  └── controller/
''');
}

/// Validate name input
bool _validateName(String name) {
  if (name.isEmpty) {
    _printError('Name cannot be empty');
    return false;
  }

  // Allow dot notation for nested pages (e.g., settings.profile)
  final validPattern = RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$');
  if (!validPattern.hasMatch(name)) {
    _printError(
      'Invalid name "$name". Use lowercase letters, numbers, and dots only. '
      'Must start with a letter. Example: home, user_profile, settings.general',
    );
    return false;
  }

  return true;
}

/// Print error message
void _printError(String message) {
  print('❌ ERROR: $message');
}

/// Print success message
void _printSuccess(String message) {
  print('✅ $message');
}

/// Print info message
void _printInfo(String message) {
  print('ℹ️  $message');
}

/// Convert to CamelCase (handles dot notation)
String toCamelCase(String input) {
  if (input.isEmpty) return input;

  if (input.contains('.')) {
    final parts = input.split('.');
    return parts.map((part) => _capitalize(part)).join();
  }

  // Handle snake_case
  if (input.contains('_')) {
    final parts = input.split('_');
    return parts.map((part) => _capitalize(part)).join();
  }

  return _capitalize(input);
}

/// Capitalize first letter
String _capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

/// Convert to snake_case
String toSnakeCase(String input) {
  if (input.isEmpty) return input;

  if (input.contains('.')) {
    return input.replaceAll('.', '_');
  }
  return input;
}

/// Safe file write with error handling
bool safeWriteFile(String path, String content, {bool force = false}) {
  try {
    final file = File(path);

    if (file.existsSync() && !force) {
      _printInfo('File already exists: $path (use --force to overwrite)');
      return false;
    }

    // Ensure parent directory exists
    final parent = file.parent;
    if (!parent.existsSync()) {
      parent.createSync(recursive: true);
    }

    file.writeAsStringSync(content);
    print('  📄 Generated: $path');
    return true;
  } catch (e) {
    _printError('Failed to write file: $path - $e');
    return false;
  }
}

/// Safe directory create
bool safeCreateDir(String path) {
  try {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      print('  📁 Created: $path');
    }
    return true;
  } catch (e) {
    _printError('Failed to create directory: $path - $e');
    return false;
  }
}

/// Check if page exists
bool pageExists(String pageName) {
  final pageFileName = toSnakeCase(pageName);
  final pageDir = Directory('lib/apps/features/$pageFileName');
  return pageDir.existsSync();
}

/// List available pages
void _listPages() {
  final featuresDir = Directory('lib/apps/features');
  if (!featuresDir.existsSync()) {
    _printInfo(
      'No pages found. Run "dart generate.dart page:home" to create one.',
    );
    return;
  }

  final directories = featuresDir.listSync().whereType<Directory>();
  if (directories.isEmpty) {
    _printInfo('No pages found.');
    return;
  }

  print('📋 Available pages:');
  for (final dir in directories) {
    final name = dir.path.split('/').last;
    print('   • $name');
  }
}

// ============================================================================
// GENERATORS
// ============================================================================

/// Generate full page with clean architecture
void generatePage(String name, {bool force = false}) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  print('');
  print('🚀 Generating page: $className');
  print('─' * 50);

  // View content
  final viewContent =
      '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/${fileName}_controller.dart';

class ${className}View extends GetView<${className}Controller> {
  const ${className}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$className'.tr),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.error.value!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.retry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const SafeArea(
          child: Center(
            child: Text(
              '${className}View is working',
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      }),
    );
  }
}
''';

  // Controller content
  final controllerContent =
      '''
import 'package:get/get.dart';

class ${className}Controller extends GetxController {
  // State
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      // TODO: Load data from usecase
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retry() async {
    await _loadData();
  }

  @override
  void onClose() {
    // TODO: Dispose resources
    super.onClose();
  }
}
''';

  // Binding content
  final bindingContent =
      '''
import 'package:get/get.dart';

import '../controller/${fileName}_controller.dart';

class ${className}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${className}Controller>(
      () => ${className}Controller(),
    );
  }
}
''';

  // Create directories
  final basePath = 'lib/apps/features/$fileName';
  final directories = [
    '$basePath/presentation/view',
    '$basePath/presentation/view/screen',
    '$basePath/presentation/controller',
    '$basePath/presentation/binding',
    '$basePath/data/datasource',
    '$basePath/data/models',
    '$basePath/data/repositories',
    '$basePath/domain/entities',
    '$basePath/domain/repositories',
    '$basePath/domain/usecase',
  ];

  for (final dir in directories) {
    safeCreateDir(dir);
  }

  // Write files
  safeWriteFile(
    '$basePath/presentation/view/${fileName}_view.dart',
    viewContent,
    force: force,
  );
  safeWriteFile(
    '$basePath/presentation/controller/${fileName}_controller.dart',
    controllerContent,
    force: force,
  );
  safeWriteFile(
    '$basePath/presentation/binding/${fileName}_binding.dart',
    bindingContent,
    force: force,
  );

  // Generate usecase, repository, datasource
  generateUsecaseInternal(name, name);
  generateRepositoryInternal(name, name);
  generateDatasource(name, name);

  // Update routes
  updateRoutes(className, fileName);

  print('─' * 50);
  _printSuccess('Page "$className" created successfully!');
  print('');
}

/// Generate page presentation only (no data/domain layers)
void generatePagePresentationOnly(String name, {bool force = false}) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  print('');
  print('🚀 Generating page (presentation only): $className');
  print('─' * 50);

  final viewContent =
      '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/${fileName}_controller.dart';

class ${className}View extends GetView<${className}Controller> {
  const ${className}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$className'.tr),
        centerTitle: true,
      ),
      body: const SafeArea(
        child: Center(
          child: Text(
            '${className}View is working',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
''';

  final controllerContent =
      '''
import 'package:get/get.dart';

class ${className}Controller extends GetxController {
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
}
''';

  final bindingContent =
      '''
import 'package:get/get.dart';

import '../controller/${fileName}_controller.dart';

class ${className}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${className}Controller>(
      () => ${className}Controller(),
    );
  }
}
''';

  final basePath = 'lib/apps/features/$fileName';
  final directories = [
    '$basePath/presentation/view',
    '$basePath/presentation/view/screen',
    '$basePath/presentation/controller',
    '$basePath/presentation/binding',
  ];

  for (final dir in directories) {
    safeCreateDir(dir);
  }

  safeWriteFile(
    '$basePath/presentation/view/${fileName}_view.dart',
    viewContent,
    force: force,
  );
  safeWriteFile(
    '$basePath/presentation/controller/${fileName}_controller.dart',
    controllerContent,
    force: force,
  );
  safeWriteFile(
    '$basePath/presentation/binding/${fileName}_binding.dart',
    bindingContent,
    force: force,
  );

  updateRoutes(className, fileName);

  print('─' * 50);
  _printSuccess('Page "$className" (presentation only) created successfully!');
  print('');
}

/// Generate screen on existing page
void generateScreenOnPage(String screenName, String pageName) {
  final screenClassName = toCamelCase(screenName);
  final screenFileName = toSnakeCase(screenName);
  final pageFileName = toSnakeCase(pageName);
  final pageClassName = toCamelCase(pageName);

  if (!pageExists(pageName)) {
    _printError('Page "$pageName" does not exist!');
    print('Create it first: dart generate.dart page:$pageName');
    _listPages();
    exit(1);
  }

  print('');
  print('🚀 Generating screen: $screenClassName on $pageClassName');
  print('─' * 50);

  final screenDir = 'lib/apps/features/$pageFileName/presentation/view/screen';
  safeCreateDir(screenDir);

  final screenContent =
      '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/${pageFileName}_controller.dart';

class ${screenClassName}Screen extends GetView<${pageClassName}Controller> {
  const ${screenClassName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('${screenClassName}Screen is working'),
      ),
    );
  }
}
''';

  safeWriteFile('$screenDir/${screenFileName}_screen.dart', screenContent);

  print('─' * 50);
  _printSuccess('Screen "$screenClassName" created on page "$pageClassName"!');
  print('');
}

/// Generate standalone controller
void generateController(String name, {bool force = false}) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  print('');
  print('🚀 Generating controller: ${className}Controller');
  print('─' * 50);

  final content =
      '''
import 'package:get/get.dart';

class ${className}Controller extends GetxController {
  // State
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    // TODO: Initialize
  }

  @override
  void onClose() {
    // TODO: Dispose resources
    super.onClose();
  }
}
''';

  safeCreateDir('lib/apps/controller');
  safeWriteFile(
    'lib/apps/controller/${fileName}_controller.dart',
    content,
    force: force,
  );

  print('─' * 50);
  _printSuccess('Controller "${className}Controller" created!');
  print('');
}

/// Generate model
void generateModel(String name, {bool force = false}) {
  final className = '${toCamelCase(name)}Model';
  final fileName = '${toSnakeCase(name)}_model';

  print('');
  print('🚀 Generating model: $className');
  print('─' * 50);

  final content =
      '''
class $className {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const $className({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory $className.fromJson(Map<String, dynamic> json) {
    return $className(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Copy with new values
  $className copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return $className(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is $className && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$className(id: \$id, name: \$name)';
}
''';

  safeCreateDir('lib/apps/data/model');
  safeWriteFile('lib/apps/data/model/$fileName.dart', content, force: force);

  print('─' * 50);
  _printSuccess('Model "$className" created!');
  print('');
}

/// Generate Freezed model
void generateFreezedModel(String name, {bool force = false}) {
  final className = '${toCamelCase(name)}Model';
  final fileName = '${toSnakeCase(name)}_model';

  print('');
  print('🚀 Generating Freezed model: $className');
  print('─' * 50);

  final content =
      '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${fileName}.freezed.dart';
part '${fileName}.g.dart';

@freezed
class $className with _\$${className} {
  const factory $className({
    required int id,
    required String name,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _$className;

  factory $className.fromJson(Map<String, dynamic> json) =>
      _\$${className}FromJson(json);
}
''';

  safeCreateDir('lib/apps/data/model');
  safeWriteFile('lib/apps/data/model/$fileName.dart', content, force: force);

  print('');
  _printInfo(
    'Run: flutter pub run build_runner build --delete-conflicting-outputs',
  );
  print('─' * 50);
  _printSuccess('Freezed model "$className" created!');
  print('');
}

/// Generate widget
void generateWidget(String name, {bool force = false}) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  print('');
  print('🚀 Generating widget: ${className}Widget');
  print('─' * 50);

  final content =
      '''
import 'package:flutter/material.dart';

class ${className}Widget extends StatelessWidget {
  const ${className}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      child: Text('$className Widget'),
    );
  }
}
''';

  safeCreateDir('lib/apps/widget');
  safeWriteFile(
    'lib/apps/widget/${fileName}_widget.dart',
    content,
    force: force,
  );

  print('─' * 50);
  _printSuccess('Widget "${className}Widget" created!');
  print('');
}

/// Generate service
void generateService(String name, {bool force = false}) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  print('');
  print('🚀 Generating service: ${className}Service');
  print('─' * 50);

  final content =
      '''
import 'package:get/get.dart';

class ${className}Service extends GetxService {
  static ${className}Service get to => Get.find<${className}Service>();

  Future<${className}Service> init() async {
    // TODO: Initialize service
    return this;
  }

  @override
  void onClose() {
    // TODO: Cleanup
    super.onClose();
  }
}
''';

  safeCreateDir('lib/apps/core/services');
  safeWriteFile(
    'lib/apps/core/services/${fileName}_service.dart',
    content,
    force: force,
  );

  print('');
  _printInfo(
    'Register in main.dart: await Get.putAsync(() => ${className}Service().init());',
  );
  print('─' * 50);
  _printSuccess('Service "${className}Service" created!');
  print('');
}

/// Generate repository on page
void generateRepositoryOnPage(String repoName, String pageName) {
  final repoClassName = toCamelCase(repoName);
  final repoFileName = toSnakeCase(repoName);
  final pageFileName = toSnakeCase(pageName);

  if (!pageExists(pageName)) {
    _printError('Page "$pageName" does not exist!');
    print('Create it first: dart generate.dart page:$pageName');
    _listPages();
    exit(1);
  }

  print('');
  print('🚀 Generating repository: ${repoClassName}Repository on $pageName');
  print('─' * 50);

  final domainRepoDir = 'lib/apps/features/$pageFileName/domain/repositories';
  final dataRepoDir = 'lib/apps/features/$pageFileName/data/repositories';

  safeCreateDir(domainRepoDir);
  safeCreateDir(dataRepoDir);

  // Abstract repository
  final abstractContent =
      '''
abstract class ${repoClassName}Repository {
  // TODO: Define contract methods
  // Example:
  // Future<Either<Failure, List<Entity>>> getAll();
  // Future<Either<Failure, Entity>> getById(int id);
}
''';

  // Implementation
  final implContent =
      '''
import '../../domain/repositories/${repoFileName}_repository.dart';

class ${repoClassName}RepositoryImpl implements ${repoClassName}Repository {
  // final ${repoClassName}NetworkDatasource _network;
  // final ${repoClassName}OfflineDatasource _offline;

  ${repoClassName}RepositoryImpl();

  // TODO: Implement repository methods
}
''';

  safeWriteFile(
    '$domainRepoDir/${repoFileName}_repository.dart',
    abstractContent,
  );
  safeWriteFile(
    '$dataRepoDir/${repoFileName}_repository_impl.dart',
    implContent,
  );

  print('');
  _printInfo(
    'Add to binding: Get.lazyPut<${repoClassName}Repository>(() => ${repoClassName}RepositoryImpl());',
  );
  print('─' * 50);
  _printSuccess(
    'Repository "${repoClassName}Repository" created on "$pageName"!',
  );
  print('');
}

/// Generate usecase on page
void generateUsecaseOnPage(String usecaseName, String pageName) {
  final usecaseClassName = toCamelCase(usecaseName);
  final usecaseFileName = toSnakeCase(usecaseName);
  final pageFileName = toSnakeCase(pageName);

  if (!pageExists(pageName)) {
    _printError('Page "$pageName" does not exist!');
    print('Create it first: dart generate.dart page:$pageName');
    _listPages();
    exit(1);
  }

  print('');
  print('🚀 Generating usecase: ${usecaseClassName}Usecase on $pageName');
  print('─' * 50);

  final usecaseDir = 'lib/apps/features/$pageFileName/domain/usecase';
  safeCreateDir(usecaseDir);

  final content =
      '''
// import '../repositories/${usecaseFileName}_repository.dart';

class ${usecaseClassName}Usecase {
  // final ${usecaseClassName}Repository _repo;

  ${usecaseClassName}Usecase();

  Future<void> call() async {
    // TODO: Implement usecase logic
  }
}
''';

  safeWriteFile('$usecaseDir/${usecaseFileName}_usecase.dart', content);

  print('─' * 50);
  _printSuccess('Usecase "${usecaseClassName}Usecase" created on "$pageName"!');
  print('');
}

/// Generate entity on page
void generateEntityOnPage(String entityName, String pageName) {
  final entityClassName = toCamelCase(entityName);
  final entityFileName = toSnakeCase(entityName);
  final pageFileName = toSnakeCase(pageName);

  if (!pageExists(pageName)) {
    _printError('Page "$pageName" does not exist!');
    print('Create it first: dart generate.dart page:$pageName');
    _listPages();
    exit(1);
  }

  print('');
  print('🚀 Generating entity: ${entityClassName}Entity on $pageName');
  print('─' * 50);

  final entityDir = 'lib/apps/features/$pageFileName/domain/entities';
  safeCreateDir(entityDir);

  final content =
      '''
class ${entityClassName}Entity {
  final int id;
  final String name;

  const ${entityClassName}Entity({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ${entityClassName}Entity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '${entityClassName}Entity(id: \$id, name: \$name)';
}
''';

  safeWriteFile('$entityDir/${entityFileName}_entity.dart', content);

  print('─' * 50);
  _printSuccess('Entity "${entityClassName}Entity" created on "$pageName"!');
  print('');
}

/// Internal usecase generator (used by page generator)
void generateUsecaseInternal(String name, String pageName) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);
  final pageFileName = toSnakeCase(pageName);

  final content =
      '''
import '../repositories/${fileName}_repository.dart';

class ${className}Usecase {
  final ${className}Repository _repo;

  ${className}Usecase(this._repo);

  Future<void> call() async {
    // TODO: Implement usecase logic
  }
}
''';

  final dir = 'lib/apps/features/$pageFileName/domain/usecase';
  safeCreateDir(dir);
  safeWriteFile('$dir/${fileName}_usecase.dart', content);
}

/// Internal repository generator
void generateRepositoryInternal(String name, String pageName) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);
  final pageFileName = toSnakeCase(pageName);

  final abstractContent =
      '''
abstract class ${className}Repository {
  // TODO: Define contract methods
}
''';

  final implContent =
      '''
import '../../domain/repositories/${fileName}_repository.dart';
import '../datasource/${fileName}_network_datasource.dart';
import '../datasource/${fileName}_offline_datasource.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  final ${className}NetworkDatasource _network;
  final ${className}OfflineDatasource _offline;

  ${className}RepositoryImpl(this._network, this._offline);

  // TODO: Implement repository methods
}
''';

  final domainDir = 'lib/apps/features/$pageFileName/domain/repositories';
  final dataDir = 'lib/apps/features/$pageFileName/data/repositories';

  safeCreateDir(domainDir);
  safeCreateDir(dataDir);

  safeWriteFile('$domainDir/${fileName}_repository.dart', abstractContent);
  safeWriteFile('$dataDir/${fileName}_repository_impl.dart', implContent);
}

/// Generate datasource
void generateDatasource(String name, String pageName) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);
  final pageFileName = toSnakeCase(pageName);

  final networkContent =
      '''
class ${className}NetworkDatasource {
  // final Dio _dio;
  
  ${className}NetworkDatasource();

  // TODO: Implement remote API calls
}
''';

  final offlineContent =
      '''
class ${className}OfflineDatasource {
  // final SharedPreferences _prefs;
  
  ${className}OfflineDatasource();

  // TODO: Implement local storage
}
''';

  final dir = 'lib/apps/features/$pageFileName/data/datasource';
  safeCreateDir(dir);

  safeWriteFile('$dir/${fileName}_network_datasource.dart', networkContent);
  safeWriteFile('$dir/${fileName}_offline_datasource.dart', offlineContent);
}

/// Update routes
void updateRoutes(String className, String fileName) {
  final routesDir = 'lib/apps/routes';
  safeCreateDir(routesDir);

  // Update route_names.dart
  final routeNamesFile = File('$routesDir/route_names.dart');
  final routeConstant = fileName.toUpperCase();

  if (!routeNamesFile.existsSync()) {
    final content =
        '''
// ignore_for_file: constant_identifier_names

abstract class RouteNames {
  static const String $routeConstant = '/$fileName';
}
''';
    routeNamesFile.writeAsStringSync(content);
    print('  📄 Generated: ${routeNamesFile.path}');
  } else {
    var content = routeNamesFile.readAsStringSync();
    if (!content.contains('static const String $routeConstant')) {
      // Find the closing brace of the class
      final lastBraceIndex = content.lastIndexOf('}');
      if (lastBraceIndex != -1) {
        final newRoute =
            "  static const String $routeConstant = '/$fileName';\n";
        content = content.replaceRange(
          lastBraceIndex,
          lastBraceIndex,
          newRoute,
        );
        routeNamesFile.writeAsStringSync(content);
        print('  📝 Updated: ${routeNamesFile.path}');
      }
    }
  }

  // Update route_app.dart
  final routeAppFile = File('$routesDir/route_app.dart');

  if (!routeAppFile.existsSync()) {
    final content =
        '''
import 'package:get/get.dart';

import 'route_names.dart';
import '../features/$fileName/presentation/binding/${fileName}_binding.dart';
import '../features/$fileName/presentation/view/${fileName}_view.dart';

class RouteApp {
  static final routes = [
    GetPage(
      name: RouteNames.$routeConstant,
      page: () => const ${className}View(),
      binding: ${className}Binding(),
    ),
  ];
}
''';
    routeAppFile.writeAsStringSync(content);
    print('  📄 Generated: ${routeAppFile.path}');
  } else {
    var content = routeAppFile.readAsStringSync();

    if (!content.contains('${className}View')) {
      // Add imports
      final viewImport =
          "import '../features/$fileName/presentation/view/${fileName}_view.dart';";
      final bindingImport =
          "import '../features/$fileName/presentation/binding/${fileName}_binding.dart';";

      // Find position after last import
      final importPattern = RegExp(r"import '[^']+';");
      final matches = importPattern.allMatches(content).toList();

      if (matches.isNotEmpty) {
        final lastImportEnd = matches.last.end;
        final imports = '\n$bindingImport\n$viewImport';

        // Check if imports already exist
        if (!content.contains(viewImport)) {
          content = content.replaceRange(lastImportEnd, lastImportEnd, imports);
        }
      }

      // Add route entry
      final routesArrayEnd = content.lastIndexOf('];');
      if (routesArrayEnd != -1) {
        final routeEntry =
            '''
    GetPage(
      name: RouteNames.$routeConstant,
      page: () => const ${className}View(),
      binding: ${className}Binding(),
    ),
  ''';
        content = content.replaceRange(
          routesArrayEnd,
          routesArrayEnd,
          routeEntry,
        );
      }

      routeAppFile.writeAsStringSync(content);
      print('  📝 Updated: ${routeAppFile.path}');
    }
  }
}

/// Handle delete command
void _handleDelete(String type, String name) {
  switch (type) {
    case 'page':
      _deletePage(name);
      break;
    default:
      _printError('Delete not supported for: $type');
      print('Supported: delete:page:<name>');
  }
}

/// Delete a page
void _deletePage(String name) {
  final fileName = toSnakeCase(name);
  final className = toCamelCase(name);
  final pageDir = Directory('lib/apps/features/$fileName');

  if (!pageDir.existsSync()) {
    _printError('Page "$name" does not exist!');
    _listPages();
    return;
  }

  print('');
  print('🗑️  Deleting page: $className');
  print('─' * 50);

  // Confirm deletion
  stdout.write('Are you sure you want to delete "$className"? (y/N): ');
  final response = stdin.readLineSync()?.toLowerCase() ?? 'n';

  if (response != 'y' && response != 'yes') {
    print('Cancelled.');
    return;
  }

  // Delete directory
  try {
    pageDir.deleteSync(recursive: true);
    print('  🗑️  Deleted: ${pageDir.path}');
  } catch (e) {
    _printError('Failed to delete page directory: $e');
    return;
  }

  // Update route_names.dart
  final routeNamesFile = File('lib/apps/routes/route_names.dart');
  if (routeNamesFile.existsSync()) {
    var content = routeNamesFile.readAsStringSync();
    final routePattern = RegExp(
      "\\s*static const String ${fileName.toUpperCase()} = '[^']+';\\n?",
    );
    content = content.replaceAll(routePattern, '');
    routeNamesFile.writeAsStringSync(content);
    print('  📝 Updated: ${routeNamesFile.path}');
  }

  // Update route_app.dart
  final routeAppFile = File('lib/apps/routes/route_app.dart');
  if (routeAppFile.existsSync()) {
    var content = routeAppFile.readAsStringSync();

    // Remove imports
    final viewImportPattern = RegExp(
      "import '../features/$fileName/presentation/view/${fileName}_view.dart';\\n?",
    );
    final bindingImportPattern = RegExp(
      "import '../features/$fileName/presentation/binding/${fileName}_binding.dart';\\n?",
    );
    content = content.replaceAll(viewImportPattern, '');
    content = content.replaceAll(bindingImportPattern, '');

    // Remove GetPage entry
    final pagePattern = RegExp(
      "\\s*GetPage\\(\\s*name: RouteNames\\.${fileName.toUpperCase()},\\s*page: \\(\\) => const ${className}View\\(\\),\\s*binding: ${className}Binding\\(\\),\\s*\\),?",
      multiLine: true,
    );
    content = content.replaceAll(pagePattern, '');

    routeAppFile.writeAsStringSync(content);
    print('  📝 Updated: ${routeAppFile.path}');
  }

  print('─' * 50);
  _printSuccess('Page "$className" deleted!');
  print('');
}

// ============================================================================
// INIT COMMAND
// ============================================================================

/// Initialize project structure
void _cmdInit(List<String> args) {
  print('');
  print('🚀 Initializing GetX project structure');
  print('─' * 50);

  // Parse optional --pkg flag
  String pkgName = 'yo_ui';
  String pkgUrl = 'https://github.com/cahyo40/youi.git';

  final pkgOpt = args.firstWhere(
    (a) => a.startsWith('--pkg='),
    orElse: () => '',
  );
  if (pkgOpt.isNotEmpty && pkgOpt.contains('=')) {
    final raw = pkgOpt.split('=').last;
    final split = raw.split(':');
    if (split.length >= 2) {
      pkgName = split[0];
      pkgUrl = split.sublist(1).join(':'); // Handle URL with colons
    } else {
      _printInfo('Format --pkg=name:url not valid, using defaults');
    }
  }

  // Create folders
  final folders = [
    'lib/apps/features',
    'lib/apps/routes',
    'lib/apps/controller',
    'lib/apps/widget',
    'lib/apps/data/model',
    'lib/apps/core/error',
    'lib/apps/core/network',
    'lib/apps/core/utils',
    'lib/apps/core/theme',
    'lib/apps/core/services',
    'lib/apps/core/constants',
    'test/unit',
    'test/widget',
    'integration_test',
    'assets/images',
    'assets/fonts',
    'assets/icons',
  ];

  for (final f in folders) {
    safeCreateDir(f);
  }

  // Create skeleton files
  _createSkeletonFiles(pkgName);

  // Inject dependencies to pubspec
  _injectDepsToPubspec(pkgName: pkgName, pkgUrl: pkgUrl);

  // Create .gitignore additions
  _updateGitignore();

  // Create analysis_options.yaml if not exists
  _createAnalysisOptions();

  print('─' * 50);
  _printSuccess('Project initialized!');
  print('');
  print('📋 Next steps:');
  print('   1. flutter pub get');
  print('   2. dart generate.dart page:home');
  print('   3. flutter run');
  print('');
}

void _createSkeletonFiles(String pkgName) {
  // Failure class
  safeWriteFile('lib/apps/core/error/failure.dart', '''
abstract class Failure {
  final String message;
  final int? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  String toString() => 'Failure: \$message (code: \$code)';
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
''');

  // API Constants
  safeWriteFile('lib/apps/core/network/api_constants.dart', '''
abstract class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const Duration timeout = Duration(seconds: 30);
  
  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
}
''');

  // App Constants
  safeWriteFile('lib/apps/core/constants/app_constants.dart', '''
abstract class AppConstants {
  static const String appName = 'MyApp';
  static const String appVersion = '1.0.0';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
}
''');

  // App Theme
  safeWriteFile('lib/apps/core/theme/app_theme.dart', '''
import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );
}
''');

  // Route names
  safeWriteFile('lib/apps/routes/route_names.dart', '''
// ignore_for_file: constant_identifier_names

abstract class RouteNames {
  static const String HOME = '/home';
}
''');

  // Main.dart
  safeWriteFile('lib/main.dart', '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'apps/routes/route_app.dart';
import 'apps/routes/route_names.dart';
import 'apps/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize services here
  // await Get.putAsync(() => StorageService().init());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MyApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: RouteNames.HOME,
      getPages: RouteApp.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}
''');
}

void _injectDepsToPubspec({required String pkgName, required String pkgUrl}) {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    _printError('pubspec.yaml not found');
    return;
  }

  final lines = file.readAsLinesSync();
  final buf = StringBuffer();

  bool inDeps = false;
  final needed = <String, String>{
    'get': '^4.6.6',
    'dio': '^5.4.0',
    'internet_connection_checker': '^1.0.0+1',
    'shared_preferences': '^2.2.2',
    'flutter_screenutil': '^5.9.0',
  };
  final pkgGitLines = ['  $pkgName:', '    git:', '      url: $pkgUrl'];

  for (final l in lines) {
    final trim = l.trim();

    if (trim == 'dependencies:') {
      inDeps = true;
    }
    if (inDeps && trim.startsWith('dev_dependencies:')) {
      inDeps = false;
    }

    // Skip if already exists
    if (needed.keys.any((k) => trim.startsWith('$k:'))) continue;
    if (trim.startsWith('$pkgName:')) continue;

    buf.writeln(l);

    // Insert after dependencies:
    if (trim == 'dependencies:') {
      needed.forEach((k, v) => buf.writeln('  $k: $v'));
      pkgGitLines.forEach(buf.writeln);
    }
  }

  file.writeAsStringSync(buf.toString());
  print('  📝 Updated: pubspec.yaml');
}

void _updateGitignore() {
  final content = '''

# === GetX Generator ===
*.freezed.dart
*.g.dart
*.gr.dart
build/
.env
.env.*
/android/app/google-services.json
/ios/Runner/GoogleService-Info.plist
''';

  final file = File('.gitignore');
  if (file.existsSync()) {
    final existing = file.readAsStringSync();
    if (!existing.contains('GetX Generator')) {
      file.writeAsStringSync(content, mode: FileMode.append);
      print('  📝 Updated: .gitignore');
    }
  } else {
    file.writeAsStringSync(content);
    print('  📄 Generated: .gitignore');
  }
}

void _createAnalysisOptions() {
  final file = File('analysis_options.yaml');
  if (file.existsSync()) return;

  final content = '''
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_fields: true
    prefer_final_locals: true
    avoid_print: true
    prefer_single_quotes: true
    sort_constructors_first: true
    sort_unnamed_constructors_first: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gr.dart"
  errors:
    invalid_annotation_target: ignore
''';

  file.writeAsStringSync(content);
  print('  📄 Generated: analysis_options.yaml');
}
