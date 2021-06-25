import 'package:args/args.dart';

export 'impl/builder/builder.dart';
export 'impl/generate/generate.dart';

export 'impl/upgrade.dart';
export 'impl/version.dart';

abstract class Command {
  /// 命令名称
  String get name;

  /// 命令帮助文本
  String get help;

  ArgParser get argParser;

  Future<void> parser(List<String> arguments);
}
