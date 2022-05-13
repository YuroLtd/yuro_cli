import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateVersion extends Command {
  @override
  String get name => 'version';

  @override
  String get help => '''
  The numeric version number of the application to be built.
  You can find it in the "pubspec.yaml" file, similar to "1.0.0+1."
  ''';

  @override
  ArgParser get argParser => ArgParser()
    ..addSeparator('Usage: yuro gen $name [arguments]')
    ..addSeparator('Global arguments:')
    ..addFlag('help', abbr: 'h', help: 'Print this usage information.', defaultsTo: false);

  @override
  Future<void> parser(List<String> arguments) async {
    final argResults = argParser.parse(arguments);
    if (argResults['help']) {
      stdout.writeln(argParser.usage);
      return;
    }
    // 更新数字版本号
    var result = await updateVersionCode();
    if (!result) return;

    // 生成构建信息
    final buildInfo = await gitBuildInfo();
    final buildInfoStr = 'const buildInfo = \'$buildInfo\';';
    final generateFile = File(path.join(await PROJECT_PATH, 'lib/generated/build_config.g.dart'));
    final content = <String>[];

    if (!generateFile.existsSync()) {
      generateFile.createSync(recursive: true);
      content.addAll([license, buildInfoStr]);
    } else {
      content.addAll(generateFile.readAsLinesSync());
      final index = content.indexWhere((element) => element.startsWith('const buildInfo ='));
      content.replaceRange(index, index + 1, [buildInfoStr]);
    }
    result = await writeFile(generateFile, content);
    if (result) {
      logger.i('Process finished.');
    }
  }
}
