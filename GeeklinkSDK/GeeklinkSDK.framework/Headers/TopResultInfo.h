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

@interface TopResultInfo : NSObject
/**返回错误类型*/
@property (nonatomic , assign) GLStateType state;
/**增删改*/
@property (nonatomic , assign) GLActionFullType action;

/** 增删改单个子设备设备，keyIDList可以不用传*/
@property (nonatomic , strong) TopSubDevInfo * subDevInfo;
/** 主设备md5*/
@property (nonatomic , copy) NSString * md5;
/** 控制和按键增删改时子设备的ID*/
@property (nonatomic , assign) NSInteger subId;
/** 增删改某个自定义按键*/
@property (nonatomic , assign) NSInteger keyId;

/**返回子设备列表[TopSubDevInfo]*/
@property (nonatomic , strong) NSArray * subDevList;
/**状态value， 在TopSubDevInfo根据对应的类型解析*/
@property (nonatomic , strong) NSString * stateValue;
/**获取主机设备状态和主机设备状态改变的时候有效*/
@property (nonatomic , strong) TopMainDevStateInfo * mainDevStateInfo;

/**简化的定时列表*/
@property (nonatomic , strong) NSArray * timerSimpleArray;

/**定时操作*/
@property (nonatomic , assign) GLSingleTimerActionType singleTimerActionType;

/**定时详情回复*/
@property (nonatomic , strong) TopTimeInfo * timeInfo;


/*码库品牌列表*/
@property (nonatomic , strong) NSArray * dbrcBrandList;



/*码库品牌fileId列表*/
@property (nonatomic , strong) NSArray * dbrcBrandFileIdList;
/** 获取到的irCode*/
@property (nonatomic , copy) NSString * irCode;
/** 获取到的irCode*/

/**
 * GLKeyStudyTypeKeyStudyIr学习红外
 * GLKeyStudyTypeKeyStudyCancel取消
 * 其他暂时不支持
 */
@property (nonatomic , assign) GLKeyStudyType studyType;
/**时区x60*/
@property (nonatomic , assign) NSInteger timezone;


/**keyList: [NSNumber]   NSNumber 对于对应码库类型的按键枚举*/
@property (nonatomic , strong)  NSArray * keyList;
@end

NS_ASSUME_NONNULL_END
