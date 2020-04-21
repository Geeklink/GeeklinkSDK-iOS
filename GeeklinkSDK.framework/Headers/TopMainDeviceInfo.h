//
//  TopMainDeviceInfo.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/20.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopDeviceType.h"
NS_ASSUME_NONNULL_BEGIN


@interface TopMainDeviceInfo : NSObject
@property (nonatomic , assign) TopDeviceMainType mainType;
@property (nonatomic , assign) TopNetworkDeviceType subType;
@property (nonatomic , copy) NSString * token;
@property (nonatomic , copy) NSString * md5;
@end

NS_ASSUME_NONNULL_END
