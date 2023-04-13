import 'package:yuro_cli/command/command.dart';

import 'generate_assets.dart';
import 'generate_version.dart';

class Generate extends Command {
  @override
  String get name => 'gen';

  @override
  String get help => 'Generate assets and version.';

  @override
  List<Command> get commands => [GenerateImage(), GenerateVersion()];
}
