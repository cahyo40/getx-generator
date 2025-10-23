// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart generate.dart <command>:<name>');
    print('Available commands: page, controller, model, widget');
    exit(1);
  }
  // handle perintah screen
  if (arguments[0] == 'screen' &&
      arguments.length >= 4 &&
      arguments[2] == 'on') {
    final screenName = arguments[1];
    final pageName = arguments[3];
    generateScreenOnPage(screenName, pageName);
    return;
  }

  if (arguments[0] == 'init') {
    _cmdInit(arguments);
    generatePage("home");
    return;
  }

  // Handle perintah repository dengan format khusus
  if (arguments[0].startsWith('repository:') &&
      arguments.length >= 3 &&
      arguments[1] == 'on') {
    final repoParts = arguments[0].split(':');
    if (repoParts.length != 2) {
      print(
        'Invalid repository format. Use: repository:<repo_name> on <page_name>',
      );
      exit(1);
    }

    final repoName = repoParts[1];
    final pageName = arguments[2];
    generateRepositoryOnPage(repoName, pageName);
    return;
  }

  final command = arguments[0];
  final parts = command.split(':');

  if (parts.length != 2) {
    print('Invalid command format. Use: <command>:<name>');
    exit(1);
  }

  /* ---------- init ---------- */

  final type = parts[0];
  final name = parts[1];

  switch (type) {
    case 'page':
      if (arguments.contains('--presentation-only')) {
        generatePagePresentationOnly(name);
      } else {
        generatePage(name);
      }
      break;
    case 'controller':
      generateController(name);
      break;
    case 'model':
      generateModel(name);
      break;
    case 'widget':
      generateWidget(name);
      break;
    case 'repository':
      print('For repository, use: repository:<repo_name> on <page_name>');
      break;
    default:
      print('Unknown command: $type');
      print('Available commands: page, controller, model, widget');
      exit(1);
  }
}

String toCamelCase(String input) {
  if (input.contains('.')) {
    final parts = input.split('.');
    return parts
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join();
  }
  return input[0].toUpperCase() + input.substring(1);
}

String toSnakeCase(String input) {
  if (input.contains('.')) {
    return input.replaceAll('.', '_');
  }
  return input;
}

extension on File {
  void printCreated() => print('Generated: $path');
}

void generatePage(String name) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  // Generate view file
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
          title: Text('${className}View'.tr),
          centerTitle: true,
        ),
        body: const SafeArea(
          child: Text(
            '${className}View is working',
            style: TextStyle(fontSize: 20),
          ),
        ),
    );
  }
}
''';

  // Generate controller file
  final controllerContent =
      '''
import 'package:get/get.dart';

class ${className}Controller extends GetxController {
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
}
''';

  // Generate binding file
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
  final viewDir = Directory('$basePath/presentation/view');
  final controllerDir = Directory('$basePath/presentation/controller');
  final bindingDir = Directory('$basePath/presentation/binding');
  final datasourceDir = Directory('$basePath/data/datasource');
  final modelsDir = Directory('$basePath/data/models');
  final repositoriesDir = Directory('$basePath/data/repositories');
  final entitiesDir = Directory('$basePath/domain/entities');
  final domainRepositoriesDir = Directory('$basePath/domain/repositories');
  final usecaseDir = Directory('$basePath/domain/usecase');
  final screenDir = Directory(
    '$basePath/presentation/view/screen',
  ); // Tambah folder screen

  final directories = [
    viewDir,
    screenDir,
    controllerDir,
    bindingDir,
    datasourceDir,
    modelsDir,
    repositoriesDir,
    entitiesDir,
    domainRepositoriesDir,
    usecaseDir,
  ];

  for (final dir in directories) {
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      print('Created directory: ${dir.path}');
    }
  }

  // Write files
  final viewFile = File('${viewDir.path}/${fileName}_view.dart');
  final controllerFile = File(
    '${controllerDir.path}/${fileName}_controller.dart',
  );
  final bindingFile = File('${bindingDir.path}/${fileName}_binding.dart');

  viewFile.writeAsStringSync(viewContent);
  controllerFile.writeAsStringSync(controllerContent);
  bindingFile.writeAsStringSync(bindingContent);

  print('Generated view: ${viewFile.path}');
  print('Generated controller: ${controllerFile.path}');
  print('Generated binding: ${bindingFile.path}');

  // Generate usecase, repository, datasource
  generateUsecase(name, name);
  generateRepository(name, name);
  generateDatasource(name, name);

  // Update routes
  updateRoutes(className, fileName);
}

void generateController(String name) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  final content =
      '''
