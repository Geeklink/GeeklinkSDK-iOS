//
//  TopDBRCBrandFileIdListVC.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/27.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GeeklinkSDK/SDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface TopDBRCBrandFileIdListVC : UIViewController
@property (nonatomic, strong) TopMainDeviceInfo * mainDeviceInfo;
@property (nonatomic, assign) TopDBRCBrand * brand;
@property (nonatomic, assign) TopDataBaseDeviceType dataBaseDeviceType;

@end

NS_ASSUME_NONNULL_END
