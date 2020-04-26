//
//  TopLocationServerHandle.h
//  Top
//
//  Created by 列树童 on 2017/5/11.
//  Copyright © 2017年 Geeklink. All rights reserved.
//

#import "TopSuperDataHandle.h"

@interface TopLocationDataHandle : TopSuperDataHandle <GLLocationHandleObserver>

@property (nonatomic, retain) id <GLLocationHandle> handle;

- (id)initWithApi:(id<GLApi>)api;

@end
