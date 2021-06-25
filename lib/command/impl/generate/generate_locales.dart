import 'dart:convert';

import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateLocales extends Command {
  final path = 'assets/locales';

  @override
  String get name => 'locales';

  @override
  String get help => 'Generate assets/locales resource.';

  @override
  ArgParser get argParser => ArgParser()
    ..addFlag('watch', abbr: 'w', help: 'Whether to listen the changes in assets.', defaultsTo: true)
    ..addOption('output', abbr: 'o', help: 'Default output directory.', defaultsTo: 'generated')
    ..addOption('name', abbr: 'n', help: 'The Assets Class Name.', defaultsTo: 'LocaleKeys');

  @override
  Future<void> parser(List<String> arguments) async {
    var argResults = argParser.parse(arguments);
    bool watch = argResults['watch'];
    String output = argResults['output'];
    String name = argResults['name'];

    logger.i('\ngenerate images...');
    var result = await generateLocales(watch, output, name);
    if (result) {
      result = await YamlUtil.registerAssets('$path/');
    }
    if (result) {
      await YamlUtil.runFlutterPubGet();
    }
    logger.i('Process finished.\n');
  }

  Future<bool> generateLocales(bool watch, String output, String name) async {
    if (!YamlUtil.checkYamlFile()) return false;

    var dir = Directory(join(PROJECT_PATH!, path));
    if (!dir.existsSync()) {
      logger.e('The directory of "$path" does not exist under the project!');
      return false;
    }

    var generateFile = File(join(PROJECT_PATH!, 'lib/$output/locales.g.dart'));
    if (!generateFile.existsSync()) generateFile.createSync(recursive: true);

    var localeFiles = dir.listSync();
    localeFiles = localeFiles.where((element) => FileSystemEntity.isFileSync(element.path) && element.path.endsWith('.json')).toList();
    localeFiles.sort((a, b) => a.path.compareTo(b.path));

    // 生成文件内容
    var locales = <String, Map<String, dynamic>>{};
    localeFiles.forEach((fileEntity) {
      var name = fileEntity.path.split('/').last.split('.')[0];
      var map = json.decode(File(fileEntity.path).readAsStringSync());
      locales[name] = map;
    });

    var sb = StringBuffer();
    sb.writeln(license);
    sb.writeln('import \'package:flutter/widgets.dart\';\n');
    // AppTranslation 部分
    sb.writeln('abstract class AppTranslation {');
    sb.writeln('\tstatic final Map<String, Map<String, String>> translations = {');
    locales.keys.forEach((element) {
      sb.writeln('\t\t\'$element\': Locales.$element,');
    });
    sb.writeln('\t};\n');
    sb.writeln('\tstatic const List<Locale> supportedLocales = [');
    locales.keys.forEach((element) {
      var locale = element.toLowerCase().split('_');
      var language = '\'${locale[0]}\'';
      var country = locale.length == 2 ? ', \'${locale[1].toUpperCase()}\'' : '';
      sb.writeln('\t\tLocale($language$country),');
    });
    sb.writeln('\t];\n}\n');
    //
    var localesMap = <String, Map<String, String>>{};
    locales.forEach((key, value) => localesMap[key] = _parse(value, null));
    var localeKeys = <String>[];
    localesMap.forEach((key, value) {
      if (!value.containsKey('locale')) {
        logger.w('locale file "$key.json" is missing the key named "locale"');
      }
      var waitAddList = value.keys.where((element) => !localeKeys.contains(element)).toList();
      localeKeys.addAll(waitAddList);
    });

    sb.writeln('abstract class $name {');
    localeKeys.forEach((element) {
      sb.writeln('\tstatic const $element = \'$element\';');
    });
    sb.writeln('}\n');
    //
    sb.writeln('abstract class Locales {');
    localesMap.forEach((key, value) {
      sb.writeln('\tstatic const $key = <String, String>{');
      value.forEach((k, v) {
        sb.writeln('\t\t\'$k\': \'$v\',');
      });
      sb.writeln('\t};');
    });
    sb.writeln('}');
    generateFile.writeAsStringSync(sb.toString(), flush: true);
    return true;
  }

  Map<String, String> _parse(Map<String, dynamic> data, String? parentKey) {
    var map = <String, String>{};
    data.forEach((key, value) {
      var currentKey = parentKey != null ? '${parentKey}_$key' : key;
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
