part of 'core.dart';

/// 获取[package]的最新版本
Future<String> getRemoteVersion(String package) async {
  var res = await get(Uri.parse('$HOST_URL/api/packages/$package'));
  if (res.statusCode == 200) {
    return json.decode(res.body)['latest']['version'];
  } else {
    throw 'Failed to get the latest version of "$package", statusCode: ${res.statusCode}';
  }
}
