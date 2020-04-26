//
//  TopEZCamTools.h
//  Top
//
//  Created by 列树童 on 2017/12/1.
//  Copyright © 2017年 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopEZCamTools : NSObject 
@property (nonatomic, strong) NSArray * adminList;
@property (nonatomic, strong) NSArray * shareList;
+ (TopEZCamTools *)shareTopEZCamTools;

- (void)checkDevList;
- (NSArray *)loadAdminList;
- (NSArray *)loadShareList;
- (void)cleanCamList;

@end
