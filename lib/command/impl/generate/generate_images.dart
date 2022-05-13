import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateImages extends Command {
  final _path = 'assets${path.separator}images';
  final _extensions = ['.png', '.jpg', '.svg'];

  @override
  String get name => 'image';

  @override
  String get help => 'Generate assets/images resource.required file must be PNG、JPG、SVG';

  @override
  ArgParser get argParser => ArgParser()
    ..addFlag('watch', abbr: 'w', help: 'Whether to listen the changes in assets.', defaultsTo: true)
    ..addOption('output', abbr: 'o', help: 'Default output directory.', defaultsTo: 'generated');

  @override
  Future<void> parser(List<String> arguments) async {
    final argResults = argParser.parse(arguments);
    final watch = argResults['watch'];
    final output = argResults['output'];

    logger.i('generate images...');
    var result = await _generateImages(watch, output);
    // 写入成功后, 检查pubspec.yaml文件是否注册了assets/images, 如果没有注册则注册该资源目录
    if (result) result = await registerAssets('assets/images/');
    // 如果本次注册了资源,执行"flutter pub get"命令
    if (result) await runFlutterPubGet();
    logger.i('Process finished.');
  }

  // 生成images.g.dart文件
  Future<bool> _generateImages(bool isWatch, String output) async {
    final yamlFile = await getYamlFile();
    if (yamlFile == null) return false;
    // 检查assets/images目录是否存在
    final dir = Directory(path.join(await PROJECT_PATH, _path));
    if (!dir.existsSync()) {
      logger.e('The directory of "$_path" does not exist under the project.');
      return false;
    }
    // 获取图片资源
    final images = _parse(dir);
    if (images.isEmpty) {
      logger.w('The directory of "$_path" is empty.');
      return false;
    }

    // 创建待生成文件
    final generateFile = File(path.join(await PROJECT_PATH, 'lib/$output/image.g.dart'));
    if (!generateFile.existsSync()) generateFile.createSync(recursive: true);
    // 生成文件内容
    final sb = StringBuffer();
    sb.writeln(license);
    sb.writeln('class ImageKeys {');
    sb.writeln('ImageKeys._();');
    images.forEach((key, value) {
      sb.writeln('static const $key = \'assets/images/$value\';');
    });
    sb.writeln('}');
    // 将内容写入文件
    final statement = DartFormatter(pageWidth: 120).format(sb.toString());
    generateFile.writeAsStringSync(statement, flush: true);
    return true;
  }

  Map<String, String> _parse(Directory rootDir, [Directory? imgDir]) {
    final map = <String, String>{};
    final fileList = (imgDir ?? rootDir).listSync();
    for (final element in fileList) {
      if (FileSystemEntity.isFileSync(element.path)) {
        final fileName = path.basename(element.path);
        // 如果是隐藏文件,则跳过
        if (fileName.startsWith('.')) continue;
        final extension = path.extension(element.path);
        // 不支持的文件格式,则跳过
        if (!_extensions.contains(extension)) continue;
        var fileNameWithoutExtension = path.basenameWithoutExtension(element.path);
        // 截取@之前的部分
        if (fileNameWithoutExtension.contains('@')) {
          fileNameWithoutExtension = fileNameWithoutExtension.substring(0, fileNameWithoutExtension.indexOf('@'));
        }
        // 替换字符串中的空格、中划线,大写字母替换为下划线加小写字母
        fileNameWithoutExtension = fileNameWithoutExtension
            .replaceAll(' ', '_')
            .replaceAll('-', '_')
            .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match[0]?.toLowerCase()}');
        final relativePath = path.relative(element.path, from: rootDir.path).replaceAll('\\', '/');
        map[fileNameWithoutExtension] = relativePath;
      } else {
        final _map = _parse(rootDir, Directory(element.path));
        map.addAll(_map);
      }
    }
    return map;
  }
}
