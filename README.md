XXLog是一个基于[Mars](https://github.com/Tencent/mars)开发的日志框架，基于`Mars`的日志组件进行了封装，可以方便的在`OC`和`Swift`中进行使用

## 说明
在项目开发中，我们除了常规的控制台查看日志之外，还会碰到测试人员或用户出现异常情况无法定位情况，如果能看到项目运行全流程的日志，那么对问题的排查将会如虎添翼。
`Mars`框架提供了高可靠性高性能的运行期日志组件`xlog`，但是它并不是开箱即用的，文档也并不完善，需要你下载项目进行编译和封装才能很好的使用。此项目对它进行了二次封装，以方便用户进行使用。

## 安装
推荐使用Cocoapods进行安装，在项目的`Podfile`中添加：

```ruby
pod 'XXLog', '~> 0.1.0'
```

## 使用

### 项目中日志的配置及使用
使用样例进行说明。
OC样例：
```objective-c
// 第一步，需要初始化配置。

@import XXLog.LogHelper;

// 日志文件保存目录。
NSString* logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/log"];
XXLogConfig *config;
#ifdef DEBUG
config = [[XXLogConfig alloc] initWithPath:logPath level:XXLogLevelDebug isConsoleLog:true pubKey:nil cacheDays:7];
#else
config = [[XXLogConfig alloc] initWithPath:logPath level:XXLogLevelVerbose isConsoleLog:false pubKey:nil cacheDays:7];
#endif
[[LogHelper sharedHelper] setupConfig:config];

// 第二步，初始化后即可使用。
LOG_DEBUG("模块名", @"我是日志内容-使用OC打印");

```

Swift样例：
```swift
// 第一步，需要初始化配置。

var logLevel: XXLogLevel
var isConsoleLog: Bool
#if DEBUG
logLevel = .debug
isConsoleLog = true
#else
logLevel = .info
isConsoleLog = false
#endif
// 日志文件保存目录。
let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
let path =  NSString.path(withComponents: [documentPath, "log"])
let config = XXLogConfig.init(path: path, level: logLevel, isConsoleLog: isConsoleLog, pubKey: nil, cacheDays: 7)
LogHelper.shared().setupConfig(config)

// 第二步，初始化后即可使用。
LOG_WARNING("模块名", "我说日志内容--使用swift打印")
```

### 日志的导出
一般来讲，日志的导出分为模拟器和真机，在模拟器上，可以直接打开模拟器上日志文件所在目录，拿到日志文件。
在真机上，一般通过网络接口上传日志文件到服务器，然后从服务器下载获取。

### 日志的解码
日志文件是压缩和加密的（可以选择是否加密），导出后无法直接查看，需要进行解码。解码的脚本在项目的`script`目录下。
里面有三个脚本，分别是`gen_key.py`（生成密钥脚本）、`decode_mars_nocrypt_log_file.py`（不加密）和`decode_mars_crypt_log_file.py`（加密），后两个脚本在`Mars`项目中都是用`python2`编写，但是有开发者在项目的[issue](https://github.com/Tencent/mars/issues/804)中提供了`python3`的脚本，我这里提供的脚本是`Python3`版本的
这两个python脚本都需要安装依赖才能运行，它们均依赖于`zstandard`，加密日志解码脚本还依赖于`pyelliptic`。

#### 依赖安装
- 均需要依赖库`zstandard`，直接`pip3 install zstandard`安装
- 使用`decode_mars_crypt_log_file.py`加密log解码脚本，需要额外安装依赖`pyelliptic`，当前环境默认安装到是`1.5.8`版本，但是实际需要安装`1.5.10`版本，通过`pip3 install https://github.com/mfranciszkiewicz/pyelliptic/archive/1.5.10.tar.gz\#egg\=pyelliptic`命令进行安装。详细说明见[issue](https://github.com/Tencent/mars/issues/501)

#### 不加密日志文件的解码
直接使用`decode_mars_nocrypt_log_file.py`脚本对日志文件进行解密即可，命令：
`python3 decode_mars_nocrypt_log_file.py 日志文件路径`

执行完命令后会在日志文件路径下生成一个新的`.log`文件，直接打开这个`.log`文件即可查看日志

#### 加密log文件的解码
`xlog`使用非对称加密，使用前需要使用提供的脚本`gen_key.py`生成公钥和私钥。
在框架api调用时设置公钥，则会使用这个公钥对日志进行加密。然后在解码脚本中设置好相应的公钥和私钥，样例如下：

- 项目中：
```obj-c
// 脚本生成的公钥
NSString *pubKey = @"572d1e2710ae5fbca54c76a382fdd44050b3a675cb2bf39feebe85ef63d947aff0fa4943f1112e8b6af34bebebbaefa1a0aae055d9259b89a1858f7cc9af9df1";
XXLogConfig *config = [[XXLogConfig alloc] initWithPath:logPath level:XXLogLevelVerbose isConsoleLog:false pubKey:pubKey cacheDays:7];
[[LogHelper sharedHelper] setupConfig:config];
```

- 脚本`decode_mars_crypt_log_file.py`中：
```python
# ...
PRIV_KEY = "145aa7717bf9745b91e9569b80bbf1eedaa6cc6cd0e26317d810e35710f44cf8"
PUB_KEY = "572d1e2710ae5fbca54c76a382fdd44050b3a675cb2bf39feebe85ef63d947aff0fa4943f1112e8b6af34bebebbaefa1a0aae055d9259b89a1858f7cc9af9df1"
# ...
```

设置好公钥和私钥后，则调用命令进行解码：`python3 script/decode_mars_crypt_log_file.py 日志文件`，
执行完命令后会在日志文件路径下生成一个新的`.log`文件，直接打开这个`.log`文件即可查看日志


## 包大小对比
环境：新建项目release方式run在iphonexr上
新打包大小： 184kb
添加XXLog后打包大小：1.1MB
