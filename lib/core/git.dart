part of 'core.dart';

/// 获取git提交次数
Future<int?> gitCommitCount() async {
  final gitCount = await runExecutableArguments('git', ['rev-list', '--count', 'HEAD']);
  if (gitCount.exitCode != 0) logger.w(gitCount.stderr);
  return int.tryParse(gitCount.stdout);
}

/// 利用git生成类似于"branch_short_yyMMddHHmm"的构建信息
Future<String> gitBuildInfo() async {
  final branch = await runExecutableArguments('git', ['symbolic-ref', '--short', '-q', 'HEAD']);
  final short = await runExecutableArguments('git', ['rev-parse', '--short', 'HEAD']);
  final date = DateTime.now();
  final year = date.year.toString().substring(2);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${branch.stdout}_${short.stdout}_$year$month$day$hour$minute'.replaceAll('\n', '');
}
