//
//  CHLoadingView.m
//  JdPlayOpenSDKWithUI
//
//  Created by 沐阳 on 16/11/15.
//  Copyright © 2016年 沐阳. All rights reserved.
//

#import "CHLoadingView.h"

@implementation CHLoadingView

-(UILabel *)textL {
    
    if (_textL == nil) {
        UILabel * l = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 100, 25)];
        
        l.textColor = [UIColor whiteColor];
        l.textAlignment = NSTextAlignmentCenter;
        l.font = [UIFont systemFontOfSize:13];
        l.text = @"努力加载中...";
        _textL = l;
    }
    return _textL;
}

-(UIView *)maxCover {
    if (_maxCover == nil) {
        UIView * v = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [v setBackgroundColor:[UIColor blackColor]];
        [v setAlpha:0.7];
        _maxCover = v;
    }
    return _maxCover;
}


- (UIActivityIndicatorView *)activity
{
    if (_activity == nil) {
        
        UIActivityIndicatorView * view = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(35, 20, 30, 30)];
        view.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _activity = view;
    }
    return _activity;
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        [self addSubview:self.activity];
        [self addSubview:self.textL];
    }
    return self;
}



+ (CHLoadingView *)showWithView:(UIView *)view
{
    CHLoadingView * load = [[self alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    load.center = view.center;
    [load.activity startAnimating];
    [view addSubview:load.maxCover];
    [view addSubview:load];
    return load;
}



+ (CHLoadingView *)showWithView:(UIView*)view withTip:(NSString *)tip{
    
    CHLoadingView * load = [[self alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    load.center = view.center;
    [load.activity startAnimating];
    load.textL.text = tip;
    [view addSubview:load.maxCover];
    [view addSubview:load];
    return load;
}


- (void)dismiss
{
    [self.activity stopAnimating];
    [self.maxCover removeFromSuperview];
    [self removeFromSuperview];
}


@end
