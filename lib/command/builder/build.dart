import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

import 'build_android.dart';
// import 'build_ios.dart';
// import 'build_windows.dart';

class Build extends Command {
  @override
  String get name => 'build';

  @override
  String get help => 'execute cmd "flutter build <command>"';

  @override
  List<Command> get commands => [
        BuildAndroid(), /* BuildIos(), BuildWindows()*/
      ];

  @override
  void buildArgParser(ArgParser argParser) {}
  
  @override
  void coustomParser(ArgResults argResults) {
  }
}
