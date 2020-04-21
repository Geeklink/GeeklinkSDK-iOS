//
//  TopGLAPIManager.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/13.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopConfigerDevResult.h"
#import "TopResultInfo.h"
#import "TopACStateInfo.h"
#import "TopTimerSimpleInfo.h"
#import "TopActionInfo.h"
#import "TopDBRCBrand.h"
#import "TopDBRCBrandFileId.h"
#import "GLTimezoneAction.h"
NS_ASSUME_NONNULL_BEGIN


@protocol TopGLAPIManagerDelegate <NSObject>

@required
/* TopResultInfo 返回结果
* TopResultInfo结果有效数据md5; subId; stateValue(如果是空调则有效);mainDevStateInfo如果是主设备则有效
*/
- (void)deviceStateChange:(TopResultInfo *)resultInfo;

@end
@interface TopGLAPIManager : NSObject


/*初始化传入appID 和 secret*/
+ (instancetype)initManagerWithAppId:(NSString *)appID andSecret: (NSString *)secret;
/*单例*/
+ (TopGLAPIManager *) shareManager;
/*进入前台要打开*/
- (void)networkContinue;
/*进入后台要关闭*/
- (void)stopNetwork;


/**  配置新设备
 * apBssid: 路由器的Wi-FiapBssid
 * apSsid: 路由器的Wi-FiapSsid
 * password: 路由器的Wi-Fi password
 * 不支持5GWi-Fi
 *回复 configerResult
 *
 *
 */
- (void)configerWifiWithApBssid:(NSString *) apBssid andApSsid:(NSString *) apSsid andPassword: (NSString *) password configerResult:(void(^)(TopConfigerDevResult * configerDevResult))configerResult;

/**停止配置*/
- (void)stopConfigureWifi;


/**   链接所有已经添加的设备
 * mainDeviceList = [TopMainDevice]
 */
- (void)linKAllMainDevice:(NSArray *) mainDeviceList;



/**  删除主设备
 * md5: 主机的md5
 * TopResultInfo结果有效数据state;md5;
 * 
 *  */
- (void)deleteMainDevice:(NSString *)md5  complete:(void(^)(TopResultInfo * resucltInfo))result;

/**  获取所有子设备信息
 * md5: 主机的md5
 *TopResultInfo 返回结果
 *TopResultInfo结果有效数据 state; md5; subDevList : [TopSubDevInfo];
 */
- (void)getSubDeviceListWithMd5:(NSString *)md5 complete:(void(^)(TopResultInfo * resucltInfo))result;

/**  增删改子设备
 * md5: 主机的md5
 * action: GLActionFullTypeInsert(增), GLActionFullTypeDelete（删）, GLActionFullTypeUpdate（改）
 * subDevInfo:子设备Info 添加的时候subId填0，自定义设备fileId填0
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;md5; subDevInfo;action
 *
 */
- (void)setSubDeviceWithMd5:(NSString *)md5 subDevInfo:(TopSubDevInfo *)subDevInfo action:(GLActionFullType)action complete:(void(^)(TopResultInfo * resucltInfo))result;
/**  增删改自定义设备的按键
 * md5: 主机的md5
 * action: GLActionFullTypeInsert(增), GLActionFullTypeDelete（删）, GLActionFullTypeUpdate（改：重新录码）
 * 增加的时候keyId填0，
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;md5; keyId;action
 */
- (void)setSubDeviceKeyWithMd5:(NSString *)md5 action:(GLActionFullType)action  subDeviceId: (NSInteger)subDeviceId keyId: (NSInteger)keyId complete:(void(^)(TopResultInfo * resucltInfo))result;

/**  取消按键更新或者添加操作
 * md5: 主机的md5
 * TopResultInfo结果有效数据state;md5;
 */
- (void)cancelSetKeyWithMd5:(NSString *)md5 complete:(void(^)(TopResultInfo * resucltInfo))result;

/**  控制子设备
 * md5: 主机的md5
 *subDevInfo：子设备信息
 *acStateInfo: 如果是空调则要传入空调的状态,如果不是空调可以填空
 *keyId：如果是自定义设备，填对应的keyID,如果是马库设备填按键类型
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;md5;
 */
- (void)controlSubDeviceKeyWithMd5:(NSString *)md5 subDevInfo:(TopSubDevInfo *)subDevInfo acStateInfo:(TopACStateInfo * __nullable)acStateInfo keyId: (NSInteger)keyId complete:(void(^)(TopResultInfo * resucltInfo))result;

/**  获取设备状态 （目前只有空调和主设备有效）
 * md5: 主机的md5
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;md5;;mainDevStateInfo主设状态
*/
- (void)getDeviceStateInfo:(NSString *)md5  complete:(void(^)(TopResultInfo * resucltInfo))result;
/**  获取简化的定时时间列表
 * md5: 主机的md5
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;md5; timerSimpleArray:[TopTimerSimpleInfo]
 */
