//
//  MozTopAlertView.h
//  MoeLove
//
//  Created by LuLucius on 14/12/7.
//  Copyright (c) 2014年 MOZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger
{
    TopAlertTypeError,
    TopAlertTypeTip
} TopAlertType;

@interface TopAlertView : UIView
{
    @private
    UIImageView *leftIcon;
}

@property(nonatomic, assign)BOOL autoHide;
@property(nonatomic, assign)NSInteger duration;


/*
 * btn target
 */
@property (nonatomic, copy) dispatch_block_t doBlock;

@property (nonatomic, copy) dispatch_block_t nextTopAlertBlock;

/*
 * action after dismiss
 */
@property (nonatomic, copy) dispatch_block_t dismissBlock;


+ (TopAlertView*)showWithType:(TopAlertType)type text:(NSString*)text parentView:(UIView*)parentView;

@end
