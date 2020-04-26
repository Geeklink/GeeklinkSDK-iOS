//
//  TopMsgLogCell.h
//  Top
//
//  Created by Lieshutong on 16/4/14.
//  Copyright © 2016年 Geeklink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopMsgLogCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *timelbl;
@property (weak, nonatomic) IBOutlet UILabel *msgLbl;
@property (weak, nonatomic) IBOutlet UIImageView *redPoi;

@end
