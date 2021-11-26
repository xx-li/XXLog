//
//  XXLogConfig.h
//  XXLogDemo
//
//  Created by Stellar on 2021/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XXLogLevel) {
    XXLogLevelAll = 0,
    XXLogLevelVerbose = 0,
    XXLogLevelDebug,    // Detailed information on the flow through the system.
    XXLogLevelInfo,     // Interesting runtime events (startup/shutdown), should be conservative and keep to a minimum.
    XXLogLevelWarn,     // Other runtime situations that are undesirable or unexpected, but not necessarily "wrong".
    XXLogLevelError,    // Other runtime errors or unexpected conditions.
    XXLogLevelFatal,    // Severe errors that cause premature termination.
    XXLogLevelNone,     // Special level used to disable all log messages.
};


@interface XXLogConfig : NSObject

/// 日志点本地存储目录
@property(copy, nonatomic, readonly) NSString * path;

/// 是否允许控制台输出。 建议release模式下设为false禁用控制台输出
@property(assign, nonatomic, readonly) BOOL isConsoleLog;

@property(assign, nonatomic, readonly) XXLogLevel level;

/// 对日志加密的公钥，如果不需要加密，传入nil
@property(copy, nonatomic, nullable, readonly) NSString * pubKey;

/// 缓存的天数
@property(assign, nonatomic, readonly) NSUInteger cacheDays;

- (instancetype)initWithPath:(NSString *)path
                       level:(XXLogLevel)level
                isConsoleLog:(BOOL)isConsoleLog
                      pubKey:(nullable NSString *)pubKey
                   cacheDays:(NSUInteger)cacheDays;

@end

NS_ASSUME_NONNULL_END
