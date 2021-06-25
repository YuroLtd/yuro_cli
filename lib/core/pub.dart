import 'package:yuro_cli/core/core.dart';

/// Pub工具类
abstract class PubUtil {
  /// 获取[package]的最新版本
  static Future<String?> getRemoteVersion(String package) async {
    try {
      var res = await get(Uri.parse('https://pub.dev/api/packages/$package'));
      if (res.statusCode == 200) {
        return json.decode(res.body)['latest']['version'];
      }
    } on Exception catch (_) {}
    return null;
  }

  /// 执行CLI升级
  static void runUpgrade() async {
    if (PUB_PATH != null || FLUTTER_PUB_PATH != null) {
      ProcessResult res;
      var lockFile = File(join(FLUTTER_PUB_PATH ?? '', 'global_packages/yuro_cli/pubspec.lock'));
      if (lockFile.existsSync()) {
        res = await runExecutableArguments('flutter', ['pub', 'global', 'activate', 'yuro_cli'], verbose: true);
      } else {
        res = await runExecutableArguments('pub', ['global', 'activate', 'yuro_cli'], verbose: true);
      }
      if (res.exitCode == 0) {
        logger.i('\nyuro_cli has been updated to the latest version.');
        logger.i('Process finished with exit code ${res.exitCode}\n');
      } else {
        logger.e('\nError: ${res.stderr}');
        logger.e('Process finished with exit code ${res.exitCode}\n');
      }
    } else {
      logger.e('\nUnable to find PUB_HOME or FLUTTER_PUB_HOME in environment variables, you must configure it first.');
      logger.e('Process finished.\n');
    }
  }
}
