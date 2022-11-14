import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

import 'build_android.dart';
// import 'build_ios.dart';
// import 'build_windows.dart';

class Build extends Command {
  @override
  String get name => 'build';

  @override
  String get help => 'execute cmd "flutter build <command>"';

  @override
  List<Command> get commands => [BuildAndroid(),/* BuildIos(), BuildWindows()*/];

  @override
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
}
