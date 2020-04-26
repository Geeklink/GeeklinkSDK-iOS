//
//  TopRoomAddFBTipViewVC.h
//  Top
//
//  Created by Lieshutong on 15/9/15.
//  Copyright (c) 2015年 GeekLink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopRoomAddFBTipViewVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleTipLbl;
@property (weak, nonatomic) IBOutlet UILabel *midTipLbl;
@property (weak, nonatomic) IBOutlet UILabel *bottomTipLbl;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
- (IBAction)clickCancelBtn:(id)sender;
- (IBAction)cilckSureBtn:(id)sender;

@end
