//
//  XXLogConfig.m
//  XXLogDemo
//
//  Created by Stellar on 2021/11/25.
//

#import "XXLogConfig.h"

@implementation XXLogConfig

- (instancetype)initWithPath:(NSString *)path
                       level:(XXLogLevel)level
                isConsoleLog:(BOOL)isConsoleLog
                      pubKey:(nullable NSString *)pubKey
                   cacheDays:(NSUInteger)cacheDays {
    self = [super init];
    if (self) {
        _path =  path;
        _level = level;
        _isConsoleLog = isConsoleLog;
        _pubKey = pubKey;
        _cacheDays = cacheDays;
    }
    return self;
}

@end