import 'package:get/get.dart';

class ${className}Controller extends GetxController {
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
}
''';

  final dir = Directory('lib/apps/controller');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final file = File('${dir.path}/${fileName}_controller.dart');
  file.writeAsStringSync(content);
  print('Generated controller: ${file.path}');
}

void generateModel(String name) {
  final className = "${toCamelCase(name)}Model";
  final fileName = "${toSnakeCase(name)}_model";

  final content =
      '''
class $className {
  final int id;
  final String name;

  $className({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory $className.fromMap(Map<String, dynamic> map) {
    return $className(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}
''';

  final dir = Directory('lib/apps/data/model');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final file = File('${dir.path}/$fileName.dart');
  file.writeAsStringSync(content);
  print('Generated model: ${file.path}');
}

void generateScreenOnPage(String screenName, String pageName) {
  final screenClassName = toCamelCase(screenName);
  final screenFileName = toSnakeCase(screenName);
  final pageFileName = toSnakeCase(pageName);

  // Cek apakah folder page exists
  final pageDir = Directory('lib/apps/features/$pageFileName');
  if (!pageDir.existsSync()) {
    print('❌ ERROR: Page "$pageName" does not exist!');
    print(
      'Please create the page first using: dart generate.dart page:$pageName',
    );
    print('Available pages:');

    // List available pages
    final featuresDir = Directory('lib/apps/features');
    if (featuresDir.existsSync()) {
      final directories = featuresDir.listSync();
      for (final dir in directories) {
        if (dir is Directory) {
          print('  - ${dir.path.split('/').last}');
        }
      }
    }

    exit(1);
  }

  // Cek apakah folder screen sudah ada
  final screenDir = Directory(
    'lib/apps/features/$pageFileName/presentation/view/screen',
  );
  if (!screenDir.existsSync()) {
    screenDir.createSync(recursive: true);
    print('Created directory: ${screenDir.path}');
  }

  // Generate screen content
  final screenContent =
      '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/${pageFileName}_controller.dart';

class ${screenClassName}Screen extends GetView<${toCamelCase(pageName)}Controller> {
  const ${screenClassName}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Text('${screenClassName}Screen is working'),
    );
  }
}
''';

  // Write screen file
  final screenFile = File('${screenDir.path}/${screenFileName}_screen.dart');
  screenFile.writeAsStringSync(screenContent);

  print('✅ Generated screen: ${screenFile.path}');
  print(
    '📁 Location: lib/apps/features/$pageFileName/presentation/view/screen/',
  );
  print(
    '🎉 Screen "$screenClassName" successfully created on page "$pageName"',
  );
}

void generateWidget(String name) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  final content =
      '''
import 'package:flutter/material.dart';

class ${className}Widget extends StatelessWidget {
  const ${className}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: const Text('$className Widget'),
    );
  }
}
''';

  final dir = Directory('lib/apps/widget');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final file = File('${dir.path}/${fileName}_widget.dart');
  file.writeAsStringSync(content);
  print('Generated widget: ${file.path}');
}

void updateRoutes(String className, String fileName) {
  // Create routes directory if not exists
  final routesDir = Directory('lib/apps/routes');
  if (!routesDir.existsSync()) {
    routesDir.createSync(recursive: true);
  }

  // Update route_names.dart
  final routeNamesFile = File('${routesDir.path}/route_names.dart');
  if (!routeNamesFile.existsSync()) {
    routeNamesFile.writeAsStringSync('''
// ignore_for_file: constant_identifier_names
abstract class RouteNames {
  static const String ${fileName.toUpperCase()} = '/$fileName';
  
}
''');
  } else {
    var content = routeNamesFile.readAsStringSync();
    if (!content.contains('static const String ${fileName.toUpperCase()}')) {
      // Cari posisi sebelum kurung penutup class
      final lastBraceIndex = content.lastIndexOf('}');
      if (lastBraceIndex != -1) {
        final newRoute =
            '  static const String ${fileName.toUpperCase()} = \'/$fileName\';\n';
        content = content.replaceRange(
          lastBraceIndex - 1,
          lastBraceIndex - 1,
          newRoute,
        );
        routeNamesFile.writeAsStringSync(content);
      }
    }
  }

  // Update route_app.dart
  final routeAppFile = File('${routesDir.path}/route_app.dart');
  if (!routeAppFile.existsSync()) {
    routeAppFile.writeAsStringSync('''
import 'package:get/get.dart';

import 'route_names.dart';
import '../features/$fileName/presentation/binding/${fileName}_binding.dart';
import '../features/$fileName/presentation/view/${fileName}_view.dart';

class RouteApp {
  static final routes = [
    GetPage(
      name: RouteNames.${fileName.toUpperCase()},
      page: () => const ${className}View(),
      binding: ${className}Binding(),
    ),
  ];
}
''');
  } else {
    var content = routeAppFile.readAsStringSync();
    if (!content.contains('${className}View')) {
      // Add import
      if (!content.contains(
        'import \'../features/$fileName/presentation/view/${fileName}_view.dart\';',
      )) {
        final importIndex = content.indexOf('import \'route_names.dart\';');
        if (importIndex != -1) {
          content = content.replaceRange(
            importIndex,
            importIndex,
            'import \'../features/$fileName/presentation/view/${fileName}_view.dart\';\n',
          );
        }
      }

      // Add binding import
      if (!content.contains(
        'import \'../features/$fileName/presentation/binding/${fileName}_binding.dart\';',
      )) {
        final importIndex = content.indexOf(
          'import \'../features/$fileName/presentation/view/${fileName}_view.dart\';',
        );
        if (importIndex != -1) {
          content = content.replaceRange(
            importIndex,
            importIndex,
            'import \'../features/$fileName/presentation/binding/${fileName}_binding.dart\';\n',
          );
        }
      }

      // Add route
      final routesIndex = content.indexOf('static final routes = [');
      if (routesIndex != -1) {
        final routesEndIndex = content.indexOf('];', routesIndex);
        if (routesEndIndex != -1) {
          final routeEntry =
              '''
    GetPage(
      name: RouteNames.${fileName.toUpperCase()},
      page: () => const ${className}View(),
      binding: ${className}Binding(),
    ),''';
          content = content.replaceRange(
            routesEndIndex,
            routesEndIndex,
            routeEntry,
          );
        }
      }

      routeAppFile.writeAsStringSync(content);
    }
  }

  print('Updated routes for $className');
}

// FUNGSI BARU: generateRepositoryOnPage
void generateRepositoryOnPage(String repoName, String pageName) {
  final repoClassName = toCamelCase(repoName);
  final repoFileName = toSnakeCase(repoName);
  final pageFileName = toSnakeCase(pageName);

  // Cek apakah folder page exists
  final pageDir = Directory('lib/apps/features/$pageFileName');
  if (!pageDir.existsSync()) {
    print('❌ ERROR: Page "$pageName" does not exist!');
    print(
      'Please create the page first using: dart generate.dart page:$pageName',
    );
    print('Available pages:');

    // List available pages
    final featuresDir = Directory('lib/apps/features');
    if (featuresDir.existsSync()) {
      final directories = featuresDir.listSync();
      for (final dir in directories) {
        if (dir is Directory) {
          print('  - ${dir.path.split('/').last}');
        }
      }
    }

    exit(1);
  }

  // Buat folder repositories jika belum ada
  final repoDir = Directory(
    'lib/apps/features/$pageFileName/data/repositories',
  );
  if (!repoDir.existsSync()) {
    repoDir.createSync(recursive: true);
    print('Created directory: ${repoDir.path}');
  }

  // Generate abstract repository untuk domain
  final abstractRepoContent =
      '''
abstract class ${repoClassName}Repository {
  
}
''';

  // Generate implementation repository untuk data
  final implRepoContent =
      '''
import '../../domain/repositories/${repoFileName}_repository.dart';

class ${repoClassName}RepositoryImpl implements ${repoClassName}Repository {
  
}
''';

  // Buat folder domain repositories jika belum ada
  final domainRepoDir = Directory(
    'lib/apps/features/$pageFileName/domain/repositories',
  );
  if (!domainRepoDir.existsSync()) {
    domainRepoDir.createSync(recursive: true);
    print('Created directory: ${domainRepoDir.path}');
  }

  // Write abstract repository file (domain)
  final abstractRepoFile = File(
    '${domainRepoDir.path}/${repoFileName}_repository.dart',
  );
  abstractRepoFile.writeAsStringSync(abstractRepoContent);

  // Write implementation repository file (data)
  final implRepoFile = File(
    '${repoDir.path}/${repoFileName}_repository_impl.dart',
  );
  implRepoFile.writeAsStringSync(implRepoContent);

  print('✅ Generated abstract repository: ${abstractRepoFile.path}');
  print('✅ Generated implementation repository: ${implRepoFile.path}');
  print('📁 Location: lib/apps/features/$pageFileName/');
  print(
    '🎉 Repository "$repoClassName" successfully created on page "$pageName"',
  );
  print('');
  print('💡 Next steps:');
  print('   1. Implement the actual data source logic in the repository impl');
  print('   2. Add dependency injection in your binding:');
  print(
    '      Get.lazyPut<${repoClassName}Repository>(() => ${repoClassName}RepositoryImpl());',
  );
}

void generateUsecase(String name, String pageName) {
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
    // TODO: implement
  }
}
''';

  final dir = Directory('lib/apps/features/$pageFileName/domain/usecase');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  File('${dir.path}/${fileName}_usecase.dart')
    ..writeAsStringSync(content)
    ..printCreated();
}

void generateRepository(String name, String pageName) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);
  final pageFileName = toSnakeCase(pageName);

  // abstract
  final abstractContent =
      '''
abstract class ${className}Repository {
  // TODO: define contract
}
''';

  // impl
  final implContent =
      '''
import '../../domain/repositories/${fileName}_repository.dart';
import '../datasource/${fileName}_network_datasource.dart';
import '../datasource/${fileName}_offline_datasource.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  final ${className}NetworkDatasource _network;
  final ${className}OfflineDatasource _offline;

