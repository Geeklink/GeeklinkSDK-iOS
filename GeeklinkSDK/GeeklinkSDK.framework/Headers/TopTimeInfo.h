//
//  TopTimeInfo.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/23.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopTimeInfo : NSObject

/*定时ID*/
@property (nonatomic , assign) NSInteger timerId;
/*定时名称*/
@property (nonatomic , copy) NSString * name;
/*定时启动时间，以分为单位0 - 1399*/
@property (nonatomic , assign) NSInteger time;
/*重复0x00-0x7f ，0为一次，31 = 0x1e = 00011110（ 二三四五  ）*/
@property (nonatomic , assign) NSInteger week;
/*启动和关闭*/
@property (nonatomic , assign) BOOL onOff;

/*动作列表*/
@property (nonatomic , strong) NSArray * actionInfoList;

@end

NS_ASSUME_NONNULL_END
