//
//  MozTopAlertView.m
//  MoeLove
//
//  Created by LuLucius on 14/12/7.
//  Copyright (c) 2014年 MOZ. All rights reserved.
//

#import "TopAlertView.h"

#define MOZ_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;

#define hsb(h,s,b) [UIColor colorWithHue:h/360.0f saturation:s/100.0f brightness:b/100.0f alpha:1.0]

@implementation TopAlertView

- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (TopAlertView*)showWithType:(TopAlertType)type text:(NSString*)text parentView:(UIView*)parentView{
    TopAlertView *alertView = [[TopAlertView alloc]initWithType:type text:text doText:nil];
    [parentView addSubview:alertView];
    [alertView show];
    return alertView;
}


- (instancetype)initWithType:(TopAlertType)type text:(NSString*)text doText:(NSString*)doText
{
    self = [super init];
    if (self) {
        [self setType:type text:text doText:doText];
    }
    return self;
}

- (void)setType:(TopAlertType)type text:(NSString*)text{
    [self setType:type text:text doText:nil];
}

- (void)setType:(TopAlertType)type text:(NSString*)text doText:(NSString*)doText{
    _autoHide = YES;
    _duration = 2;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    [self setFrame:CGRectMake(0, -40, width, 40)];
    
    leftIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 24,24 )];
    leftIcon.backgroundColor = [UIColor clearColor];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(44 , 10, width*0.8, 20)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = [UIFont systemFontOfSize:16];
    textLabel.text = text;
    UISwipeGestureRecognizer* recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(touchTop:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:recognizer];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 2;
    switch (type) {
        case TopAlertTypeTip:
        {
            self.backgroundColor = [UIColor whiteColor];
            [textLabel setTextColor:[UIColor blackColor]];
            leftIcon.image = [UIImage imageNamed:@"pop_des"];
        }
            break;
        case TopAlertTypeError:
            self.backgroundColor = [UIColor redColor];
            [textLabel setTextColor:[UIColor whiteColor]];
            leftIcon.image = [UIImage imageNamed:@"pop_des"];
            break;
        default:
            break;
    }
    [self addSubview:textLabel];
    [self addSubview:leftIcon];
}

-(void)touchTop:(UISwipeGestureRecognizer*)recognizer
{
    [self hide ];
}

- (void)rightBtnAction{
    if (_doBlock) {
        _doBlock();
        _doBlock = nil;
    }
}

- (void)show{
    dispatch_block_t showBlock = ^{
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
            self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y + 60);
        }
                         completion:^(BOOL finished)
         {
             //            leftIcon.layer.opacity = 1;
             //            leftIcon.transform = CGAffineTransformMakeScale(0, 0);
             
             //            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
             //                leftIcon.transform = CGAffineTransformMakeScale(1, 1);
             //            } completion:^(BOOL finished) {
             //            }];
         }];
        
        [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
    };
    
    TopAlertView *lastAlert = [TopAlertView viewWithParentView:self.superview cur:self];
    if (lastAlert)
    {
        lastAlert.nextTopAlertBlock = ^{
            showBlock();
        };
        [lastAlert hide];
    }
    else
    {
        showBlock();
    }
    
}

+ (TopAlertView*)viewWithParentView:(UIView*)parentView cur:(UIView*)cur{
    NSArray *array = [parentView subviews];
    for (UIView *view in array) {
        if ([view isKindOfClass:[TopAlertView class]] && view!=cur) {
            return (TopAlertView *)view;
        }
    }
    return nil;
}

- (void)hide{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [UIView animateWithDuration:0.2 animations:^{
        self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y - 60);
    }
                     completion:^(BOOL finished)
     {
         [self removeFromSuperview];
         self.hidden = YES;
         if (_nextTopAlertBlock)
         {
             _nextTopAlertBlock();
             _nextTopAlertBlock = nil;
         }
     }];
}

-(void)setDuration:(NSInteger)duration{
    _duration = duration;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
}

-(void)setAutoHide:(BOOL)autoHide{
    if (autoHide && !_autoHide) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    }
    _autoHide = autoHide;
}


@end
