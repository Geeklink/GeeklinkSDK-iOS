//
//  TopGLDisinfectionLampAPIManager.h
//  GeeklinkCpp
//
//  Created by 杨飞飞 on 2020/5/15.
//  Copyright © 2020 列树童. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopGLDisinfectionLampResultInfo.h"
#import "GLActionType.h"
#import "GLActionFullType.h"
NS_ASSUME_NONNULL_BEGIN

@interface TopGLDisinfectionLampAPIManager : NSObject
/* 单例*/
+ (TopGLDisinfectionLampAPIManager *) shareManager;



/**Get disinfection  lamp state（获取设备最新状态）
 *md5: Host device's md5(主机的md5)
 *TopGLDisinfectionLampResultInfo ：
 *md5//Host device's md5(主机的md5);
 * state // Request result status( 请求结果状态)
 * TopMainDevStateInfo : (Device's status)设备状态信息
 */
- (void)getDisinfectionLampState:(NSString *)md5 complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;

/**Control disinfection  lamp.（控制消毒灯）
 *md5: Host device's md5(主机的md5)
 *disinfection_time: Duration of disinfection.  0 is off. (消毒时长, 0是关闭)
 *account: user account (用户账号)
 *TopGLDisinfectionLampResultInfo ：
 *md5//Host device's md5(主机的md5);
 * state // Request result status( 请求结果状态)
 */
- (void)controlDisinfectionLamp:(NSString *)md5 disinfection_time:(NSInteger) disinfection_time account:(NSString *)account complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;

/**Get disinfection  timer list（获取消毒定时列表）
 *md5: Host device's md5(主机的md5)
 *TopGLDisinfectionLampResultInfo ：
 *md5//Host device's md5(主机的md5);
 * state // Request result status( 请求结果状态)
 * disinfectionTimerList : [TopGLDisinfectionLampResultInfo];
 */
- (void)getDisinfectionLampTimerInfoList:(NSString *)md5 complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;


/**Insert/delete/update disinfection  timer（增删改消毒定时）
 *md5: Host device's md5(主机的md5)
 * GLActionFullType(操作类型)：  GLActionFullTypeInsert： Insert(插入)；GLActionFullTypeDelete:  Delete(删除) ；GLActionFullTypeUpdate: Update(更新)
 * disinfectionLampTimerInfo: Disinfection timer info. (消毒定时信息)
 *TopGLDisinfectionLampResultInfo ：
 *md5//Host device's md5(主机的md5);
 * state // Request result status( 请求结果状态)
 * GLActionFullType(操作类型)：  GLActionFullTypeInsert： Insert(插入)；GLActionFullTypeDelete:  Delete(删除) ；GLActionFullTypeUpdate: Update(更新)
 */
- (void)setDisinfectionLampTimerInfo:(NSString *)md5 actionFullType:(GLActionFullType)actionFullType disinfectionLampTimerInfo:(TopGLDisinfectionTimerInfo *)disinfectionLampTimerInfo complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;


/**Get or set disinfection lamp child lock（获取或修改消毒灯儿童锁）
 *md5: Host device's md5(主机的md5)
 *action: GLActionTypeCheck(Get 获取); GLActionTypeModify(Set 设置)
 *child_lock: It was used only when action was GLActionTypeModify. // 当action GLActionTypeModify(Set 设置)才有校。
 *md5//Host device's md5(主机的md5);
 *state // Request result status( 请求结果状态)
 *md5//Dvice's md5(主机的md5);
 *child_lock : Child lock status(儿童锁状态)
 *action: GLActionTypeCheck(Get 获取); GLActionTypeModify(Set 设置)
 */
- (void)disinfectionLampChildLock:(NSString *)md5 action:(GLActionType) action child_lock:(BOOL)child_lock  complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;

/**Get disinfection  records（获取所有子设备信息）
 *md5: Host device's md5(主机的md5)
 *TopGLDisinfectionLampResultInfo ：
 *md5//Host device's md5(主机的md5);
 * *state // Request result status( 请求结果状态)
 * *record_load_index: rescord index. value is 0 or 1. (获取记录的索引， 0或1)
 *disinfectionRecordList : [TopDisinfectionLampRecord];
 */
- (void)getDisinfectionLampRecords:(NSString *)md5 complete:(void(^)(TopGLDisinfectionLampResultInfo * resucltInfo))result;





@end

NS_ASSUME_NONNULL_END
