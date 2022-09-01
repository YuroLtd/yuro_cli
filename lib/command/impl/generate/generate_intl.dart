import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateIntl extends Command {
  @override
  String get name => 'intl';

  @override
  String get help => 'Generate localizations for the current project.';

  @override
  Future<void> parser(List<String> arguments) async {
    // 创建l10n.yaml文件到项目根目录
    final l10nYamlFile = File(path.join(await PROJECT_PATH, 'l10n.yaml'));
    if (!l10nYamlFile.existsSync()) {
      l10nYamlFile.createSync();
      final ioSink = l10nYamlFile.openWrite();
      ioSink.write(_l10nYamlContent);
      await ioSink.flush();
      await ioSink.close();
    }
    final yamlMap = loadYaml(l10nYamlFile.readAsStringSync()) as YamlMap;
    final syntheticPackage = (yamlMap.nodes['synthetic-package']?.value as bool?) ?? true;
    // 如果不是合成包,则创建output-dir目录
    if (!syntheticPackage) {
      final outputDir = (yamlMap.nodes['output-dir']?.value as String?) ?? 'lib/intl';
      final dir = Directory(path.join(await PROJECT_PATH, outputDir));
      if (!dir.existsSync()) dir.createSync(recursive: true);
    }
    // arb文件存放目录
    final arbDir = (yamlMap.nodes['arb-dir']?.value as String?) ?? 'lib/intl/l10n';
    // 创建模板文件
    final tempArbName = (yamlMap.nodes['template-arb-file']?.value as String?) ?? 'intl_zh.arb';
    final tempArbFile = File(path.join(await PROJECT_PATH, arbDir, tempArbName));
    if (!tempArbFile.existsSync()) {
      tempArbFile.createSync(recursive: true);
      final ioSink = tempArbFile.openWrite();
      ioSink.write(_tempArbContent);
      await ioSink.flush();
      await ioSink.close();
    }

    bool needRunPubGet = false;
    // 增加flutter_localizations依赖
    var checkResult = await checkPackageRegistered(PackagePosition.dependencies, 'flutter_localizations');
    if (!checkResult) {
      await registerPackage(PackagePosition.dependencies, 'flutter_localizations');
      needRunPubGet = true;
    }

    // 添加intl依赖
    checkResult = await checkPackageRegistered(PackagePosition.dependencies, 'intl');
    if (!checkResult) {
      await registerPackage(PackagePosition.dependencies, 'intl');
      needRunPubGet = true;
    }

    // 启用flutter generate
    checkResult = await checkPackageRegistered(PackagePosition.flutter, 'generate');
    if (!checkResult) {
      await registerPackage(PackagePosition.flutter, 'generate');
      needRunPubGet = true;
    }
    needRunPubGet ? await runPubGet() : logger.i('Process finished.');
  }

  String get _l10nYamlContent => '''
# Internationalization User Guide
# https://docs.google.com/document/d/10e0saTfAv32OZLRmONy866vnaw0I2jwL8zukykpgWBc/edit#

# arb文件目录
arb-dir: lib/intl/l10n

# 模板文件
template-arb-file: intl_zh.arb

# 指定本地化文件输出路径, 如果要配置此项需将[synthetic-package] 设置为false
#output-dir: lib/intl

# 输出文件名称
output-localization-file: app_localizations.dart

# 输出localizations类的名称
#output-class: AppLocalizations

# 未翻译的键输出到指定文件, {root}/desiredFileName.txt
untranslated-messages-file: desiredFileName.txt

# 首选语言, 会排在supportedLocales的第一个
# 不配置此属性时, [template-arb-file]的文件默认为首选语言
preferred-supported-locales:
  - zh

# 延迟加载
# 是否生成带有作为延迟导入的语言环境的 Dart 本地化文件，允许在 Flutter web.xml 中延迟加载每个语言环境。
#use-deferred-loading: false

# 当arb文件中没有指定翻译,是否返回null
# 如果为false, 会使用首选语言的值来返回
# 如果为true, 会返回null
#nullable-getter: false

# 指定是否是合成包 
# 当值为true,则生成文件在.dart_tool/flutter_gen/gen_l10n
# 当值为false, 这生成的文件在[arb-dir]目录下
# 注: 不建议修改该字段为true, 会导致build_runner插件无法生成代码
synthetic-package: true

# 附加到生成的 Dart 本地化文件的头部, String类型
#header: ''

# 附加到生成的 Dart 本地化文件的头部, 文件类型, 可以得到一个更长的头部
#header-file:
  ''';

  String get _tempArbContent => '''
{
  "@@locale": "zh"
}
  ''';
}
