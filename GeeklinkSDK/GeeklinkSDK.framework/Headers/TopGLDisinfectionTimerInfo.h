//
//  TopGLDisinfectionTimerInfo.h
//  GeeklinkSDK
//
//  Created by 杨飞飞 on 2020/5/18.
//  Copyright © 2020 列树童. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopGLDisinfectionTimerInfo : NSObject
/**timer id (定时的ID) */
@property (nonatomic, assign) int32_t timerId;

/**Timer name: Up to 24 characters (消毒定时名称：最多24个字节) */
@property (nonatomic, strong) NSString * name;

/**on or off (定时是否启动) */
@property (nonatomic, assign) BOOL onOff;

/* repeat: 0 is once, 31 = 0x1e = 00011110 (Tuesday Wednesday Thursday Friday)
 重复: 0为一次，31 = 0x1e = 00011110（ 二三四五  ）*/
@property (nonatomic, assign) int32_t week;

/** Time to start disinfection. Minute.
 开始消毒时间，以分为单位 */
@property (nonatomic, assign) int32_t startTime;

/**Disinfection time. Minute.
 消毒时长，以分为单位 */
@property (nonatomic, assign) int32_t disinfectionTime;
@end

NS_ASSUME_NONNULL_END
