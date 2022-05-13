import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class YuroCli {
  static YuroCli? instance;

  factory YuroCli() => instance ?? YuroCli._();

  YuroCli._();

  List<Command> get commands => [Run(), Generate(), Build(), Upgrade()];

  ArgParser get argParser {
    final argParser = ArgParser();
    argParser.addSeparator('Usage: yuro <command> [arguments]');
    argParser.addSeparator('Global commands:');
    argParser.addFlag('version', abbr: 'v', help: 'Show the version of this CLI.', defaultsTo: false);
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
    } else if (argResults['version']) {
      final version = await getNativeVersion();
      logger.i('\nYuro Cli ${version ?? 'unknown'}\n');
      return;
    } else {
      final result = commands.where((element) => element.name == arguments.first).toList();
      if (result.isNotEmpty) {
        await result.first.parser(arguments.sublist(1));
      } else {
        logger.e('Could not find a command named "${arguments[0]}".');
      }
    }
  }
}
