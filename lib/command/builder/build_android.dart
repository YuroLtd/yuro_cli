import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

class BuildAndroid extends Command {
  @override
  String get name => 'apk';

  @override
  String get help => 'execute cmd "flutter build apk"';

  @override
  void buildArgParser(ArgParser argParser) {
    argParser.addOption('target=<path>', abbr: 't', help: '''
    The main entry-point file of the application, as run on the device.
    If the "--target" option is omitted, but a file name is provided on the command line, then that is used instead.
    (defaults to "lib\\main.dart")
    ''');
    argParser.addOption('flavor', abbr: 'f', help: '''
    Build a custom app flavor as defined by platform-specific build setup.
    Supports the use of product flavors in Android Gradle scripts, and the use of custom Xcode schemes.
    ''');
    argParser.addOption('target-platform', abbr: 'p', help: '''
    The target platform for which the app is compiled.
    [android-arm (default), android-arm64 (default), android-x86, android-x64 (default)]
    ''');
    argParser.addFlag('split-per-abi', abbr: 's', help: '''
    Whether to split the APKs per ABIs. To learn more, see: https://developer.android.com/studio/build/configure-apk-splits#configure-abi-s
    ''');
  }

  @override
  void coustomParser(ArgResults argResults) async {
    // 开始构建编译命令
    final executableArguments = ['build', 'apk'];
    final flavor = argResults['flavor'];
    if (flavor != null) executableArguments.add('--flavor=$flavor');

    final target = argResults['target=<path>'];
    if (target != null) executableArguments.add('--target=$target');

    final platform = argResults['target-platform'];
    if (platform != null) executableArguments.add('--target-platform=$platform');

    final split = argResults['split-per-abi'];
    if (split) executableArguments.add('--split-per-abi');

    await runExecutableArguments('flutter', executableArguments, verbose: true);
  }
}
