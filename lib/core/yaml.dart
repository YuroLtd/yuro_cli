part of 'core.dart';

/// 获取CLI的本地版本
Future<String> getCLIVersion() async {
  final lockFile = getCLILockFile();
  final yamlMap = loadYaml(lockFile.readAsStringSync()) as YamlMap;
  return yamlMap['packages']['yuro_cli']['version'].toString();
}

/// 判断资源目录是否已经注册到pubspec.yaml文件中
Future<void> registerAssets(List<String> paths) async {
  final yamlFile = await getYamlFile();
  final editor = YamlEditor(yamlFile.readAsStringSync());

  final flutterMap = Map.from(editor.parseAt(['flutter'], orElse: () => YamlMap()).value);
  final assets = List.from(flutterMap.putIfAbsent('assets', () => YamlList()));

  final list = paths.where((element) => !assets.contains(element));
  if (list.isNotEmpty) {
    assets.addAll(list);
    flutterMap['assets'] = YamlList.wrap(assets);
    editor.update(['flutter'], YamlMap.wrap(flutterMap));
    await yamlFile.writeAsString(editor.toString(), flush: true);
    await runPubGet();
  }
}

/// position:
///  dependencies
///  dev_dependencies
///  dependency_overrides
Future<void> registerPackage(String package, [String position = 'dependencies']) async {
  final yamlFile = await getYamlFile();
  final editor = YamlEditor(yamlFile.readAsStringSync());

  final positionMap = Map.from(editor.parseAt([position], orElse: () => YamlMap()).value);
  if (!positionMap.containsKey(package)) {
    final version = await getRemoteVersion(package);
    positionMap[package] = '^$version';
    editor.update([position], YamlMap.wrap(positionMap));
    await yamlFile.writeAsString(editor.toString(), flush: true);
    await runPubGet();
  }
}
