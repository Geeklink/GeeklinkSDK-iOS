//
//  TopGLDisinfectionLampResultInfo.h
//  project_lib
//
//  Created by 杨飞飞 on 2020/5/18.
//  Copyright © 2020 列树童. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopGLDisinfectionLampRecord.h"
#import "TopMainDevStateInfo.h"
#import "TopGLDisinfectionTimerInfo.h"
#import "GLStateType.h"
#import "GLActionType.h"
#import "GLActionFullType.h"
NS_ASSUME_NONNULL_BEGIN

@interface TopGLDisinfectionLampResultInfo : NSObject
/**Result state
 返回错误类型*/
@property (nonatomic , assign) GLStateType state;

/** GLActionTypeCheck: Get (获取)
 GLActionTypeModify: Modify (修改)
 */
@property (nonatomic , assign) GLActionType actionType;
/** Child lock status.(童锁状态)
 */
@property (nonatomic , assign) BOOL child_lock;
/** Action type： 操作类型
 GLActionFullTypeInsert： Insert(插入)
GLActionFullTypeDelete:  Delete(删除)
GLActionFullTypeUpdate: Update(更新)
 */
@property (nonatomic , assign) GLActionFullType actionFullType;
/**Device md5
 设备md5*/
@property (nonatomic , copy) NSString * md5;

/**Device State
 消毒灯设备状态*/
@property (nonatomic , strong) TopMainDevStateInfo * mainDevStateInfo;
/*Timer list
 定时列表 */
@property (nonatomic, strong) NSArray<TopGLDisinfectionTimerInfo *> * disinfectionTimerList;

/*Record list
 记录列表 */
@property (nonatomic, strong) NSArray<TopGLDisinfectionLampRecord *> * disinfectionRecordList;
@end

NS_ASSUME_NONNULL_END
