import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

import 'package:yuro_cli/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateImage extends Command {
  @override
  String get name => 'assets';

  @override
  String get help => 'Generate assets resource.';

  late final String projectPath;

  @override
  void buildArgParser(ArgParser argParser) {
    argParser.addOption('path', abbr: 'p', help: 'Path of assets.');
    argParser.addOption('output', abbr: 'o', help: 'Default output directory is "lib/generated.', defaultsTo: 'generated');
    argParser.addOption('ignore', abbr: 'i', help: 'Ignored folders, separated by ",".');
  }

  @override
  void coustomParser(ArgResults argResults) async {

    final assetsPath = argResults['path'];
    final outputDir = argResults['output'];
    final ignorePaths = (argResults['ignore'] as String?)?.split(',') ?? [];

    projectPath = await PROJECT_PATH;
    final rootDir = Directory(path.join(projectPath, 'assets'));
    if (!rootDir.existsSync()) rootDir.createSync(recursive: true);

    final map = <Directory, Map<String, String>>{};
    if (assetsPath == null) {
      rootDir
          .listSync()
          .whereType<Directory>()
          .where((e) => !ignorePaths.contains(path.basename(e.path)))
          .forEach((e) => map.putIfAbsent(e, () => {}));
    } else {
      final dir = Directory(path.join(rootDir.path, assetsPath));
      if (!dir.existsSync()) dir.createSync(recursive: true);
      map.putIfAbsent(dir, () => {});
    }
    // 分析文件夹内容
    map.entries.forEach(_parseAssetsFile);

    // 创建并写入文件
    logger.i('generate file...');
    final generateFile = File(path.join(projectPath, 'lib/$outputDir/assets.g.dart'));
    if (!generateFile.existsSync()) generateFile.createSync(recursive: true);
    final list = await _writeFile(generateFile, map);

    // 检查资源是否注册到pubspec.yaml文件
    await registerAssets(list);

    logger.i('\rProcess finished with exit code 0');
  }

  // 分析文件夹中的文件
  void _parseAssetsFile(MapEntry<Directory, Map<String, String>> mapEntry) {
    final relativePath = path.relative(mapEntry.key.path, from: projectPath).replaceAll('\\', '/');
    logger.i('analyzing directory...[$relativePath]');

    // 过滤文件,隐藏文件
    mapEntry.key.listSync().whereType<File>().where((e) => !path.basename(e.path).startsWith('.')).forEach((file) {
      // 替换字符串中的空格、中划线,大写字母替换为下划线加小写字母
      final fileName = path
          .basename(file.path)
          .replaceAll(' ', '_')
          .replaceAll('-', '_')
          .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match[0]!.toLowerCase()}');

      var key = path.basenameWithoutExtension(fileName);
      int index = 1;
      while (mapEntry.value.containsKey(key)) {
        key = '${path.basenameWithoutExtension(fileName)}_$index';
        index++;
      }
      mapEntry.value[key] = '$relativePath/$fileName';
    });
  }

  Future<List<String>> _writeFile(File file, Map<Directory, Map<String, String>> map) async {
    final list = <String>[];
    final sb = StringBuffer();
    sb.writeln(license);
    sb.writeln();
    sb.writeln('// ignore_for_file: constant_identifier_names');
    sb.writeln();

    map.entries.forEach((element) {
      final relativePath = path.relative(element.key.path, from: projectPath).replaceAll('\\', '/');
      var dirName = path.basename(element.key.path).replaceAll('.', '_').toLowerCase();

      if (!RegExp(r'^[a-zA-Z]+_?[a-zA-Z]*$').hasMatch(dirName)) {
        logger.e('folder name "$dirName" is invalid');
        return;
      }
      list.add('$relativePath/');
      dirName = dirName
          .split('_')
          .map((e) => e.replaceAllMapped(
                RegExp(r'^[a-z]+$'),
                (match) => '${match.input.substring(0, 1).toUpperCase()}${match.input.substring(1)}',
              ))
          .join();
      sb.writeln('abstract class Asset$dirName{');
      element.value.forEach((key, value) {
        sb.writeln('static const $key = \'$value\';');
      });
      sb.writeln('}');
    });

    final statement = DartFormatter(pageWidth: 120).format(sb.toString());
    file.writeAsStringSync(statement, flush: true);

    return list;
  }
}
