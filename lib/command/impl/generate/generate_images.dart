import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateImages extends Command {
  final path = 'assets/images';

  @override
  String get name => 'images';

  @override
  String get help => 'Generate assets/images resource.';

  @override
  ArgParser get argParser => ArgParser()
    ..addFlag('watch', abbr: 'w', help: 'Whether to listen the changes in assets.', defaultsTo: true)
    ..addOption('output', abbr: 'o', help: 'Default output directory.', defaultsTo: 'generated')
    ..addOption('name', abbr: 'n', help: 'The Assets Class Name.', defaultsTo: 'ImageKeys');

  @override
  Future<void> parser(List<String> arguments) async {
    var argResults = argParser.parse(arguments);
    bool watch = argResults['watch'];
    String output = argResults['output'];
    String name = argResults['name'];

    logger.i('\ngenerate images...');
    var result = await generateImages(watch, output, name);
    // 写入成功后, 检查pubspec.yaml文件是否注册了assets/images, 如果没有注册则注册该资源目录
    if (result) {
      result = await YamlUtil.registerAssets('$path/');
    }
    // 如果本次注册了资源,执行"flutter pub get"命令
    if (result) {
      await YamlUtil.runFlutterPubGet();
    }
    logger.i('Process finished.\n');
  }

  // 生成ImageKeys文件
  Future<bool> generateImages(bool isWatch, String output, String name) async {
    // 验证pubspec.yaml文件是否存在
    if (!YamlUtil.checkYamlFile()) return false;
    // 检查assets/images目录是否存在
    var dir = Directory(join(PROJECT_PATH!, path));
    if (!dir.existsSync()) {
      logger.e('\nThe directory of "$path" does not exist under the project.');
      return false;
    }
    // 创建待生成文件
    var generateFile = File(join(PROJECT_PATH!, 'lib/$output/images.g.dart'));
    if (!generateFile.existsSync()) generateFile.createSync(recursive: true);
    // 获取图片资源
    var imageFiles = dir.listSync();
    imageFiles = imageFiles.where((element) => FileSystemEntity.isFileSync(element.path)).toList();
    imageFiles.sort((a, b) => a.path.compareTo(b.path));
    // 生成文件内容
    var sb = StringBuffer();
    sb.writeln(license);
    sb.writeln('abstract class $name {');
    imageFiles.forEach((file) {
      var fileName = file.path.split('/').last;
      var fieldName = fileName.replaceAll('/', '_').replaceAll(' ', '_').replaceAll('-', '_').replaceAll('@', '_AT_');
      var fieldNames = fieldName.split('.');
      sb.writeln('\tstatic const ${fieldNames[1].toUpperCase()}_${fieldNames[0].toUpperCase()} = \'assets/images/$fileName\';');
    });
    sb.writeln('}');
    // 将内容写入文件
    generateFile.writeAsStringSync(sb.toString(), flush: true);
    return true;
  }
}
