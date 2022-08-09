import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateImage extends Command {
  final _path = 'assets${path.separator}images';
  final _extensions = ['.png', '.jpg', '.svg'];
  late final Directory rootDir;
  late final String outputDir;

  final _contents = <String, String>{};
  StreamSubscription? _subscription;
  Timer? _timer;

  @override
  String get name => 'image';

  @override
  String get help => 'Generate assets/images resource, required file must be PNG、JPG、SVG.';

  @override
  ArgParser get argParser => ArgParser()
    ..addFlag('watch', abbr: 'w', help: 'Whether to listen the changes in assets.', defaultsTo: true)
    ..addOption('output', abbr: 'o', help: 'Default output directory.', defaultsTo: 'generated');

  @override
  Future<void> parser(List<String> arguments) async {
    final argResults = argParser.parse(arguments);
    final watch = argResults['watch'];
    outputDir = argResults['output'];

    final root = Directory(path.join(await PROJECT_PATH, _path));
    if (!root.existsSync()) {
      throw 'The directory of "$_path" does not exist under the project.';
    }
    rootDir = root;

    _subscription?.cancel();
    await _generateAssetsImageFile();

    // 检查资源是否注册到pubspec.yaml文件
    final registered = await checkAssetsRegistered('assets/images/');
    if (!registered) await registerAssets('assets/images/');
    await runPubGet();

    // 判断是否监听文件夹内容改变
    if (watch) {
      logger.i('\r');
      _subscription = root.watch().listen(_watchChanged);
    } else {
      logger.i('\rProcess finished with exit code 0');
    }
  }

  void _watchChanged(FileSystemEvent event) {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 1), _generateAssetsImageFile);
  }

  // 生成assets_images.g.dart文件
  Future<void> _generateAssetsImageFile() async {
    logger.i('analyzing image...\n');
    _parse(rootDir);
    logger.i('generate file...\n');
    // 创建待生成文件
    final generateFile = File(path.join(await PROJECT_PATH, 'lib/$outputDir/assets_images.g.dart'));
    if (!generateFile.existsSync()) generateFile.createSync(recursive: true);
    // 生成文件内容
    final sb = StringBuffer();
    sb.writeln(license);
    sb.writeln();
    sb.writeln('// ignore_for_file: constant_identifier_names');
    sb.writeln();
    sb.writeln('class AssetsImages {');
    sb.writeln('AssetsImages._();');
    sb.writeln();
    _contents.forEach((key, value) {
      sb.writeln('static const $key = \'assets/images/$value\';');
    });
    sb.writeln('}');
    // 将内容写入文件
    final statement = DartFormatter(pageWidth: 120).format(sb.toString());
    generateFile.writeAsStringSync(statement, flush: true);
  }

  // 获取图片资源
  void _parse(Directory root) {
    final fileList = root.listSync();
    for (final file in fileList) {
      if (FileSystemEntity.isFileSync(file.path)) {
        final entry = _generateEntry(root, file);
        if (entry != null) _contents.putIfAbsent(entry.key, () => entry.value);
      } else {
        _parse(Directory(file.path));
      }
    }
  }

  MapEntry<String, String>? _generateEntry(Directory root, FileSystemEntity file) {
    var fileName = path.basename(file.path);
    // 如果是隐藏文件,则跳过
    if (fileName.startsWith('.')) return null;

    // 不支持的文件格式,则跳过
    final extension = path.extension(file.path);
    if (!_extensions.contains(extension)) return null;

    fileName = path.basenameWithoutExtension(file.path);
    // 针对ios截取@之前的部分
    if (fileName.contains('@')) {
      fileName = fileName.substring(0, fileName.indexOf('@'));
    }
    // 替换字符串中的空格、中划线,大写字母替换为下划线加小写字母
    fileName = fileName.replaceAll(' ', '_');
    fileName = fileName.replaceAll('-', '_');
    fileName = fileName.replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match[0]!.toLowerCase()}');

    final relativePath = path.relative(file.path, from: rootDir.path).replaceAll('\\', '/');
    print('${file.path}, $fileName --- $relativePath');
    return MapEntry(fileName, relativePath);
  }
}
