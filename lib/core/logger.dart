import 'package:ansicolor/ansicolor.dart';

class Logger {
  final AnsiPen _penWaring = AnsiPen()..yellow();
  final AnsiPen _penError = AnsiPen()..red();

  void i(String msg) => print(msg);

  void w(String msg) => print(_penWaring(msg));

  void e(String msg) => print(_penError(msg));
}