  ${className}RepositoryImpl(this._network, this._offline);
}
''';

  final domainDir = Directory(
    'lib/apps/features/$pageFileName/domain/repositories',
  );
  final dataDir = Directory(
    'lib/apps/features/$pageFileName/data/repositories',
  );

  domainDir.createSync(recursive: true);
  dataDir.createSync(recursive: true);

  File('${domainDir.path}/${fileName}_repository.dart')
    ..writeAsStringSync(abstractContent)
    ..printCreated();

  File('${dataDir.path}/${fileName}_repository_impl.dart')
    ..writeAsStringSync(implContent)
    ..printCreated();
}

void generateDatasource(String name, String pageName) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);
  final pageFileName = toSnakeCase(pageName);

  final networkContent =
      '''
class ${className}NetworkDatasource {
  // TODO: remote api calls
}
''';

  final offlineContent =
      '''
class ${className}OfflineDatasource {
  // TODO: local db / shared pref
}
''';

  final dir = Directory('lib/apps/features/$pageFileName/data/datasource');
  dir.createSync(recursive: true);

  File('${dir.path}/${fileName}_network_datasource.dart')
    ..writeAsStringSync(networkContent)
    ..printCreated();

  File('${dir.path}/${fileName}_offline_datasource.dart')
    ..writeAsStringSync(offlineContent)
    ..printCreated();
}

void generatePagePresentationOnly(String name) {
  final className = toCamelCase(name);
  final fileName = toSnakeCase(name);

  // Generate view file
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
        title: Text('${className}View'.tr),
        centerTitle: true,
      ),
      body: const SafeArea(
        child: Text(
          '${className}View is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
''';

  // Generate controller file
  final controllerContent =
      '''
import 'package:get/get.dart';

class ${className}Controller extends GetxController {
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
}
''';

  // Generate binding file
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
  final viewDir = Directory('$basePath/presentation/view');
  final controllerDir = Directory('$basePath/presentation/controller');
  final bindingDir = Directory('$basePath/presentation/binding');
  final screenDir = Directory('$basePath/presentation/view/screen');

  final directories = [viewDir, screenDir, controllerDir, bindingDir];

  for (final dir in directories) {
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      print('Created directory: ${dir.path}');
    }
  }

  // Write files
  final viewFile = File('${viewDir.path}/${fileName}_view.dart');
  final controllerFile = File(
    '${controllerDir.path}/${fileName}_controller.dart',
  );
  final bindingFile = File('${bindingDir.path}/${fileName}_binding.dart');

  viewFile.writeAsStringSync(viewContent);
  controllerFile.writeAsStringSync(controllerContent);
  bindingFile.writeAsStringSync(bindingContent);

  print('Generated view: ${viewFile.path}');
  print('Generated controller: ${controllerFile.path}');
  print('Generated binding: ${bindingFile.path}');

  // Update routes
  updateRoutes(className, fileName);
}

