import 'package:yuro_cli/core/core.dart';

export 'impl/run/run.dart';
export 'impl/generate/generate.dart';
export 'impl/build/build.dart';

export 'impl/upgrade.dart';

abstract class Command {
  /// 命令名称
  String get name;

  /// 命令帮助文本
  String get help;

  /// 获取子命令列表
  List<Command> get commands => [];

  ArgParser get argParser {
    final argParser = ArgParser();
    argParser.addSeparator('Usage: yuro $name <command>');
    argParser.addSeparator('Global commands:');
    argParser.addFlag('help', abbr: 'h', help: 'Print this usage information.', defaultsTo: false);
    final sb = StringBuffer()..writeln('Available commands:');
    commands.forEach((element) {
      sb.write(element.name);
      sb.write(' ' * (15 - element.name.length));
      sb.writeln(element.help);
      argParser.addCommand(element.name, element.argParser);
    });
    argParser.addSeparator(sb.toString());
    return argParser;
  }

  Future<void> parser(List<String> arguments) async {
    final argResults = argParser.parse(arguments);
    if (argResults.arguments.isEmpty || argResults['help']) {
      stdout.writeln(argParser.usage);
    }else{
      final result = commands.where((element) => element.name == arguments.first).toList();
      if (result.isNotEmpty) {
        await result.first.parser(arguments.sublist(1));
      } else {
        logger.e('Could not find a command named "${arguments[0]}".');
      }
    }
  }
}
