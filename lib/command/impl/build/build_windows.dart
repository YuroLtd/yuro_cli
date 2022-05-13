import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class BuildWindows extends Command{

  @override
  String get name => 'windows';

  @override
  String get help => 'execute cmd "flutter build windows"';

  @override
  ArgParser get argParser => ArgParser();



  @override
  Future<void> parser(List<String> arguments) async{

  }

}