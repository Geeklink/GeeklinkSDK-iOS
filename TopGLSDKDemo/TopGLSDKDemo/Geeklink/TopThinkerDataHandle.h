//
//  TopThinkerDataHandle.h
//  Top
//
//  Created by linter on 15/9/13.
//  Copyright (c) 2015年 Geeklink. All rights reserved.
//

#import "TopSuperDataHandle.h"
#import "TopThkAckInfo.h"

@interface TopThinkerDataHandle : TopSuperDataHandle <GLThinkerHandleObserver>

@property (nonatomic, retain) id <GLThinkerHandle> handle;

- (id)initWithApi:(id<GLApi>)api;

@end
