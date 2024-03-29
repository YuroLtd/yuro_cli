import 'dart:async';
import 'dart:convert';
import 'dart:io';

export 'package:args/args.dart';
export 'package:yaml/yaml.dart';
export 'package:yaml_edit/yaml_edit.dart';
export 'package:process_run/process_run.dart';
export 'package:meta/meta.dart';
export 'package:path/path.dart';
export 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:http/http.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';


part 'src/yaml.dart';
part 'src/http.dart';
part 'src/git.dart';
part 'src/command.dart';

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
  if (directory == null || !File(join(directory, 'pubspec.yaml')).existsSync()) {
    throw FileSystemException('not the root path of the flutter or dart project', directory);
  }
  return directory;
}

String get HOST_URL => Platform.environment['PUB_HOSTED_URL'] ?? 'https://pub.dev/';

/// dart的.pub-cache地址
String get PUB_CACHE {
  final path = Platform.environment['PUB_CACHE'];
  if (path == null) {
    throw Exception('Unable to find PUB_CACHE in environment variables, you must configure it first.');
  }
  return path;
}

/// 获取项目cli的lock文件
File getCLILockFile() {
  File lockFile = File(join(PUB_CACHE, 'global_packages/yuro_cli/pubspec.lock'));
  if (!lockFile.existsSync()) {
    throw Exception('Yuo can use command "<dart> pub global activate yuro_cli" to get this cli.');
  }
  return lockFile;
}

/// 获取指定的yaml文件
Future<File> getYamlFile([String name = 'pubspec.yaml']) async => File(join(await PROJECT_PATH, 'pubspec.yaml'));

class _Logger {
  final AnsiPen _penWaring = AnsiPen()..yellow();
  final AnsiPen _penError = AnsiPen()..red();

  void i(String msg) => print(msg);

  void w(String msg) => print(_penWaring(msg));

  void e(String msg) => print(_penError(msg));
}

final logger = _Logger();
