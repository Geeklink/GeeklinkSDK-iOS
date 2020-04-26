//
//  TopThinkerDataHandle.m
//  Top
//
//  Created by linter on 15/9/13.
//  Copyright (c) 2015年 Geeklink. All rights reserved.
//

#import "TopThinkerDataHandle.h"
#import "TopThkAckInfo.h"
#import "TopSlaveAckInfo.h"

@implementation TopThinkerDataHandle

- (id)initWithApi:(id<GLApi>)api {
    self = [super init];
    if (self) {
        if (api) {
            self.handle = [api observerThinkerHandle];
            [self.handle init:self];
        } else {
            NSLog(@"ERR! api should init first");
        }
    }
    return self;
}

/**温湿度校准回调 */
- (void)fromDeviceTempHumOffsetGet:(GLStateType)state homeId:(NSString *)homeId deviceId:(int32_t)deviceId tempHumInfo:(GLTempHumInfo *)tempHumInfo{
    TopSlaveAckInfo * ackInfo = [[TopSlaveAckInfo alloc] init];
    ackInfo.subDeviceId = deviceId;
    ackInfo.homeId = homeId;
    ackInfo.tempHumInfo = tempHumInfo;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fromDeviceTempHumOffsetGet" object:ackInfo];
}

/**码库智能匹配返回结果 */
- (void)onSmartMatchResponse:(NSString *)homeId deviceId:(int32_t)deviceId list:(NSArray *)list {
    TopThkAckInfo *info = [TopThkAckInfo new];
    info.homeId = homeId;
    info.deviceId = deviceId;
    info.list = list;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onSmartMatchResponse" object:info];
}

/**学习回调函数 */
- (void)onThinkerStudyResponse:(NSString *)homeId deviceId:(int32_t)deviceId studyState:(GLStudyState)studyState studyType:(int32_t)studyType studyData:(NSString *)studyData {
    
    //    NSLog(@"onThinkerStudyResponse studyData:%@", studyData);
    
    TopThkAckInfo *info = [TopThkAckInfo new];
    info.homeId = homeId;
    info.deviceId = deviceId;
    info.studyState = studyState;
    info.studyType = studyType;
    info.studyData = studyData;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onThinkerStudyResponse" object:info];
}

- (void)onGetMasterStateResponse:(NSString *)homeId deviceId:(int32_t)deviceId masterInfo:(GLThinkerCheckMasterInfo *)masterInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onGetMasterStateResponse" object:masterInfo];
}


- (void)onThinkerSetRouterInfoResponse:(NSString *)homeId deviceId:(int32_t)deviceId routerInfo:(NSString *)routerInfo {
    
    //    NSLog(@"TopThinkerDataHandle onThinkerSetRouterInfoResponse routerInfo:%@", routerInfo);
    
    TopThkAckInfo *info = [TopThkAckInfo new];
    info.homeId = homeId;
    info.deviceId = deviceId;
    info.routerInfo = routerInfo;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onThinkerSetRouterInfoResponse" object:info];
}

- (void)fromDeviceTempHumOffsetSet:(GLStateType)state homeId:(NSString *)homeId deviceId:(int32_t)deviceId {
    
    TopSlaveAckInfo * ackInfo = [[TopSlaveAckInfo alloc] init];
    ackInfo.subDeviceId = deviceId;
    ackInfo.homeId = homeId;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fromDeviceTempHumOffsetSet" object:ackInfo];
}

- (void)onSendCodeResponse:(NSString *)homeId deviceId:(int32_t)deviceId success:(BOOL)success {
    TopThkAckInfo *info = [TopThkAckInfo new];
    info.homeId = homeId;
    info.deviceId = deviceId;
    info.isSuccess = success;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onSendCodeResponse" object:info];
}

- (void)fromDeviceGSMCallSet:(GLStateType)state homeId:(NSString *)homeId deviceId:(int32_t)deviceId {
    
    TopThkAckInfo *info = [TopThkAckInfo new];
    info.state = state;
    info.homeId = homeId;
    info.deviceId = deviceId;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fromDeviceGSMCallSet" object:info];
}


- (void)fromDeviceGSMInfoGet:(GLStateType)state homeId:(NSString *)homeId deviceId:(int32_t)deviceId info:(GLGSMModelInfo *)info {
    
    TopThkAckInfo *ackInfo = [TopThkAckInfo new];
    ackInfo.state = state;
    ackInfo.homeId = homeId;
    ackInfo.deviceId = deviceId;
    ackInfo.GSMModelInfo = info;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fromDeviceGSMInfoGet" object:ackInfo];
}


- (void)fromDeviceGSMModelSet:(GLStateType)state homeId:(NSString *)homeId deviceId:(int32_t)deviceId {
    
    TopThkAckInfo *info = [TopThkAckInfo new];
    info.state = state;
    info.homeId = homeId;
    info.deviceId = deviceId;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fromDeviceGSMModelSet" object:info];
}


- (void)fromDeviceGSMSmsSet:(GLStateType)state homeId:(NSString *)homeId deviceId:(int32_t)deviceId {
    
    TopThkAckInfo *info = [TopThkAckInfo new];
    info.state = state;
    info.homeId = homeId;
    info.deviceId = deviceId;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fromDeviceGSMSmsSet" object:info];
}

- (void)fromDeviceGSMLangSet:(GLStateType)state homeId:(NSString *)homeId deviceId:(int32_t)deviceId {
    TopThkAckInfo *info = [TopThkAckInfo new];
    info.state = state;
    info.homeId = homeId;
    info.deviceId = deviceId;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fromDeviceGSMLangSet" object:info];
}



@end
