1.config environment variable
```
// Mac
export DART_PUB_HOME=/Users/.pub-cache
export PATH=${PATH}:${PUB_HOME}/bin

// Windows
// add user environment variable 
DART_PUB_HOME=C:\Users\administrator\AppData\Local\Pub\Cache

// add bin in path
%DART_PUB_HOME%\bin

```
2.install yuro_cli
```
<dart> pub global activate yuro_cli
```
  
3.use

3.1.`yuro gen image`
  
3.2.`yuro gen locale`

3.3.`yuro run build_runner`


