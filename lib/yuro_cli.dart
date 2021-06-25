import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

final ArgParser _argParser = ArgParser();

final List<Command> _commands = [Builder(), Generate(), Version(), Upgrade()];

void inject() {
  _argParser.addSeparator('Usage: yuro <command> [arguments]');
  var sb = StringBuffer()..writeln('Available commands:');
  _commands.forEach((element) {
    sb.write(element.name);
    sb.write(' ' * (15 - element.name.length));
    sb.writeln(element.help);
    _argParser.addCommand(element.name, element.argParser);
  });
  _argParser.addSeparator(sb.toString());
}

void parseArgs(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    if (_argParser.commands.containsKey(arguments[0])) {
      var command = _commands.where((element) => element.name == arguments[0]).first;
      await command.parser(arguments.sublist(1));
    } else {
      logger.e('Could not find a command named "${arguments[0]}".');
    }
  } else {
    stdout.writeln(_argParser.usage);
  }
}
