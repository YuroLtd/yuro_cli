import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class Version extends Command {
  @override
  String get name => 'version';

  @override
  String get help => 'Show the version of this CLI.';

  @override
  ArgParser get argParser => ArgParser();

  @override
  Future<void> parser(List<String> arguments) async {
    final version = await getNativeVersion();
    logger.i('\nYuro Cli ${version ?? 'unknown'}\n');
  }
}
