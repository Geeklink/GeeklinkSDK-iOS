//
//  TopMainDevStateInfo.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/23.
//  Copyright © 2020 Geeklink. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TopDisinfectionStateType) {
    TopDisinfectionStateTypeON,
    TopDisinfectionStateTypeOFF,
    TopDisinfectionStateTypePAUSE,
};

//#import "Geeklink-Bridging-Header.h"
#import "GLDevConnectState.h"

NS_ASSUME_NONNULL_BEGIN
/*Host device‘s state 主设备状态*/
@interface TopMainDevStateInfo : NSObject
/* Connect state  设备在线状态*/
@property (nonatomic, assign) GLDevConnectState state;
/*If is LAN status  （ip局域网状态下才有的）*/
@property (nonatomic, copy) NSString *ip;
/*Device‘s mac （设备mac）*/
@property (nonatomic, copy) NSString *mac;
/*The current version of the device （设备当前版本）*/
@property (nonatomic, copy) NSString *curVer;
/*The latest version of the device （设备最新版本）*/
@property (nonatomic, copy) NSString *latestVer;

/*Disinfection lamp status （消毒灯状态）*/
@property (nonatomic, assign) TopDisinfectionStateType disinfection_state;
/*Disinfection current time （当前消毒时间）*/
@property (nonatomic, assign) int32_t disinfection_cur_dur;
/*Disinfection total time （消毒总时间）*/
@property (nonatomic, assign) int32_t disinfection_all_dur;
/*Time stamp of last disinfection （上次消毒的时间戳）*/
@property (nonatomic, assign) int32_t disinfection_last_time;




@end

NS_ASSUME_NONNULL_END
