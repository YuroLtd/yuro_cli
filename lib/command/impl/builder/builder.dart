import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

import 'builder_runner.dart';

class Builder extends Command {
  final _commands = [BuildRunner()];

  @override
  String get name => 'build';

  @override
  String get help => 'build project.';

  @override
  ArgParser get argParser {
    var argParser = ArgParser();
    argParser.addSeparator('Usage: yuro builder <command>');
    var sb = StringBuffer()..writeln('Available commands:');
    _commands.forEach((element) {
      sb.write(element.name);
      sb.write(' ' * (15 - element.name.length));
      sb.writeln(element.help);
      argParser.addCommand(element.name, element.argParser);
    });
    argParser.addSeparator(sb.toString());
    return argParser;
  }

  @override
  Future<void> parser(List<String> arguments) async {
    if (arguments.isNotEmpty) {
      if (argParser.commands.containsKey(arguments[0])) {
        var command = _commands.where((element) => element.name == arguments[0]).first;
        await command.parser(arguments.sublist(1));
      } else {
        throw ArgumentError('Could not find a command named "${arguments[0]}".');
      }
    } else {
      stdout.writeln(argParser.usage);
    }
  }
}
