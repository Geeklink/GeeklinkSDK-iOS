//
//  CHLoadingView.h
//  JdPlayOpenSDKWithUI
//
//  Created by 沐阳 on 16/11/15.
//  Copyright © 2016年 沐阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLoadingView : UIView

@property (nonatomic,strong) UIActivityIndicatorView * activity;

@property (nonatomic,strong) UILabel * textL;
/** 背部的遮盖 */
@property (nonatomic, strong) UIView * maxCover;


+ (CHLoadingView *)showWithView:(UIView *)view;
+ (CHLoadingView *)showWithView:(UIView*)view withTip:(NSString *)tip;

- (void)dismiss;

@end
