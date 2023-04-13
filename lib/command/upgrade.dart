import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

class Upgrade extends Command {
  @override
  String get name => 'upgrade';

  @override
  String get help => 'Upgrade this CLI.';

  @override
  void buildArgParser(ArgParser argParser) {}

  @override
  void coustomParser(ArgResults argResults) async {
    final remoteVersion = await getRemoteVersion('yuro_cli');
    final nativeVersion = await getCLIVersion();

    if (nativeVersion.compareTo(remoteVersion) >= 0) {
      logger.i('\nCLI is already the latest version.\n');
    } else {
      logger.i('\nnew version $remoteVersion is published.  upgrade...\n');
      final result = await runUpdateCLI();
      if (result) {
        logger.i('\nCLI upgrade completed.');
      } else {
        logger.e('\nCLI upgrade failed.');
      }
    }
  }
}
