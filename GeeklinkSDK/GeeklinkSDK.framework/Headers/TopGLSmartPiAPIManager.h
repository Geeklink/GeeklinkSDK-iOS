//
//  TopGLSmartPiAPIManager.h
//  GeeklinkCpp
//
//  Created by 杨飞飞 on 2020/5/15.
//  Copyright © 2020 列树童. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopGLSmartPiResultInfo.h"
#import "TopACStateInfo.h"
#import "TopTimerSimpleInfo.h"
#import "TopActionInfo.h"
#import "TopDBRCBrand.h"
#import "TopDBRCBrandFileId.h"
#import "GLTimezoneAction.h"
NS_ASSUME_NONNULL_BEGIN


@interface TopGLSmartPiAPIManager : NSObject

/* 单例*/
+ (TopGLSmartPiAPIManager *) shareManager;

/**Get all sub-device information（获取所有子设备信息）
 *md5: Host device's md5(主机的md5)
 *TopGLSmartPiResultInfo ：
 *state // Request result status( 请求结果状态)
 *md5//Host device's md5(主机的md5);
 *subDevList : [TopSubDevInfo];  //Sub-device list( 子设备列表)
 */
- (void)getSubDeviceListWithMd5:(NSString *)md5 complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;

/** Add, delete, modify sub-devices (增删改子设备)
 * md5: Host device's md5(主机的md5)
 * action: GLActionFullTypeInsert(add 增), GLActionFullTypeDelete（delete 删）, GLActionFullTypeUpdate（modify 改）
 * subDevInfo:  Sub_device infomatiom.  When adding the subId is 0.  Custom sub_device's fileId is 0.(子设备Info 添加的时候subId填0，自定义设备fileId填0)
 * TopGLSmartPiResultInfo:
 * state;// Request result status( 请求结果状态)
 * md5;//Host device's md5(主机的md5);
 *  subDevInfo;//Sub_device infomatiom  (子设备信息)
 *  action: GLActionFullTypeInsert(add 增), GLActionFullTypeDelete（delete 删）, GLActionFullTypeUpdate（modify 改）
 *
 */
- (void)setSubDeviceWithMd5:(NSString *)md5 subDevInfo:(TopSubDevInfo *)subDevInfo action:(GLActionFullType)action complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;
/** Add, delete, and change the keys of a custom device (增删改自定义设备的按键)
 * md5:  Host device's md5(主机的md5)
 * action: GLActionFullTypeInsert(add 增), GLActionFullTypeDelete（delete 删）, GLActionFullTypeUpdate（modify 改：重新录码）
 * keyId:   When adding the subId is 0 (增加的时候keyId填0)
 * TopGLSmartPiResultInfo:
 * state;;// Request result status( 请求结果状态)
 * md5;Host device's md5(主机的md5)
 * keyId//Key's id (按键的ID)
 * action//GLActionFullTypeInsert(add 增), GLActionFullTypeDelete（delete 删）, GLActionFullTypeUpdate（modify 改：重新录码）
 */
- (void)setSubDeviceKeyWithMd5:(NSString *)md5 action:(GLActionFullType)action  subDeviceId: (NSInteger)subDeviceId keyId: (NSInteger)keyId complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;

/**  Cancel  custom device's keys update or add operation(取消按键更新或者添加操作)
 * md5:  Host device's md5(主机的md5)
 * TopGLSmartPiResultInfo:
 * state;// Request result status( 请求结果状态)
 * md5;Host device's md5(主机的md5)
 */
- (void)cancelSetKeyWithMd5:(NSString *)md5 complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;

/** Control sub-device (控制子设备)
 * md5: Host device's md5(主机的md5)
 *subDevInfo：Sub device's infomation(子设备信息)
 *acStateInfo: If is AC (如果是空调则要传入空调的状态,如果不是空调可以填空)
 *keyId：Custom device key's Id or database device key type(如果是自定义设备，填对应的keyID,如果是马库设备填按键类型)
 * TopGLSmartPiResultInfo:
 * state; // Request result status( 请求结果状态)
 * md5://Host device's md5(主机的md5)
 */
- (void)controlSubDeviceKeyWithMd5:(NSString *)md5 subDevInfo:(TopSubDevInfo *)subDevInfo acStateInfo:(TopACStateInfo * __nullable)acStateInfo keyId: (NSInteger)keyId complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;


/**  Get a simplified timing list (获取简化的定时列表)
 * md5: Host device's md5(主机的md5)
 * TopGLSmartPiResultInfo
 * state;//Request result status( 请求结果状态)
 * md5;//Host device's state(主设状态)
 * timerSimpleArray:[TopTimerSimpleInfo]
 */

- (void)getActionTimerListWithMd5:(NSString *)md5 complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;

/** Modify simple timing information( 修改简单的定时信息)
 * md5: Host device's md5(主机的md5)
 * action:    GLSingleTimerActionTypeDelete(Delete 删除),    GLSingleTimerActionTypeSetOnOff (Set Run 设置开关)
 * TopGLSmartPiResultInfo
 * TopGLSmartPiResultInfo
 * state;//Request result status( 请求结果状态)
 * action;// GLSingleTimerActionTypeDelete(Delete 删除),    GLSingleTimerActionTypeSetOnOff (Set Run 设置开关)
 */
