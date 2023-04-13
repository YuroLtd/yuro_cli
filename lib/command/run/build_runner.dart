import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

class BuildRunner extends Command {
  @override
  String get name => 'build_runner';

  @override
  String get help => 'execute cmd "flutter packages pub run build_runner build"';

  @override
  void buildArgParser(ArgParser argParser) {
    argParser.addFlag('delete', abbr: 'd', help: 'The command contains --delete-conflicting-outputs.', defaultsTo: false);
  }

  @override
  void coustomParser(ArgResults argResults) async {
    await registerPackage('build_runner', 'dev_dependencies');
    await runBuildRunner(argResults['delete']);
  }
}
