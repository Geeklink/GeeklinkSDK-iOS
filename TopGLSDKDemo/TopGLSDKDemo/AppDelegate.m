//
//  AppDelegate.m
//  TopGLSDKDemo
//
//  Created by 杨飞飞 on 2020/4/15.
//  Copyright © 2020 杨飞飞. All rights reserved.
//

#import "AppDelegate.h"
#import <GeeklinkSDK/SDK.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   // 需要填入申请的appID和Secret
      [TopGLAPIManager initManagerWithAppId:@"875da62ac55ff12a" andSecret:@"d4f7b957875da62ac55ff12aeba6e44f"];
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[TopGLAPIManager shareManager] stopNetwork];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[TopGLAPIManager shareManager] networkContinue];
}





@end
