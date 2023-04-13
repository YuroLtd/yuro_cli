import 'package:yuro_cli/core/core.dart';

abstract class Command {
  final _argParser = ArgParser();

  Command() {
    _buildArgParser();
  }

  /// 命令名称
  String get name;

  /// 命令帮助文本
  String get help;

  /// 获取子命令列表
  List<Command> get commands => [];

  ArgParser get argParser => _argParser;

  void _buildArgParser() {
    argParser.addSeparator('Available arguments:');
    buildArgParser(_argParser);
    argParser.addFlag('help', abbr: 'h', help: 'Print this usage information.', defaultsTo: false);

    if (commands.isNotEmpty) {
      final sb = StringBuffer()..writeln('Available commands:');
      commands.forEach((element) {
        sb.write(element.name);
        sb.write(' ' * (15 - element.name.length));
        sb.writeln(element.help);
        argParser.addCommand(element.name, element.argParser);
      });
      argParser.addSeparator(sb.toString());
    }
    argParser.addSeparator('');
  }

  /// 构建自己的命令参数
  void buildArgParser(ArgParser argParser);

  /// 统一解析器, 命令未截止时调用[coustomParser]
  void parser(ArgResults argResults) {
    if (argResults.command != null) {
      final command = commands.firstWhere((element) => element.name == argResults.command!.name);
      command.parser(argResults.command!);
      return;
    }

    if (argResults['help']) {
      stdout.writeln(argParser.usage);
      return;
    }

    coustomParser(argResults);
  }

  ///
  void coustomParser(ArgResults argResults);
}
