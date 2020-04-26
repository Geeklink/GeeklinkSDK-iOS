//
//  TopLocationServerHandle.m
//  Top
//
//  Created by 列树童 on 2017/5/11.
//  Copyright © 2017年 Geeklink. All rights reserved.
//

#import "TopLocationDataHandle.h"
#import "GlobalVars.h"

@implementation TopLocationDataHandle

- (id)initWithApi:(id<GLApi>)api {
    self = [super init];
    if (self) {
        if (api) {
            self.handle = [api observerLocationHandle];
            [self.handle init:self];
        } else {
            NSLog(@"ERR! api should init first");
        }
    }
    return self;
}


- (void)fromServerPartsHomeSet:(GLStateType)state {
    TopSlaveAckInfo * slaveAckInfo = [[TopSlaveAckInfo alloc] init];
    slaveAckInfo.state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fromServerPartsHomeSet" object:slaveAckInfo];
}

@end
