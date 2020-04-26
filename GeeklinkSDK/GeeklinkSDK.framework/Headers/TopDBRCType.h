//
//  TopDBRCType.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/25.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopDBRCType : NSObject
@property (nonatomic , assign) NSInteger ID;
@property (nonatomic , copy) NSString * name;
@property (nonatomic , strong) NSMutableArray * brandList;
@end

NS_ASSUME_NONNULL_END