/* ============================================================
   NEW INIT FUNCTION (plain-text pubspec helper)
   ============================================================ */

/// entry for `dart generate.dart init [--pkg=name:url:ref]`
void _cmdInit(List<String> args) {
  // -------------------- 1. parse optional --pkg --------------------
  String pkgName = 'yo_ui';
  String pkgUrl = 'https://github.com/cahyo40/youi.git';

  final pkgOpt = args.firstWhere(
    (a) => a.startsWith('--pkg='),
    orElse: () => '',
  );
  if (pkgOpt.isNotEmpty && pkgOpt.contains('=')) {
    final raw = pkgOpt.split('=').last;
    final split = raw.split(':');
    if (split.length >= 3) {
      pkgName = split[0];
      pkgUrl = split[1];
    } else {
      print('⚠️  Format --pkg=name:url:ref tidak lengkap, pakai default');
    }
  }

  // -------------------- 2. create folders --------------------
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
    'test/unit',
    'test/widget',
    'integration_test',
    'assets/images',
    'assets/fonts',
  ];
  for (final f in folders) {
    Directory(f).createSync(recursive: true);
  }

  // -------------------- 3. skeleton files --------------------
  File('lib/apps/core/error/failure.dart').writeAsStringSync(
    'class Failure {\n  final String message;\n  Failure(this.message);\n}',
  );

  File('lib/apps/core/network/api_constants.dart').writeAsStringSync(
    'abstract class ApiConstants {\n  static const String baseUrl = "https://jsonplaceholder.typicode.com";\n}',
  );

  File('lib/apps/core/theme/app_theme.dart').writeAsStringSync('''
import 'package:flutter/material.dart';
abstract class AppTheme {
  static ThemeData light = ThemeData(
    primarySwatch: Colors.blue,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
''');

  // routes
  File('lib/apps/routes/route_names.dart').writeAsStringSync(
    '// ignore_for_file: constant_identifier_names\nabstract class RouteNames {\n  static const String SPLASH = "/";\n}',
  );

  // main.dart
  File('lib/main.dart').writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:$pkgName/$pkgName.dart';

