import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

import 'command/run/run.dart';
import 'command/generate/generate.dart';
import 'command/builder/build.dart';
import 'command/upgrade.dart';

class YuroCli extends Command {
  @override
  String get name => 'yuro';

  @override
  String get help => 'Yuro cli';

  @override
  List<Command> get commands => [Run(), Generate(), Build(), Upgrade()];

  @override
  void buildArgParser(ArgParser argParser) {
    argParser.addFlag('version', abbr: 'v', help: 'Show the version of this CLI.', defaultsTo: false);
  }

  @override
  void coustomParser(ArgResults argResults) async {
    if (argResults['version']) {
      final version = await getCLIVersion();
      logger.i('\nYuro Cli $version\n');
    }
  }
}

final cli = YuroCli();
