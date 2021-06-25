import 'dart:io';

export 'dart:convert';
export 'package:http/http.dart';
export 'package:path/path.dart';
export 'package:args/args.dart';
export 'package:yaml/yaml.dart';
export 'package:process_run/process_run.dart';

export 'dart:io';
import 'logger.dart';
export 'pub.dart';
export 'yaml.dart';

/// 项目地址
String? PROJECT_PATH = Platform.environment['PWD'];

/// dart的.pub-cache地址
String? PUB_PATH = Platform.environment['PUB_HOME'];

/// flutter的.pub-cache地址
String? FLUTTER_PUB_PATH = Platform.environment['FLUTTER_PUB_HOME'];

/// 生成文件的固定头
const String license = '''// DO NOT MODIFY MANUALLY. This code generate by package:yuro_cli/yuro_cli.dart.\n''';

final logger = Logger();
