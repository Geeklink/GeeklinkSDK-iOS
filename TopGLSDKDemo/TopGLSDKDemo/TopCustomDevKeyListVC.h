//
//  TopCustomDevKeyListVC.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/30.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GeeklinkSDK/SDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface TopCustomDevKeyListVC : UIViewController
@property (nonatomic, strong) TopMainDeviceInfo * mainDeviceInfo;
/**如果控制子设备则传入*/
@property (strong, nonatomic) TopSubDevInfo * subDevInfo;

/**如果控制子设备则传入*/
@property (strong, nonatomic) NSMutableArray * keyIdList;

@end

NS_ASSUME_NONNULL_END
