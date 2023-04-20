import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateVersion extends Command {
  @override
  String get name => 'version';

  @override
  String get help => 'The numeric version number of the application to be built.';

  @override
  void buildArgParser(ArgParser argParser) {}

  @override
  void coustomParser(ArgResults argResults) async {
    // 创建build_config.g.dart
    final generateFile = File(join(await PROJECT_PATH, 'lib/generated/build.g.dart'));
    if (!generateFile.existsSync()) generateFile.createSync(recursive: true);
    final contents = generateFile.readAsLinesSync();
    contents.forEach((element) {
      print('"$element"');
    });
    print('/////////');
    // 判断是否要插入license
    if (!contents.contains(license)) {
      contents.insertAll(0, [license, '']);
    }

    _addOrReplace(contents, 'buildBranch', await gitBranch());
    _addOrReplace(contents, 'buildNumber', await gitShort());
    _addOrReplace(contents, 'buildDate', await gitDate());

    final yamlFile = await getYamlFile();
    final editor = YamlEditor(yamlFile.readAsStringSync());
    final version = editor.parseAt(['version'], orElse: () => YamlScalar.wrap('1.0.0+1')).value as String;

    final versionName = version.substring(0, version.contains('+') ? version.indexOf('+') : null);
    final versionCode = await gitCommitCount();

    _addOrReplace(contents, 'versionName', versionName);
    _addOrReplace(contents, 'versionCode', versionCode);

    await generateFile.writeAsString(contents.join('\n'), flush: true);

    // editor.update(['version'], YamlScalar.wrap('$versionName${version.contains('+') ? '+$versionCode' : ''}'));
    // await yamlFile.writeAsString(editor.toString());
    // await runPubGet();

    logger.i('\rProcess finished with exit code 0');
  }

  void _addOrReplace(List<String> contents, String field, String value) {
    final index = contents.indexWhere((element) => element.contains(field));
    final content = 'const $field = \'$value\';';
    // 不存在, 在文件末尾追加一行, 否则替换原来的行
    index == -1 ? contents.add(content) : contents.replaceRange(index, index + 1, [content]);
  }
}