import 'apps/routes/route_app.dart';

void main()=>runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context)=>GetMaterialApp(
        title:'MyApp',
        theme: YoTheme.lightTheme(context),
    darkTheme: YoTheme.darkTheme(context),
        initialRoute:'/',
        getPages:RouteApp.routes,
      );
}
''');

  // -------------------- 4. inject deps --------------------
  _injectDepsToPubspec(pkgName: pkgName, pkgUrl: pkgUrl);

  // -------------------- 5. gitignore --------------------
  File(
    '.gitignore',
  ).writeAsStringSync(_gitIgnoreContent, mode: FileMode.append);

  print('✅ Project initialised!');
  print('   Next: flutter pub get');
  print('         flutter run');
}

/* -----------------------------------------------------------
   Helper: inject dependencies (plain-text)
----------------------------------------------------------- */
void _injectDepsToPubspec({required String pkgName, required String pkgUrl}) {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) throw ('pubspec.yaml not found');

  final lines = file.readAsLinesSync();
  final buf = StringBuffer();

  // ignore: unused_local_variable
  bool inDeps = false, depsClosed = false;
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
      depsClosed = true;
    }

    // skip kalau sudah ada
    if (needed.keys.any((k) => trim.startsWith('$k:'))) continue;
    if (trim.startsWith('$pkgName:')) continue;

    buf.writeln(l);

    // sisipkan setelah dependencies:
    if (trim == 'dependencies:') {
      needed.forEach((k, v) => buf.writeln('  $k: $v'));
      pkgGitLines.forEach(buf.writeln);
    }
  }
  file.writeAsStringSync(buf.toString());
}

String get _gitIgnoreContent => '''

# --- GENERATED ---
*.freezed.dart
*.g.dart
*.gr.dart
build/
.env
/pubspec.lock
/android/app/google-services.json
/ios/Runner/GoogleService-Info.plist
''';
