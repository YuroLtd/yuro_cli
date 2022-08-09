import 'package:yuro_cli/command/command.dart';

import 'generate_image.dart';
import 'generate_intl.dart';
import 'generate_version.dart';

class Generate extends Command {
  @override
  String get name => 'gen';

  @override
  String get help => 'Generate assets resource.';

  @override
  List<Command> get commands => [GenerateImage(), GenerateIntl(), GenerateVersion()];
}
