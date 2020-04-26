//
//  TopEZCamTools.m
//  Top
//
//  Created by 列树童 on 2017/12/1.
//  Copyright © 2017年 Geeklink. All rights reserved.
//

#import "TopEZCamTools.h"
#import "GlobalKit.h"

//#import "EZOpenSDK.h"
//#import "EZHCNetDeviceSDK.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>

@implementation TopEZCamTools

+ (TopEZCamTools *)shareTopEZCamTools {
    static TopEZCamTools *sharedTopEZCamTools;
    
    @synchronized(self) {
        
        if (!sharedTopEZCamTools) {
            sharedTopEZCamTools = [TopEZCamTools new];
            
            if (EZVIZ_App_Key.length != 0) {//初始化SDK
                
#ifndef SIMULATOR
                [[EZOpenSDK class] initLibWithAppKey:EZVIZ_App_Key];
                [EZHCNetDeviceSDK initSDK];
                [[EZOpenSDK class] enableP2P:YES];
                [[EZOpenSDK class] setDebugLogEnable:YES];
                NSLog(@"EZOpenSDK Version = %@", [[EZOpenSDK class] getVersion]);
                
                if ([GlobalKit shareKit].accessToken) {//设置Token
                    [[EZOpenSDK class] setAccessToken:[GlobalKit shareKit].accessToken];
                }
#endif
            }
        }
        return sharedTopEZCamTools;
    }
}

- (void)checkDevList {
    if ([GlobalKit shareKit].accessToken == nil) {
        return;
    }
    if (EZVIZ_App_Key.length != 0) {
       
//        NSLog(@"checkDevList");
       
        if ([GlobalKit shareKit].accessToken) {//获取设备
            
#ifndef SIMULATOR
            [[EZOpenSDK class] getDeviceList:0
                                    pageSize:15
                                  completion:^(NSArray *deviceList, NSInteger totalCount, NSError *error) {
                                      self.adminList = deviceList;
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"onEZCamToolsDevListChange" object:nil];
                                  }];
            
            [[EZOpenSDK class] getSharedDeviceList:0
                                          pageSize:15
                                        completion:^(NSArray *deviceList, NSInteger totalCount, NSError *error) {
                                            self.shareList = deviceList;
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"onEZCamToolsDevListChange" object:nil];
                                        }];
#endif
        }
    }
}

- (NSArray *)loadAdminList {
    return self.adminList;
}

- (NSArray *)loadShareList {
    return self.shareList;
}
- (NSArray *)adminList{
    if (_adminList == nil){
        _adminList = [NSArray array];
    }
    return _adminList;
}
- (NSArray *)shareList{
    if (_shareList == nil){
        _shareList = [NSArray array];
    }
    return _shareList;
}
- (void)cleanCamList {
    _adminList = nil;
    _shareList = nil;
}

@end
