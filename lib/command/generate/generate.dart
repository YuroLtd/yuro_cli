import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

import 'generate_assets.dart';
import 'generate_version.dart';

class Generate extends Command {
  @override
  String get name => 'gen';

  @override
  String get help => 'Generate assets and version.';

  @override
  List<Command> get commands => [GenerateImage(), GenerateVersion()];

  @override
  void buildArgParser(ArgParser argParser) {
  }
  
  @override
  void coustomParser(ArgResults argResults) {
  }
}
