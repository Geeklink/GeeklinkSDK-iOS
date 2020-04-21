//
//  TopMainDevStateInfo.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/23.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Geeklink-Bridging-Header.h"
#import "GLDevConnectState.h"

NS_ASSUME_NONNULL_BEGIN
/*主设备状态*/
@interface TopMainDevStateInfo : NSObject
/*设备在线状态*/
@property (nonatomic, assign) GLDevConnectState state;
/*ip局域网状态下才有的*/
@property (nonatomic, copy) NSString *ip;
/*设备mac*/
@property (nonatomic, copy) NSString *mac;
/*设备当前版本*/
@property (nonatomic, copy) NSString *curVer;
/*设备最新版本*/
@property (nonatomic, copy) NSString *latestVer;

@end

NS_ASSUME_NONNULL_END
