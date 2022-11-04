import 'package:path/path.dart' as path;
import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateVersion extends Command {
  @override
  String get name => 'version';

  @override
  String get help => 'The numeric version number of the application to be built.';

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
    await _updateVersionCode();

    // 创建build_config.g.dart
    final generateFile = File(path.join(await PROJECT_PATH, 'lib/generated/build_config.g.dart'));
    if (!generateFile.existsSync()) generateFile.createSync(recursive: true);

    final contents = generateFile.readAsLinesSync();
    // 判断是否要插入license
    if (!contents.contains(license)) {
      contents.insert(0, '$license\n');
    }

    if(!contents.contains('// ignore_for_file: constant_identifier_names')){
      contents.insert(1, '// ignore_for_file: constant_identifier_names\n');
    }

    final branch = await gitBranch();
    _addOrReplace(contents, 'const buildBranch', branch);

    final short = await gitShort();
    _addOrReplace(contents, 'const buildNumber', short);

    final date = await gitDate();
    _addOrReplace(contents, 'const buildDate', date);

    final versionName = await _getVersionName();
    _addOrReplace(contents, 'const versionName', versionName);

    final versionCode = await _getVersionCode();
    _addOrReplace(contents, 'const versionCode', versionCode);

    await writeFile(generateFile, contents);
  }

  Future<void> _updateVersionCode() async {
    var version = await getAttributeValue('version') as String?;
    if (version == null) {
      throw 'Failed to get attribute: version';
    }

    final versionCode = await gitCommitCount();
    if (version.contains('+')) {
      version = version.substring(0, version.indexOf("+"));
    }
    version += '+$versionCode';

    final yamlFile = await getYamlFile();
    final yamlFileContent = yamlFile.readAsLinesSync();
    final attribute = 'version: ';
    final index = yamlFileContent.indexWhere((element) => element.startsWith(attribute));
    yamlFileContent.replaceRange(index, index + 1, ['$attribute$version']);
    await writeFile(yamlFile, yamlFileContent);
  }

  Future<String> _getVersionName() async {
    final version = await getAttributeValue('version') as String?;
    if (version == null) {
      throw 'Failed to get attribute: version';
    }
    final list = version.split('+');
    return list[0];
  }

  Future<String> _getVersionCode() async {
    final version = await getAttributeValue('version') as String?;
    if (version == null) {
      throw 'Failed to get attribute: version';
    }
    final list = version.split('+');
    if (list.length != 2) {
      throw 'no build number';
    }
    return list[1];
  }

  void _addOrReplace(List<String> contents, String startWidth, String value) {
    final index = contents.indexWhere((element) => element.startsWith(startWidth));
    final content = '$startWidth = \'$value\';';
    // 不存在, 在文件末尾追加一行, 否则替换原来的行
    index == -1 ? contents.add('$startWidth = \'$value\';') : contents.replaceRange(index, index + 1, [content]);
  }
}
