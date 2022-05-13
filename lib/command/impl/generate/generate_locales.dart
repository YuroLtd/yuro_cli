import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateLocales extends Command {
  final _path = 'assets${path.separator}locales';

  @override
  String get name => 'locale';

  @override
  String get help => 'Generate assets/locales resource.';

  @override
  ArgParser get argParser => ArgParser()
    ..addFlag('watch', abbr: 'w', help: 'Whether to listen the changes in assets.', defaultsTo: true)
    ..addOption('output', abbr: 'o', help: 'Default output directory.', defaultsTo: 'generated');

  @override
  Future<void> parser(List<String> arguments) async {
    final argResults = argParser.parse(arguments);
    final watch = argResults['watch'];
    final output = argResults['output'];

    logger.i('generate locales...');
    // 生成Local文件
    var result = await _generateLocales(watch, output);
    // 注册到yaml文件
    if (result) result = await registerAssets('assets/locales/');
    // 执行flutter pub get命令
    if (result) await runFlutterPubGet();
    logger.i('Process finished.');
  }

  // 生成locale.g.dart文件
  Future<bool> _generateLocales(bool watch, String output) async {
    final yamlFile = await getYamlFile();
    if (yamlFile == null) return false;
    // 判断资源目录是否存在
    final dir = Directory(path.join(await PROJECT_PATH, _path));
    if (!dir.existsSync()) {
      logger.e('The directory of "$_path" does not exist under the project!');
      return false;
    }
    // 创建待生成文件
    final generateFile = File(path.join(await PROJECT_PATH, 'lib/$output/locale.g.dart'));
    if (!generateFile.existsSync()) generateFile.createSync(recursive: true);

    // 解析locales下的json文件
    final localeFiles = dir
        .listSync()
        .where((element) => FileSystemEntity.isFileSync(element.path) && element.path.endsWith('.json'))
        .toList();
    final locales = <String, Map<String, dynamic>>{};
    localeFiles.forEach((element) {
      final name = path.basenameWithoutExtension(element.path);
      locales[name] = json.decode(File(element.path).readAsStringSync());
    });
    final localesMap = <String, Map<String, String>>{};
    locales.forEach((key, value) => localesMap[key] = _parse(value));
    final localeKeys = <String>{};
    localesMap.forEach((key, value) => localeKeys.addAll(value.keys));

    final sb = StringBuffer();
    sb.writeln(license);
    sb.writeln('import \'package:flutter/widgets.dart\';');
    // 写类LocaleKeys
    sb.writeln('class LocaleKeys {');
    sb.writeln('LocaleKeys._();');
    localeKeys.forEach((element) {
      sb.writeln('static const $element = \'$element\';');
    });
    sb.writeln('}');
    // 写类Locales
    sb.writeln('class Locales {');
    sb.writeln('Locales._();');
    // ①写translations
    sb.writeln('static const Map<String, Map<String, String>> translations = {');
    locales.keys.forEach((element) {
      sb.writeln('\'$element\': $element,');
    });
    sb.writeln('};');
    // ②写supportedLocales
    sb.writeln('static const List<Locale> supportedLocales = [');
    locales.keys.forEach((element) {
      final locale = element.toLowerCase().split('_');
      final language = '\'${locale[0]}\'';
      final country = locale.length == 2 ? ', \'${locale[1].toUpperCase()}\'' : '';
      sb.writeln('Locale($language$country),');
    });
    sb.writeln('];');

    // ③写对照表
    localesMap.forEach((key, value) {
      sb.writeln('static const $key = <String, String>{');
      value.forEach((k, v) {
        sb.writeln('\'$k\': \'$v\',');
      });
      sb.writeln('};');
    });
    sb.writeln('}');
    final statement = DartFormatter(pageWidth: 120).format(sb.toString());
    generateFile.writeAsStringSync(statement, flush: true);
    return true;
  }

  Map<String, String> _parse(Map<String, dynamic> data, [String? parentKey]) {
    final map = <String, String>{};
    data.forEach((key, value) {
      final currentKey = '${parentKey == null ? '' : '${parentKey}_'}$key';
      if (value is String) {
        map[currentKey] = value;
      } else if (value is Map<String, dynamic>) {
        map.addAll(_parse(value, currentKey));
      } else {
        map[currentKey] = value.toString();
      }
    });
    return map;
  }
}
