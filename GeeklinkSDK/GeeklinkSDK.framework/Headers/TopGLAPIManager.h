//
//  TopGLAPIManager.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/13.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopGLAPIResult.h"
#import "TopGLSmartPiResultInfo.h"
#import "TopACStateInfo.h"
#import "TopTimerSimpleInfo.h"
#import "TopActionInfo.h"
#import "TopDBRCBrand.h"
#import "TopDBRCBrandFileId.h"
#import "GLTimezoneAction.h"
NS_ASSUME_NONNULL_BEGIN


@protocol TopGLAPIManagerDelegate <NSObject>

@required
/* TopGLAPIResult （Return result 返回结果）
* TopGLAPIResult (Valid data 结果有效数据）:
*md5（Host device's md5 主机Md5）; subId(Device's subId 设备subID); stateValue(It is effective if it is AC 如果是空调则有效);（It is effective if it is host deivce如果是主设备则有效）
*/
- (void)deviceStateChange:(TopGLAPIResult *)resultInfo;

@end
@interface TopGLAPIManager : NSObject


/*  AppID and secret are required for initialization (初始化传入appID 和 secret)*/
+ (instancetype)initManagerWithAppId:(NSString *)appID andSecret: (NSString *)secret;
/* 单例*/
+ (TopGLAPIManager *) shareManager;
/* applicationWillEnterForeground 进入前台要打开*/
- (void)networkContinue;
/*applicationDidEnterBackground 进入后台要关闭*/
- (void)stopNetwork;


/**  Configure new device(配置新设备)
 * apBssid: Router  Wi-Fi' apBssid(路由器的Wi-Fi 的apBssid)
 * apSsid: Router  Wi-Fi' apSsid  (路由器的Wi-Fi apSsid)
 * password: Router  Wi-Fi' password (路由器的Wi-Fi password)
 * Not suitable for 5GWi-Fi(不支持5GWi-Fi)
 *return:
 * configerResult
 *
 *
 */
- (void)configerWifiWithApBssid:(NSString *) apBssid andApSsid:(NSString *) apSsid andPassword: (NSString *) password configerResult:(void(^)(TopGLAPIResult * configerDevResult))configerResult;

/**Stop configuration(停止配置)*/
- (void)stopConfigureWifi;


/**   Connect all added devices (连接所有已经添加的设备)
 * mainDeviceList = [TopMainDevice]
 */
- (void)linKAllMainDevice:(NSArray *) mainDeviceList;



/** Delete the host device ( 删除主设备)
 * md5:  Host device's md5(主机的md5)
 * TopGLSmartPiResultInfo:
 * state // Request result status( 请求结果状态)
 * md5 //Host device's md5(主机的md5)
 * 
 *  */
- (void)deleteMainDevice:(NSString *)md5  complete:(void(^)(TopGLAPIResult * resucltInfo))result;


/** Get device status (Currently only air conditioner and main device are valid) 获取设备状态 （目前只有空调和主设备有效）
 * md5:  Host device's md5(主机的md5)
 * TopResultInf:
 * state;// Request result status( 请求结果状态)
 * md5;Host device's md5(主机的md5)
 * ;mainDevStateInfo// Host device's state(主设状态)
 * stateValue//It is effective if it is AC 如果是空调则有效);
 */

- (void)getDeviceStateInfo:(NSString *)md5  complete:(void(^)(TopGLAPIResult * resucltInfo))result;

/** (Get or set time zone )时区设置/获取
 * md5:Host device's md5(主机的md5)
 * action: GLTimezoneActionTimezoneActionGet(Get 获取),GLTimezoneActionTimezoneActionSet（Set 设置）
 * timezone:     timezone * 60, When get it is 0.     (时区*60，获取的时候填0)
 * TopGLSmartPiResultInfo
 * state;
 * md5;
 * timezone。
 *  */
- (void)deviceTimezoneWithMd5:(NSString *)md5 action:(GLTimezoneAction)action timezone:(NSInteger)timezone complete:(void(^)(TopGLAPIResult * resucltInfo))result;

/** Upgrade device(升级设备)
 * md5:Host device's md5(主机的md5)
 * TopGLSmartPiResultInfo
 * state;
 * md5;
 * A successful reply indicates that the device is being upgraded, it takes about 1 minute, please do not power off.(回复成功代表设备正在升级，大概需要1分钟，请勿断电。)
 *  */
- (void)upgradeDeviceWithMd5:(NSString *)md5 complete:(void(^)(TopGLAPIResult * resucltInfo))result;


/*
 *delegate (代理)
 */

@property (nonatomic, weak) id<TopGLAPIManagerDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
