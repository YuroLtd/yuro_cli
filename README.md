```dart
// To install 

pub global activate yuro_cli

flutter pub global activate yuro_cli
  
// 配置环境变量（Mac）
export HOME=/Users/admin
  
export FLUTTER_HOME=${HOME}/Library/Android/flutter
export PATH=${PATH}:${FLUTTER_HOME}/bin

export FLUTTER_PUB_HOME=${FLUTTER_HOME}/.pub-cache
export PATH=${PATH}:${FLUTTER_PUB_HOME}/bin

export DART_HOME=${FLUTTER_HOME}/bin/cache/dart-sdk
export PATH=${PATH}:${DART_HOME}/bin

export PUB_HOME=${HOME}/.pub-cache
export PATH=${PATH}:${PUB_HOME}/bin
  
// generate images
yuro generate images
  
// generate locales
yuro generate locales
```

