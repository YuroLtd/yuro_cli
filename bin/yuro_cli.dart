import 'package:yuro_cli/yuro_cli.dart' as yuro;

void main(List<String> arguments) {
  yuro.inject();
  yuro.parseArgs(arguments);
}
