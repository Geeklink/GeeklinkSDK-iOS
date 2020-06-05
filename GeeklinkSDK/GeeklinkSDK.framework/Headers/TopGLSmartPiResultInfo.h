//
//  TopResucltInfo.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/20.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Geeklink-Bridging-Header.h"
#import "TopSubDevInfo.h"
#import "TopACStateInfo.h"
#import "TopMainDevStateInfo.h"
#import "TopTimeInfo.h"
#import "GLStateType.h"
#import "GLActionFullType.h"
#import "GLSingleTimerActionType.h"
#import "GLKeyStudyType.h"
NS_ASSUME_NONNULL_BEGIN

@interface TopGLSmartPiResultInfo : NSObject
/**Request  result state
 返回错误类型*/
@property (nonatomic , assign) GLStateType state;
/**GLActionFullTypeInsert: insert (插入)
  GLActionFullTypeDelete: delete(删除)
  GLActionFullTypeUpdate: update(更新)
 GLActionFullTypeTest: test (测试)
*/
@property (nonatomic , assign) GLActionFullType action;

/** Add, delete and modify a  sub-device. keyIDList can be empty.
 增删改单个子设备设备，keyIDList可以不用传*/
@property (nonatomic , strong) TopSubDevInfo * subDevInfo;
/**Main devcie's md5
 主设备md5*/
@property (nonatomic , copy) NSString * md5;
/**Sub-device's ID
 控制和按键增删改时子设备的ID*/
@property (nonatomic , assign) NSInteger subId;
/** Add, delete, modify a custom button
 增删改某个自定义按键*/
@property (nonatomic , assign) NSInteger keyId;

/** sub-device list: [TopSubDevInfo]
 返回子设备列表[TopSubDevInfo]*/
@property (nonatomic , strong) NSArray * subDevList;



/**Simplified timing list
 简化的定时列表*/
@property (nonatomic , strong) NSArray * timerSimpleArray;

/**Timed operation
 GLSingleTimerActionTypeInsert, insert (插入)
 GLSingleTimerActionTypeDelete, delete (删除)
 GLSingleTimerActionTypeUpdate: update（更新）
 GLSingleTimerActionTypeSetOnOff： Set on or off(设置启动)
 定时操作*/
@property (nonatomic , assign) GLSingleTimerActionType singleTimerActionType;

/** Timing details
 定时详情回复*/
@property (nonatomic , strong) TopTimeInfo * timeInfo;


/*Code library brand list
 码库品牌列表*/
@property (nonatomic , strong) NSArray * dbrcBrandList;



/*Code library brand fileId list
 码库品牌fileId列表*/
@property (nonatomic , strong) NSArray * dbrcBrandFileIdList;
/** ir code
 获取到的irCode*/
@property (nonatomic , copy) NSString * irCode;


/**
 * GLKeyStudyTypeKeyStudyIr (Read infrared code)学习红外
 * GLKeyStudyTypeKeyStudyCance(Cancel  reading)l取消
 * 其他暂时不支持
 */
@property (nonatomic , assign) GLKeyStudyType studyType;


/**Key list:  [NSNumber] 
 keyList: [NSNumber]   NSNumber 对于对应码库类型的按键枚举*/
@property (nonatomic , strong)  NSArray * keyList;
@end

NS_ASSUME_NONNULL_END
