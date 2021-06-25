import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class BuildRunner extends Command {
  @override
  String get name => 'runner';

  @override
  String get help => 'execute cmd "flutter packages pub run build_runner build"';

  @override
  ArgParser get argParser =>
      ArgParser()..addFlag('delete', abbr: 'd', help: 'The command contains --delete-conflicting-outputs.', defaultsTo: false);

  @override
  Future<void> parser(List<String> arguments) async {
    var argResults = argParser.parse(arguments);
    bool delete = argResults['delete'];
    var checkResult = await YamlUtil.checkBuilderRunner();
    if (checkResult) {
      await YamlUtil.runBuilderRunner(delete);
    }
    logger.i('Process finished.\n');
  }
}
