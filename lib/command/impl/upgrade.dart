import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class Upgrade extends Command {
  @override
  String get name => 'upgrade';

  @override
  String get help => 'Upgrade this CLI.';

  @override
  Future<void> parser(List<String> arguments) async {
    final remoteVersion = await getRemoteVersion('yuro_cli');
    final nativeVersion = await getNativeVersion();

    if (remoteVersion == null || nativeVersion == null || nativeVersion.compareTo(remoteVersion) >= 0) {
      logger.i('\nThe latest version is already installed.\n');
    } else {
      logger.i('\nThe current version is $nativeVersion and the latest version is $remoteVersion. upgrade...\n');
      final result = await runExecutableArguments('dart', ['pub', 'global', 'activate', 'yuro_cli'], verbose: true);
      if (result.exitCode == 0) {
        logger.i('\nyuro_cli has been updated to the latest version.');
        logger.i('Process finished with exit code ${result.exitCode}\n');
      } else {
        logger.e('\nError: ${result.stderr}');
        logger.e('Process finished with exit code ${result.exitCode}\n');
      }
    }
  }
}
