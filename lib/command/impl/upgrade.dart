import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class Upgrade extends Command {
  @override
  String get name => 'upgrade';

  @override
  String get help => 'Upgrade this CLI.';

  @override
  ArgParser get argParser => ArgParser();

  @override
  Future<void> parser(List<String> arguments) async {
    var remoteVersion = await PubUtil.getRemoteVersion('yuro_cli');
    var nativeVersion = await YamlUtil.getNativeVersion();

    if (remoteVersion == null || nativeVersion == null || nativeVersion.compareTo(remoteVersion) >= 0) {
      logger.i('\nThe latest version is already installed.\n');
    } else {
      logger.i('\nThe current version is $nativeVersion and the latest version is $remoteVersion. upgrade...\n');
      PubUtil.runUpgrade();
    }
  }
}
