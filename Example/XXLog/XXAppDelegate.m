//
//  XXAppDelegate.m
//  XXLog
//
//  Created by lixinxing on 11/26/2021.
//  Copyright (c) 2021 lixinxing. All rights reserved.
//

#import "XXAppDelegate.h"
#import "XXLog_Example-Swift.h"
@import XXLog.XXLogHelper;

@implementation XXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 设置日志文件保存目录。
    NSString* logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/log"];
    XXLogConfig *config;
#ifdef DEBUG
    config = [[XXLogConfig alloc] initWithPath:logPath level:XXLogLevelDebug isConsoleLog:true pubKey:nil cacheDays:7];
#else
    config = [[XXLogConfig alloc] initWithPath:logPath level:XXLogLevelVerbose isConsoleLog:false pubKey:nil cacheDays:7];
#endif
    [[XXLogHelper sharedHelper] setupConfig:config];
    
    LOG_DEBUG("模块名", @"我是日志内容-使用OC打印");
    
    TestSwift *test = [[TestSwift alloc] init];
    [test test];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [XXLogHelper logAppenderClose];
}

@end
