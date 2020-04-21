//
//  TopACCtrlInfo.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/18.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *power;false为关 true为开
 *mode;0自动/1制冷/2除湿/3送风/4制热
 *temp;16-30摄氏度
 *speed;码库空调风速0自动/1低/2中/3高
 *dir;0扫风/风向1/风向2/风向3/风向4
 */

NS_ASSUME_NONNULL_BEGIN

@interface TopACStateInfo : NSObject
@property (nonatomic, assign) BOOL powerState;
@property (nonatomic, assign) NSInteger mode;
@property (nonatomic, assign) NSInteger temperature;
@property (nonatomic, assign) NSInteger speed;
@property (nonatomic, assign) NSInteger dir;
@end

NS_ASSUME_NONNULL_END
