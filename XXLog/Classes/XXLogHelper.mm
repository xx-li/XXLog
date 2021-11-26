#import "XXLogHelper.h"

#import <sys/xattr.h>
#import <mars/xlog/xloggerbase.h>
#import <mars/xlog/xlogger.h>
#import <mars/xlog/appender.h>

static NSUInteger g_processID = 0;

@implementation XXLogHelper

+ (instancetype)sharedHelper {
    
    static id singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[[self class] alloc] init];
    });
    return singleton;
}

#pragma mark - 日志配置

- (void)setupConfig:(XXLogConfig *)logConfig {
    const char * path = [logConfig.path UTF8String];
    const char * pubKey = logConfig.pubKey ? [logConfig.pubKey UTF8String] : "";
    
    const char* attrName = "com.xxlog.backup";
    u_int8_t attrValue = 1;
    setxattr(path, attrName, &attrValue, sizeof(attrValue), 0, 0);
    xlogger_SetLevel((TLogLevel)logConfig.level);
    mars::xlog::appender_set_console_log(logConfig.isConsoleLog);

    mars::xlog::XLogConfig config;
    config.mode_ = mars::xlog::kAppenderAsync;
    config.logdir_ = path;
    config.nameprefix_ = "log";
    config.pub_key_ = pubKey;
    config.compress_mode_ = mars::xlog::kZlib;
    config.compress_level_ = 0;
    config.cachedir_ = "";
    config.cache_days_ = (int)logConfig.cacheDays;
    appender_open(config);
    
    _config = logConfig;
    
    LOG_DEBUG("XXLOG", @"XXLog配置完成✅，本地日志文件地址：%@", logConfig.path);
}

- (NSArray *)getLogFilePathList {
    NSMutableArray *logArr = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = self.config.path;
    if ([fileManager fileExistsAtPath:path]) {
        NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
        for (NSString *fileName in enumerator) {
            if ([fileName hasSuffix:@".xlog"]) {
                NSString *enumeratorPath = [NSString pathWithComponents:@[path, fileName]];
                [logArr addObject:enumeratorPath];
            }
        }
    }    
    return logArr;
}

- (void)clearLocalLogFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = self.config.path;
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
    for (NSString *fileName in enumerator) {
        if ([fileName hasSuffix:@".xlog"]) {
            NSString *logFilePath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:logFilePath error:nil];
        }
    }
}


+ (void)logAppenderClose {
    mars::xlog::appender_close();
}

+(void)logAppenderFlush {
    mars::xlog::appender_flush_sync();
}

#pragma mark - 日志打印相关

+ (void)logWithLevel:(XXLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
             message:(NSString *)message {
    XLoggerInfo info;
    info.level = (TLogLevel)logLevel;
    info.tag = moduleName;
    info.filename = fileName;
    info.func_name = funcName;
    info.line = lineNumber;
    gettimeofday(&info.timeval, NULL);
    info.tid = (uintptr_t)[NSThread currentThread];
    info.maintid = (uintptr_t)[NSThread mainThread];
    info.pid = g_processID;
    xlogger_Write(&info, message.UTF8String);
}

+ (void)logWithLevel:(XXLogLevel)logLevel
          moduleName:(const char*)moduleName
            fileName:(const char*)fileName
          lineNumber:(int)lineNumber
            funcName:(const char*)funcName
              format:(NSString *)format, ... {
    if ([self shouldLog:logLevel]) {
        va_list argList;
        va_start(argList, format);
        NSString* message = [[NSString alloc] initWithFormat:format arguments:argList];
        [self logWithLevel:logLevel moduleName:moduleName fileName:fileName lineNumber:lineNumber funcName:funcName message:message];
        va_end(argList);
    }
}

+ (BOOL)shouldLog:(XXLogLevel)level {
    return (TLogLevel)level >= xlogger_Level();
}

@end
