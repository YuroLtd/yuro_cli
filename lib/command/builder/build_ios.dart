import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

class BuildIos extends Command {
  @override
  String get name => 'ios';

  @override
  String get help => 'execute cmd "flutter build ios"';

  @override
  void buildArgParser(ArgParser argParser) {}
  
  @override
  void coustomParser(ArgResults argResults) async{
     await runExecutableArguments('flutter', ['build', 'ios']);
  }
}
