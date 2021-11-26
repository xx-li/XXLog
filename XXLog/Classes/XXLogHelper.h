
#import <Foundation/Foundation.h>
#import "XXLogConfig.h"


#define LogInternal(level, module, file, line, func, format, ...) \
do { \
    if ([XXLogHelper shouldLog:level]) { \
        NSString *aMessage = [NSString stringWithFormat:format, ##__VA_ARGS__, nil]; \
        [XXLogHelper logWithLevel:level moduleName:module fileName:file lineNumber:line funcName:func message:aMessage]; \
    } \
} while(0)

#define __FILENAME__ (strrchr(__FILE__,'/')+1)

/// 这几个宏调用前必须先调用LogHelper的setupConfig:方法设置log配置
#define LOG_ERROR(module, format, ...) LogInternal(XXLogLevelError, module, __FILENAME__, __LINE__, __FUNCTION__,  format, ##__VA_ARGS__)
#define LOG_WARNING(module, format, ...) LogInternal(XXLogLevelWarn, module, __FILENAME__, __LINE__, __FUNCTION__,  format, ##__VA_ARGS__)
#define LOG_INFO(module, format, ...) LogInternal(XXLogLevelInfo, module, __FILENAME__, __LINE__, __FUNCTION__,  format, ##__VA_ARGS__)
#define LOG_DEBUG(module, format, ...) LogInternal(XXLogLevelDebug, module, __FILENAME__, __LINE__, __FUNCTION__,  format, ##__VA_ARGS__)

/// 用于辅助配置Mars Xlog和提供一些快捷api的辅助类
///
/// 注意：打印日志前，必须先调用`setupConfig:`配置
///
@interface XXLogHelper : NSObject

@property(strong, nonatomic, readonly) XXLogConfig * config;

+ (instancetype)sharedHelper;

/// 设置log的配置信息，需要在调用log前先调用
- (void)setupConfig:(XXLogConfig *)config;

/// 获取本地日志文件路径列表
- (NSArray *)getLogFilePathList;

/// 清空本地日志
- (void)clearLocalLogFile;

/*! 日志产生后，会被写入逻辑内存，在应用即将被回收时，需要调用该方法，保存数据到缓存目录
 *  在应用即将被回收时调用
 *  - (void)applicationWillTerminate:(UIApplication *)application {
 *      [LogHelper logAppenderClose];
 *  }
 */
+ (void)logAppenderClose;

/// 上传前刷新缓存表，防止数据更新不及时。（不调用会存在日志丢失的情况）
+ (void)logAppenderFlush;

/// 写入log
+ (void)logWithLevel:(XXLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
             message:(NSString *)message;

+ (void)logWithLevel:(XXLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
              format:(NSString *)format, ...;

+ (BOOL)shouldLog:(XXLogLevel)level;

@end


