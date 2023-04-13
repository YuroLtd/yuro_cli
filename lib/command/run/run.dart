import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

import 'build_runner.dart';

class Run extends Command {
  @override
  String get name => 'run';

  @override
  String get help => 'execute cmd "flutter run <command>"';

  @override
  List<Command> get commands => [BuildRunner()];

  @override
  void buildArgParser(ArgParser argParser) {
  }
  
  @override
  void coustomParser(ArgResults argResults) {
  }
}
