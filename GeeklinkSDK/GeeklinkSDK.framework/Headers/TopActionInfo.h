//
//  TopActionInfo.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/23.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopSubDevInfo.h"
#import "TopACStateInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface TopActionInfo : NSObject

/*动作延迟时间，后免的动作在这个动作执行后才能执行， 秒为单位， 取值范围为0 - 1800s*/
@property (nonatomic , assign) NSInteger delay;


/*如果是空调则为空调状态值， 否则为字符串类型的KeyID*/
@property (nonatomic , copy) NSString * value;

/*按键的keyId,如果是码库空调传入*/
@property (nonatomic , strong) TopACStateInfo * acStateInfo;


/*子设备ID，获取详情的时候有效*/
@property (nonatomic , assign) NSInteger subID;

- (NSString *)getACValueWithACState:(TopACStateInfo *) acStateInfo;
- (TopACStateInfo *)getACStateWithValue:( NSString *) value;


- (NSInteger)getKeyIndWithValue:(NSString *) value;
- (NSString *)getValueWithKeyId:(NSInteger) keyId;


@end

NS_ASSUME_NONNULL_END
