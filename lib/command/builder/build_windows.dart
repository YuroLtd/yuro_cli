import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

class BuildWindows extends Command {
  @override
  String get name => 'windows';

  @override
  String get help => 'execute cmd "flutter build windows"';

  @override
  void buildArgParser(ArgParser argParser) {}
  
  @override
  void coustomParser(ArgResults argResults) {
  }
}
