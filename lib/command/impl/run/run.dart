import 'package:yuro_cli/command/command.dart';

import 'build_runner.dart';

class Run extends Command {
  @override
  String get name => 'run';

  @override
  String get help => 'execute cmd "flutter run <command>"';

  @override
  List<Command> get commands => [BuildRunner()];
}
