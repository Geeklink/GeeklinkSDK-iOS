//
//  TopDBRCBrandTypeVC.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/27.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GeeklinkSDK/SDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface TopDBRCBrandListVC : UIViewController
@property (nonatomic, strong) TopMainDeviceInfo * mainDeviceInfo;
@property (nonatomic, assign) GLDatabaseDevType dataBaseDeviceType;
@end

NS_ASSUME_NONNULL_END
