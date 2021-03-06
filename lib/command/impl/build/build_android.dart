import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class BuildAndroid extends Command {
  @override
  String get name => 'apk';

  @override
  String get help => 'execute cmd "flutter build apk"';

  @override
  ArgParser get argParser => ArgParser()
    ..addSeparator('Usage: yuro build $name [arguments]')
    ..addSeparator('Global arguments:')
    ..addFlag('help', abbr: 'h', help: 'Print this usage information.', defaultsTo: false)
    ..addSeparator('Available arguments:')
    ..addOption('target=<path>', abbr: 't', help: '''
    The main entry-point file of the application, as run on the device.
    If the "--target" option is omitted, but a file name is provided on the command line, then that is used instead.
    (defaults to "lib\\main.dart")
    ''')
    ..addOption('flavor', abbr: 'f', help: '''
    Build a custom app flavor as defined by platform-specific build setup.
    Supports the use of product flavors in Android Gradle scripts, and the use of custom Xcode schemes.
    ''');

  @override
  Future<void> parser(List<String> arguments) async {
    final argResults = argParser.parse(arguments);
    if (argResults['help']) {
      stdout.writeln(argParser.usage);
      return;
    }
    // 开始构建编译命令
    final executableArguments = ['build', 'apk'];
    final flavor = argResults['flavor'];
    if (flavor != null) executableArguments.add('--flavor=$flavor');

    final target = argResults['target=<path>'];
    if (target != null) executableArguments.addAll(['-t', target]);
    await runExecutableArguments('flutter', executableArguments, verbose: true);
  }
}
