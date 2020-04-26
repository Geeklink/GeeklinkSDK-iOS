//
//  TopThkAckInfo.h
//  Top
//
//  Created by 列树童 on 2017/7/13.
//  Copyright © 2017年 Geeklink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geeklink-Bridging-Header.h"

@interface TopThkAckInfo : NSObject

@property (nonatomic, assign) GLActionFullType action;

@property (nonatomic, assign) BOOL isSuccess;

@property (nonatomic, retain) NSData *pin;
@property (nonatomic, retain) NSData *partsMd5;
@property (nonatomic, retain) NSArray *partsList;
@property (nonatomic, retain) NSArray *baseList;
@property (nonatomic, assign) NSInteger coundown;
@property (nonatomic, retain) NSString *homeId;
@property (nonatomic, retain) NSString *routerInfo;
@property (nonatomic, assign) int32_t deviceId;
@property (nonatomic, assign) int32_t studyType;
@property (nonatomic, retain) NSString *studyData;
@property (nonatomic, retain) NSArray *list;

@property (nonatomic, assign) GLStateType state;

@property (nonatomic, assign, getter=isAlerm) BOOL alerm;

@property (nonatomic, retain) NSArray *deviceList;



@end
