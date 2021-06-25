import 'package:yuro_cli/core/core.dart';

abstract class YamlUtil {
  static bool checkYamlFile() {
    if (!File(join(PROJECT_PATH!, 'pubspec.yaml')).existsSync()) {
      logger.e('\nUnable to find pubspec.yaml in the path of "${PROJECT_PATH!}"');
      return false;
    }
    return true;
  }

  /// 获取CLI的本地版本,需要先配置[PUB_HOME]或[FLUTTER_PUB_HOME]
  static Future<String?> getNativeVersion() async {
    var pubPath = PUB_PATH ?? FLUTTER_PUB_PATH;
    if (pubPath != null) {
      var lockFile = File(join(pubPath, 'global_packages/yuro_cli/pubspec.lock'));
      if (lockFile.existsSync()) {
        var yamlMap = loadYaml(lockFile.readAsStringSync()) as YamlMap;
        return yamlMap['packages']['yuro_cli']['version'].toString();
      } else {
        logger.e('Yuo can use command "pub global activate yuro_cli" or "flutter pub global activate yuro_cli" to get this cli.');
        return null;
      }
    } else {
      logger.e('Unable to find PUB_HOME or FLUTTER_PUB_HOME in environment variables, you must configure it first.');
      return null;
    }
  }

  /// 注册资源目录到pubspec.yaml文件中
  static Future<bool> registerAssets(String path) async {
    if (!checkYamlFile()) return false;
    var yamlFile = File(join(PROJECT_PATH!, 'pubspec.yaml'));
    var yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
    if (!yamlMap.containsKey('flutter')) {
      yamlFile.writeAsStringSync('\n\rflutter:', mode: FileMode.append, flush: true);
      yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
    }
    var flutter = yamlMap['flutter'] as YamlMap?;
    if (flutter == null || !flutter.containsKey('assets')) {
      yamlFile.writeAsStringSync('\r  assets:', mode: FileMode.append, flush: true);
      yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
    }
    var assets = flutter?['assets'] as YamlList?;
    if (assets == null || !assets.contains(path)) {
      yamlFile.writeAsStringSync('\r    - $path', mode: FileMode.append, flush: true);
      return true;
    }
    return false;
  }

  /// 执行"flutter pub get"命令
  static Future<void> runFlutterPubGet() async {
    var res = await runExecutableArguments('flutter', ['pub', 'get'], verbose: true);
    if (res.exitCode != 0) {
      logger.e('\nError: ${res.stderr}');
    }
  }

  /// 执行"flutter packages pub run build_runner build"命令,当[delete]为true时,增加参数
  /// "--delete-conflicting-outputs"
  static Future<void> runBuilderRunner(bool delete) async {
    var arguments = ['pub', 'run', 'build_runner', 'build'];
    if (delete) arguments.add('--delete-conflicting-outputs');
    var res = await runExecutableArguments('flutter', arguments, verbose: true);
    if (res.exitCode != 0) {
      logger.e('\nError: ${res.stderr}');
    }
  }

  /// 检查"builder_runner"是否注册到yaml中
  static Future<bool> checkBuilderRunner() async {
    if (!checkYamlFile()) return false;
    var yamlFile = File(join(PROJECT_PATH!, 'pubspec.yaml'));
    var yamlFileContent = yamlFile.readAsLinesSync();
    var yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
    if (!yamlMap.containsKey('dev_dependencies')) {
      yamlFile.writeAsStringSync('\n\rdev_dependencies:', mode: FileMode.append, flush: true);
      yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
    }
    var devDependencies = yamlMap['dev_dependencies'] as YamlMap?;
    if (devDependencies == null || !devDependencies.containsKey('build_runner')) {
      logger.e('\nRegister "builder_runner" in "pubspec.yaml".');
      var version = await PubUtil.getRemoteVersion('build_runner');
      if (version != null) {
        var insertLine = yamlFileContent.length;
        if (devDependencies == null) {
          insertLine = yamlFileContent.indexOf('dev_dependencies:');
        } else {
          var lastKey = devDependencies.keys.last;
          insertLine = (devDependencies.nodes[lastKey] as YamlScalar).span.end.line;
        }
        yamlFileContent.insert(++insertLine, '  build_runner: ^$version');
        var writeResult = await _writeYamlFile(yamlFile, yamlFileContent);
        if (writeResult) {
          await runFlutterPubGet();
        }
        return writeResult;
      } else {
        logger.e('Failed to get the latest version of "builder_runner", please try again.');
        return false;
      }
    }
    return true;
  }

  static Future<bool> _writeYamlFile(File yamlFile, List<String> content) async {
    try {
      var iOSink = yamlFile.openWrite();
      content.forEach((element) {
        iOSink.writeln(element);
      });
      await iOSink.close();
      return true;
    } on Exception catch (_) {
      logger.e('"pubspec.yaml" write failed, please try again.');
      return false;
    }
  }
}
