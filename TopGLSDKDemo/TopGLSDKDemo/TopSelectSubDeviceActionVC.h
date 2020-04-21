//
//  TopSelectSubDeviceActionVC.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/4/1.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GeeklinkSDK/SDK.h>

NS_ASSUME_NONNULL_BEGIN
@protocol  TopSelectSubDeviceActionVCDelegate <NSObject>

@optional
- (void)selectSubDeviceActionVCSelectAction: (TopActionInfo *) actionInfo ;

@end
@interface TopSelectSubDeviceActionVC : UIViewController
@property (nonatomic, strong) TopMainDeviceInfo * mainDeviceInfo;
@property (nonatomic, weak) id<TopSelectSubDeviceActionVCDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
