import 'package:yuro_cli/command/command.dart';
import 'package:yuro_cli/core/core.dart';

class BuildRunner extends Command {
  @override
  String get name => 'build_runner';

  @override
  String get help => 'execute cmd "flutter packages pub run build_runner build"';

  @override
  ArgParser get argParser => ArgParser()
    ..addFlag('delete', abbr: 'd', help: 'The command contains --delete-conflicting-outputs.', defaultsTo: false);

  @override
  Future<void> parser(List<String> arguments) async {
    final argResults = argParser.parse(arguments);
    bool delete = argResults['delete'];
    final checkResult = await checkPackageRegister(name, PackagePosition.devDependencies);
    if (checkResult) {
      // 执行"flutter packages pub run build_runner build"命令,当[delete]为true时,增加参数"--delete-conflicting-outputs"
      final arguments = ['pub', 'run', 'build_runner', 'build'];
      if (delete) arguments.add('--delete-conflicting-outputs');
      final res = await runExecutableArguments('flutter', arguments, verbose: true);
      if (res.exitCode != 0) {
        logger.e('\nError: ${res.stderr}');
      }
    }
    logger.i('Process finished.\n');
  }
}
