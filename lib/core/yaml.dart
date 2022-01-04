part of 'core.dart';

enum PackagePosition { dependencies, devDependencies, dependencyOverrides }

extension PackagePositionExt on PackagePosition {
  String get str {
    switch (this) {
      case PackagePosition.dependencies:
        return 'dependencies';
      case PackagePosition.dependencyOverrides:
        return 'dependency_overrides';
      case PackagePosition.devDependencies:
        return 'dev_dependencies';
    }
  }
}

/// 注册资源目录到pubspec.yaml文件中
Future<bool> registerAssets(String path) async {
  final yamlFile = await getYmalFile();
  if (yamlFile == null) return false;
  var yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  if (!yamlMap.containsKey('flutter')) {
    yamlFile.writeAsStringSync('\n\rflutter:', mode: FileMode.append, flush: true);
    yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  }
  var flutter = yamlMap['flutter'] as YamlMap?;
  if (flutter == null || !flutter.containsKey('assets')) {
    yamlFile.writeAsStringSync('\r  assets:', mode: FileMode.append, flush: true);
    yamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  }
  final assets = flutter?['assets'] as YamlList?;
  if (assets == null || !assets.contains(path)) {
    yamlFile.writeAsStringSync('\r    - $path', mode: FileMode.append, flush: true);
    return true;
  }
  return false;
}

/// 检查package是否注册到yaml中
Future<bool> checkPackageRegister(String package, PackagePosition position) async {
  final yamlFile = await getYmalFile();
  if (yamlFile == null) return false;
  var yamlFileContent = yamlFile.readAsLinesSync();
  var rootYamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  if (!rootYamlMap.containsKey(position.str)) {
    logger.i('Register "${position.str}" in pubspec.yaml.\n');

    var insertLine = -1;
    // 注册dev_dependencies到yaml文件中
    if (position == PackagePosition.devDependencies) {
      insertLine = _findDependencyLastLine(rootYamlMap, PackagePosition.dependencyOverrides.str, yamlFileContent);
      if (insertLine == -1) {
        insertLine = _findDependencyLastLine(rootYamlMap, PackagePosition.dependencies.str, yamlFileContent);
      }
      if (insertLine == -1) {
        logger.e('Cannot find "dependency" or "dependency_overrides" in the pubspec.yaml file');
        return false;
      }
    }
    yamlFileContent.insert(++insertLine, '\r${position.str}:');
    final writeResult = await _writeYamlFile(yamlFile, yamlFileContent);
    if (writeResult) {
      yamlFileContent = yamlFile.readAsLinesSync();
      rootYamlMap = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
    }
  }

  final childYamlMap = rootYamlMap[position.str] as YamlMap?;
  if (childYamlMap == null || !childYamlMap.containsKey(package)) {
    logger.i('Register "$package" in pubspec.yaml.\n');
    final version = await getRemoteVersion(package);
    if (version != null) {
      var insertLine = _findDependencyLastLine(rootYamlMap, position.str, yamlFileContent);
      yamlFileContent.insert(++insertLine, '  $package: ^$version');
      final writeResult = await _writeYamlFile(yamlFile, yamlFileContent);
      // 写入成功，执行flutter pub get命令
      if (writeResult) await runFlutterPubGet();
      return writeResult;
    } else {
      logger.e('Failed to get the latest version of "$package", please try again.');
      return false;
    }
  }
  return true;
}

/// 查找dependency的上一行的位置
int _findDependencyLastLine(YamlMap rootMap, String dependencyName, List<String> yamlFileContent) {
  var dependency = rootMap[dependencyName] as YamlMap?;
  if (dependency != null) {
    final yamlNode = dependency.nodes[dependency.keys.last];
    if (yamlNode is YamlScalar) {
      return yamlNode.span.end.line;
    } else if (yamlNode is YamlMap) {
      final lastNode = yamlNode.nodes[yamlNode.keys.last];
      return (lastNode as YamlScalar).span.end.line;
    }
  } else {
    return yamlFileContent.indexOf('$dependencyName:');
  }
  return -1;
}

Future<bool> _writeYamlFile(File yamlFile, List<String> content) async {
  try {
    final iOSink = yamlFile.openWrite();
    content.forEach((element) => iOSink.writeln(element));
    await iOSink.close();
    return true;
  } on Exception catch (_) {
    logger.e('"pubspec.yaml" write failed, please try again.');
    return false;
  }
}
