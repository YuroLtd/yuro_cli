import 'dart:async';
import 'dart:convert';
import 'dart:io';

export 'package:args/args.dart';
export 'package:process_run/process_run.dart';
export 'dart:io';

import 'package:http/http.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/cmd_run.dart';

import 'util/logger.dart';

part 'yaml.dart';

/// 生成文件的固定头
const String license = '''// DO NOT MODIFY MANUALLY. This code generate by package:yuro_cli/yuro_cli.dart.\n''';

final logger = Logger();

/// 项目地址
FutureOr<String> get PROJECT_PATH async {
  final String directory;
  if (Platform.isWindows) {
    final result = await runExecutableArguments('cd', []);
    directory = (result.stdout as String).replaceAll('\r\n', '');
  } else {
    directory = Platform.environment['PWD'] ?? '';
  }
  if (!File(path.join(directory, 'pubspec.yaml')).existsSync()) {
    throw FileSystemException('not the root path of the flutter or dart project', directory);
  }
  return directory;
}

/// 获取项目pubspec.yaml文件
Future<File?> getYmalFile() async {
  try {
    return File(path.join(await PROJECT_PATH, 'pubspec.yaml'));
  } on Exception catch (err) {
    logger.e(err.toString());
    return null;
  }
}

/// dart的.pub-cache地址
String get DART_PUB_HOME {
  final path = Platform.environment['DART_PUB_HOME'] ?? '';
  if (path.isEmpty) {
    throw Exception('Unable to find DART_PUB_HOME in environment variables, you must configure it first.');
  }
  return path;
}

/// 获取[package]的最新版本
Future<String?> getRemoteVersion(String package) async {
  try {
    var res = await get(Uri.parse('https://pub.dev/api/packages/$package'));
    if (res.statusCode == 200) {
      return json.decode(res.body)['latest']['version'];
    }
  } on Exception catch (_) {
    return null;
  }
}

/// 获取CLI的本地版本,需要先配置[DART_PUB_HOME]
Future<String?> getNativeVersion() async {
  try {
    final lockFile = File(path.join(DART_PUB_HOME, 'global_packages/yuro_cli/pubspec.lock'));
    if (lockFile.existsSync()) {
      final yamlMap = loadYaml(lockFile.readAsStringSync()) as YamlMap;
      return yamlMap['packages']['yuro_cli']['version'].toString();
    } else {
      throw Exception('Yuo can use command "<dart> pub global activate yuro_cli" to get this cli.');
    }
  } on Exception catch (err) {
    logger.e(err.toString());
    return null;
  }
}

/// 执行CLI升级
void runUpgrade() async {
  final result = await runExecutableArguments('dart', ['pub', 'global', 'activate', 'yuro_cli'], verbose: true);
  if (result.exitCode == 0) {
    logger.i('\nyuro_cli has been updated to the latest version.');
    logger.i('Process finished with exit code ${result.exitCode}\n');
  } else {
    logger.e('\nError: ${result.stderr}');
    logger.e('Process finished with exit code ${result.exitCode}\n');
  }
}

/// 执行"flutter pub get"命令
Future<void> runFlutterPubGet() async {
  final res = await runExecutableArguments('flutter', ['pub', 'get'], verbose: true);
  if (res.exitCode != 0) {
    logger.e('\nError: ${res.stderr}');
  }
}