- (void)getActionTimerListWithMd5:(NSString *)md5 complete:(void(^)(TopResultInfo * resucltInfo))result;

/**  修改简单的定时信息
 * md5: 主机的md5
 * action: 用于定时执行动作的修改
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;action;
 */
 - (void)setActionSmartPiTimerSimpleWithMd5:(NSString *)md5 action:(GLSingleTimerActionType)action timeSinpleInfo:(TopTimerSimpleInfo *)timeSinpleInfo complete:(void(^)(TopResultInfo * resucltInfo))result;


/**  获取某个定时的详细情况
 * md5: 主机的md5
 *timeId对应的定时id
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;md5 timeInfo;
 */
- (void)getTimeInfoDetailWithMd5:(NSString *)md5  timeId:(NSInteger)timeId complete:(void(^)(TopResultInfo * resucltInfo))result;

/**  插入或者修改定时信息
 * md5: 主机的md5
 * action: GLSingleTimerActionType 用于定时所用信息的修改或者插入新定时
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;action;
 */
- (void)setActionTimerInfoWithMd5:(NSString *)md5 action:(GLSingleTimerActionType)action  timeInfo:(TopTimeInfo *)timeInfo complete:(void(^)(TopResultInfo * resucltInfo))result;






/**  获取某个定时的详细情况
 * md5: 主机的md5
 * studyType目前只支持GLKeyStudyTypeKeyStudyIr（红外码）和GLKeyStudyTypeKeyStudyCancel（取消获取）
 * TopResultInfo结果有效数据state;md5 ,irCode,studyType ;
 * 
 * */
- (void)getCodeFromDeviceWithMd5:(NSString *)md5 andCodeType:(GLKeyStudyType)type  complete:(void(^)(TopResultInfo * resucltInfo))result;

/**  直接让主机发学习到的红外码控制设备
 * md5: 主机的md5
 *code:字符串型红外码
 * TopResultInfo结果有效数据state;md5;
 */
- (void)controlSubDeviceWithMd5:(NSString *)md5 andIrCode:(NSString *)code complete:(void(^)(TopResultInfo * resucltInfo))result;

/**  用于获取码库品牌列表
 * md5: 主机的md5
 * databaseType:  码库类型
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;dbrcBrandList： [TopDBRCBrand]有效
 */

- (void)getDBRCBrandWithMd5:(NSString *)md5 databaseType:(TopDataBaseDeviceType)databaseType complete:(void(^)(TopResultInfo * resucltInfo))result;



/**  获取品牌对应的fileId列表
 * md5: 主机的md5
 * databaseType:  码库类型
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;dbrcBrandList： [TopDBRCBrandFileId]有效
 */
- (void)getDBRCBrandFlieIdWithMd5:(NSString *)md5 databaseType:(TopDataBaseDeviceType)databaseType andBrand:(TopDBRCBrand *)brand complete:(void(^)(TopResultInfo * resucltInfo))result;

/**  获取 码库设备所有按键
 * md5: 主机的md5
 * databaseType:  码库类型
 * fildId: 马库设备的fildIdID
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;md5; keyList
 */
- (void)getDBKeyListWithMd5:(NSString *)md5 databaseType:(TopDataBaseDeviceType)databaseType fildId:(NSInteger)fildId complete:(void(^)(TopResultInfo * resucltInfo))result ;

/**  用于简单测试是否能正确控制对应的品牌设备
 * md5: 主机的md5
 *acStateInfo: 如果是空调则要传入空调的状态,否则填空
 *keyId：填对应的码库设备填按键类型
 *fildId ：马库设备的fildIdID
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;md5; keyId;action
 */


- (void)testDataBaseDeviceWithMd5:(NSString *)md5 databaseType:(TopDataBaseDeviceType) databaseType fildId:(NSInteger)fildId  acStateInfo:(TopACStateInfo * __nullable)acStateInfo keyId: (NSInteger)keyId complete:(void(^)(TopResultInfo * resucltInfo))result;


/** 时区设置/获取
 * md5: 主机的md5
 * action: GLTimezoneActionTimezoneActionGet(获取),GLTimezoneActionTimezoneActionSet（设置）
 * timezone = 时区*60，获取的时候填0
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;md5;timezone。
 *  */
- (void)deviceTimezoneWithMd5:(NSString *)md5 action:(GLTimezoneAction)action timezone:(NSInteger)timezone complete:(void(^)(TopResultInfo * resucltInfo))result;

/** 升级设备
 * md5: 主机的md5
 * TopResultInfo 返回结果
 * TopResultInfo结果有效数据state;md5; 回复成功代表设备正在升级，大概需要1分钟，请勿断电。
 *  */
- (void)upgradeDeviceWithMd5:(NSString *)md5 complete:(void(^)(TopResultInfo * resucltInfo))result;


/*
 *代理
 */

@property (nonatomic, weak) id<TopGLAPIManagerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
