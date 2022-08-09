import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';

import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class GenerateIntl extends Command {

  @override
  String get name => 'intl';

  @override
  String get help => 'Generate localizations for the current project.';

  @override
  Future<void> parser(List<String> arguments) async {
    // 增加flutter_localizations依赖


    logger.i('Process finished.');
  }

}