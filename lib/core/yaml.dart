part of 'core.dart';

enum PackagePosition {
  dependencies('dependencies'),
  devDependencies('dev_dependencies'),
  dependencyOverrides('dependency_overrides'),
  flutter('flutter');

  final String value;

  const PackagePosition(this.value);
}

/// 获取CLI的本地版本
Future<String> getCLIVersion() async {
  final lockFile = getCLILockFile();
  final yamlMap = loadYaml(lockFile.readAsStringSync()) as YamlMap;
  return yamlMap['packages']['yuro_cli']['version'].toString();
}

/// 判断资源目录是否已经注册到pubspec.yaml文件中
Future<bool> checkAssetsRegistered(String path) async {
  final yamlFile = await getYamlFile();
  var yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  if (yamlMap.containsKey('flutter')) {
    final flutter = yamlMap['flutter'] as YamlMap?;
    if (flutter != null) {
      final assets = flutter['assets'] as YamlList?;
      return assets?.contains(path) ?? false;
    }
  }
  return false;
}

/// 注册资源目录到pubspec.yaml文件中
Future<void> registerAssets(String path) async {
  logger.i('\nregister $path...\n');
  final yamlFile = await getYamlFile();
  var yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  if (!yamlMap.containsKey('flutter')) {
    yamlFile.writeAsStringSync('\n\rflutter:', mode: FileMode.append, flush: true);
    yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  }

  if (!yamlMap.containsKey('assets')) {
    yamlFile.writeAsStringSync('\r  assets:', mode: FileMode.append, flush: true);
    yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  }

  if (!yamlMap.containsKey(path)) {
    yamlFile.writeAsStringSync('\r    - $path', mode: FileMode.append, flush: true);
  }
}

/// 获取Yaml文件指定属性的值
Future<dynamic> getAttributeValue(String attribute) async {
  final yamlFile = await getYamlFile();
  final yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  return yamlMap[attribute];
}

/// 检查package是否注册到yaml中
Future<bool> checkPackageRegistered(PackagePosition position, String package) async {
  final yamlFile = await getYamlFile();
  final rootYamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  if (rootYamlMap.containsKey(position.value)) {
    final childYamlMap = rootYamlMap[position.value] as YamlMap?;
    return childYamlMap?.containsKey(package) ?? false;
  }
  return false;
}

/// 在pubspec.yaml文件中的[position]注册最新版本的[package]
Future<void> registerPackage(PackagePosition position, String package) async {
  final yamlFile = await getYamlFile();
  var yamlFileContent = yamlFile.readAsLinesSync();
  var rootYamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;

  if (!rootYamlMap.containsKey(position.value)) {
    logger.i('Register package position "${position.value}" in pubspec.yaml.\n');
    var insertLine = -1;
    if (position == PackagePosition.dependencyOverrides) {
      insertLine = _findTargetLine(yamlFileContent, rootYamlMap, PackagePosition.dependencies);
    } else if (position == PackagePosition.devDependencies) {
      insertLine = _findTargetLine(yamlFileContent, rootYamlMap, PackagePosition.dependencyOverrides);
      if (insertLine == -1) {
        insertLine = _findTargetLine(yamlFileContent, rootYamlMap, PackagePosition.dependencies);
      }
    }
    insertLine == -1
        ? yamlFileContent.add('\r${position.value}:')
        : yamlFileContent.insert(++insertLine, '\r${position.value}:');
    await writeFile(yamlFile, yamlFileContent);
    // 重新加载
    yamlFileContent = yamlFile.readAsLinesSync();
    rootYamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  }
  logger.i('Register "$package" in pubspec.yaml.\n');

  if (package == 'flutter_localizations') {
    var insertLine = _findTargetLine(yamlFileContent, rootYamlMap, position, target: 'flutter');
    yamlFileContent.insert(++insertLine, '  flutter_localizations:');
    yamlFileContent.insert(++insertLine, '    sdk: flutter');
  } else if (package == 'generate') {
    var insertLine = _findTargetLine(yamlFileContent, rootYamlMap, position);
    yamlFileContent.insert(++insertLine, '  generate: true');
  } else {
    var insertLine = _findTargetLine(yamlFileContent, rootYamlMap, position);
    final version = await getRemoteVersion(package);
    yamlFileContent.insert(++insertLine, '  $package: ^$version');
  }
  await writeFile(yamlFile, yamlFileContent);
}

/// 查找目标的最后一行
int _findTargetLine(List<String> yamlFileContent, YamlMap yamlMap, PackagePosition position, {String? target}) {
  final rootMap = yamlMap[position.value] as YamlMap?;
  if (rootMap != null) {
    final yamlNode = rootMap.keys.contains(target) ? rootMap.nodes[target] : rootMap.nodes[rootMap.keys.last];
    if (yamlNode is YamlScalar) {
      return yamlNode.span.end.line;
    } else if (yamlNode is YamlMap) {
      var line = yamlNode.span.end.line - 1;
      if (yamlFileContent[line].isEmpty) --line;
      return line;
    }
  } else {
    return yamlFileContent.indexWhere((e) => e.contains('${position.value}:'));
  }
  return -1;
}

Future<void> writeFile(File file, List<String> content) async {
  final iOSink = file.openWrite();
  content.forEach((element) => iOSink.writeln(element));
  await iOSink.flush();
  await iOSink.close();
}
