//
//  TopTimerSimpleInfo.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/24.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**简单的定时信息用于简单的列表显示和修改定时启动开关*/
@interface TopTimerSimpleInfo : NSObject
/*定时ID*/
@property (nonatomic , assign) NSInteger timerId;
/*定时名称*/
@property (nonatomic , copy) NSString * name;
/*定时启动时间，以秒为单位*/
@property (nonatomic , assign) NSInteger time;
/*重复，0为一次，31 = 0x1e = 00011110（ 二三四五  ）*/
@property (nonatomic , assign) NSInteger week;
/*启动和关闭*/
@property (nonatomic , assign) BOOL onOff;

@end

NS_ASSUME_NONNULL_END
