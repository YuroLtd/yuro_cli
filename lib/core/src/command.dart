part of '../core.dart';

/// 执行"flutter pub get"命令
Future<bool> runPubGet() async {
  final res = await runExecutableArguments('flutter', ['pub', 'get'], verbose: true);
  return res.exitCode == 0;
}

/// 执行flutter pub run build_runner build
Future<bool> runBuildRunner(bool delete) async {
  logger.i('\r');
  final params = ['pub', 'run', 'build_runner', 'build'];
  if (delete) params.add('--delete-conflicting-outputs');
  final res = await runExecutableArguments('flutter', params, verbose: true);
  return res.exitCode == 0;
}

/// 执行flutter pub run build_runner build
Future<bool> runUpdateCLI() async {
  final res = await runExecutableArguments('dart', ['pub', 'global', 'activate', 'yuro_cli'], verbose: true);
  return res.exitCode == 0;
}
