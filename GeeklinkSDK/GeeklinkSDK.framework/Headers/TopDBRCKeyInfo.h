//
//  TopDBRCKeyInfo.h
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/25.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopDBRCKeyInfo : NSObject

@property (nonatomic , copy) NSString * name;
@property (nonatomic , assign) NSInteger key;

@property (nonatomic , assign) NSInteger ID;
@property (nonatomic , copy) NSString * irDataStr;
@property (nonatomic , strong) NSData * irData;
@end

NS_ASSUME_NONNULL_END
