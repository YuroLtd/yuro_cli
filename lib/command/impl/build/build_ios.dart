import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class BuildIos extends Command {
  @override
  String get name => 'ios';

  @override
  String get help => 'execute cmd "flutter build ios"';

  @override
  Future<void> parser(List<String> arguments) async {
    await runExecutableArguments('flutter', ['build', 'ios']);
  }
}
