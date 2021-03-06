//
//  TopGLAPIResult.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/13.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Geeklink-Bridging-Header.h"
#import "GLGeeklinkDevType.h"
#import "GLDeviceMainType.h"
#import "GLStateType.h"
#import "TopMainDevStateInfo.h"
/**
 *回复状态类型 state
 *
 * GLStateTypeOk,
 GLStateTypeFailed,
 GLStateTypeSessionError,
 GLStateTypeTokenError,
 GLStateTypeSignError,
 GLStateTypeFullError,
 GLStateTypeTimeoutError,
 GLStateTypeRepeatError,
 GLStateTypeRunningError,
 GLStateTypeInternetError,
 GLStateTypeCustomError,
 GLStateTypeMd5Error,
 GLStateTypeNoConnectError,
 GLStateTypeNoKeyError,
 GLStateTypeFileIdError,
 GLStateTypeCount,
 *ok 成功
 *failed 失败
 *session_error 1.服务器验证失败，出现时需要重新登录，2.设备验证失败，出现时是中间层问题，不用特殊提示
 *token_error 设备的token不对
 *full_error 数量已满，场景，动作，条件，分机，按键等会出现
 *repeat_error 重复添加，重复的分机，或者重复的315安防设备信号
 *running_error 当前正在执行，在启动场景会出现
 *internet_error 设备没有网络，在控制码库设备时会出现（码库设备的码时服务器返回的，所以需要外网）
 *custom_error 定制设备出现了定制功能异常，主要是给浙江电信用
 *md5_error md5错误
 *no_connect_error 未链接主机
 *no_key_error 没有该按键
 *no_key_error fileId错误
 */
NS_ASSUME_NONNULL_BEGIN

@interface TopGLAPIResult : NSObject
@property (nonatomic , assign) GLStateType state;
@property (nonatomic , assign) GLDeviceMainType mainType;
@property (nonatomic , assign) GLGeeklinkDevType geeklinkDevType;
@property (nonatomic , copy) NSString * token;
@property (nonatomic , copy) NSString * md5;

/**Get the status of the host device and the status of the host device changes.
 获取主机设备状态和主机设备状态改变的时候有效*/
@property (nonatomic , strong) TopMainDevStateInfo * mainDevStateInfo;

/**Sub-device's ID
子设备ID*/
@property (nonatomic , assign) NSInteger subId;

/* state Value
 状态value， 在TopSubDevInfo根据对应的类型解析*/
@property (nonatomic , strong) NSString * stateValue;

/** timezone
 时区x60*/
@property (nonatomic , assign) NSInteger timezone;



@end

NS_ASSUME_NONNULL_END