- (void)setActionSmartPiTimerSimpleWithMd5:(NSString *)md5 action:(GLSingleTimerActionType)action timeSinpleInfo:(TopTimerSimpleInfo *)timeSinpleInfo complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;


/**  Get the details of a  timing (获取某个定时的详细情况)
 * md5: Host device's md5(主机的md5)
 * timeId:  timing's Id 对应的定时id
 * TopGLSmartPiResultInfo:
 * state\\Request result status( 请求结果状态)
 * md5\\ Host device's md5(主机的md5)
 * timeInfo;
 */
- (void)getTimeInfoDetailWithMd5:(NSString *)md5  timeId:(NSInteger)timeId complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;

/**  Insert or modify timing information(插入或者修改定时信息)
 * md5:Host device's md5(主机的md5)
 * action: GLSingleTimerActionType : GLSingleTimerActionTypeInsert(add 插入) GLSingleTimerActionTypeUpdate(Modify 更新)  ,GLSingleTimerActionTypeDelete(Delete 删除)
 * TopGLSmartPiResultInfo
 * state;
 * action; GLSingleTimerActionTypeInsert(add 插入) GLSingleTimerActionTypeUpdate(Modify 更新)  ,GLSingleTimerActionTypeDelete(Delete 删除)
 */
- (void)setActionTimerInfoWithMd5:(NSString *)md5 action:(GLSingleTimerActionType)action  timeInfo:(TopTimeInfo *)timeInfo complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;


/** Get infrared code (读取红外码)
 * md5:Host device's md5(主机的md5)
 * studyType: GLKeyStudyTypeKeyStudyIr（infrared code  红外码）GLKeyStudyTypeKeyStudyCancel（Cancel get 取消获取）
 * TopGLSmartPiResultInfo
 * state;
 * md5 ,
 * irCode,// infrared code  红外码
 * studyType ;  GLKeyStudyTypeKeyStudyIr（infrared code  红外码）GLKeyStudyTypeKeyStudyCancel（Cancel get 取消获取）
 *
 * */
- (void)getCodeFromDeviceWithMd5:(NSString *)md5 andCodeType:(GLKeyStudyType)type  complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;

/** Send infrared code  (直接让主机发学习到的红外码控制设备)
 * md5:Host device's md5(主机的md5)
 *code: Infrared code 红外码
 * TopGLSmartPiResultInfo:
 * state;
 * md5;
 */
- (void)controlSubDeviceWithMd5:(NSString *)md5 andIrCode:(NSString *)code complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;

/** Get the code library brand list (用于获取码库品牌列表)
 * md5:Host device's md5(主机的md5)
 * databaseType:  Database's Type(码库类型)
 * TopGLSmartPiResultInfo
 * state;
 * dbrcBrandList：[TopDBRCBrand]
 *
 */

- (void)getDBRCBrandWithMd5:(NSString *)md5 databaseType:(GLDatabaseDevType)databaseType complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;



/**Get the fileId list of the brand  (获取品牌对应的fileId列表)
 * md5:Host device's md5(主机的md5)
 * databaseType:  Database's Type(码库类型)
 * TopGLSmartPiResultInfo
 * state;
 * dbrcBrandList： [TopDBRCBrandFileId]
 */
- (void)getDBRCBrandFlieIdWithMd5:(NSString *)md5 databaseType:(GLDatabaseDevType)databaseType andBrand:(TopDBRCBrand *)brand complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;

/**  Get all key types of database device (获取码库设备所有按键类型)
 * md5:Host device's md5(主机的md5)
 * databaseType:  Database's Type(码库类型)
 * fildId:  Database device's fildId 马库设备的fildIdID
 * TopGLSmartPiResultInfo
 * state;
 * md5;
 * keyList
 */
- (void)getDBKeyListWithMd5:(NSString *)md5 databaseType:(GLDatabaseDevType)databaseType fildId:(NSInteger)fildId complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result ;

/**  Test if the brand matches.  用于简单测试是否能正确控制对应的品牌设备
 * md5:Host device's md5(主机的md5)
 *acStateInfo: If is AC (如果是空调则要传入空调的状态,否则填空)
 *keyId：database device's key Type (填对应的码库设备填按键类型)
 *fildId ： Database brand's fildIdID 马库设备的fildIdID
 * TopGLSmartPiResultInfo
 * state;
 * md5;
 * keyId;
 * action
 */


- (void)testDataBaseDeviceWithMd5:(NSString *)md5 databaseType:(GLDatabaseDevType) databaseType fildId:(NSInteger)fildId  acStateInfo:(TopACStateInfo * __nullable)acStateInfo keyId: (NSInteger)keyId complete:(void(^)(TopGLSmartPiResultInfo * resucltInfo))result;




@end

NS_ASSUME_NONNULL_END
