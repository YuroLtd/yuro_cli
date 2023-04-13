import 'dart:async';
import 'dart:convert';
import 'dart:io';

export 'package:args/args.dart';
export 'package:process_run/process_run.dart';
export 'package:yaml_edit/yaml_edit.dart';
export 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:http/http.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/cmd_run.dart';

part 'yaml.dart';

part 'http.dart';

part 'git.dart';

part 'command.dart';

/// 生成文件的固定头
const String license = '// DO NOT MODIFY MANUALLY. This code generate by package:yuro_cli/yuro_cli.dart.';

/// 项目地址
Future<String> get PROJECT_PATH async {
  final String? directory;
  if (Platform.isWindows) {
    final result = await runExecutableArguments('cd', []);
    directory = (result.stdout as String).replaceAll('\r\n', '');
  } else {
    directory = Platform.environment['PWD'];
  }
  if (directory == null || !File(path.join(directory, 'pubspec.yaml')).existsSync()) {
    throw FileSystemException('not the root path of the flutter or dart project', directory);
  }
  return directory;
}

String get HOST_URL => Platform.environment['PUB_HOSTED_URL'] ?? 'https://pub.dev/';

/// dart的.pub-cache地址
String get DART_PUB_HOME {
  final path = Platform.environment['DART_PUB_HOME'];
  if (path == null) {
    throw Exception('Unable to find DART_PUB_HOME in environment variables, you must configure it first.');
  }
  return path;
}

/// 获取项目cli的lock文件
File getCLILockFile() {
  File lockFile = File(path.join(DART_PUB_HOME, 'global_packages/yuro_cli/pubspec.lock'));
  if (!lockFile.existsSync()) {
    throw Exception('Yuo can use command "<dart> pub global activate yuro_cli" to get this cli.');
  }
  return lockFile;
}

/// 获取指定的yaml文件
Future<File> getYamlFile([String name = 'pubspec.yaml']) async => File(path.join(await PROJECT_PATH, 'pubspec.yaml'));

class _Logger {
  final AnsiPen _penWaring = AnsiPen()..yellow();
  final AnsiPen _penError = AnsiPen()..red();

  void i(String msg) => print(msg);

  void w(String msg) => print(_penWaring(msg));

  void e(String msg) => print(_penError(msg));
}

final logger = _Logger();
