//
//  topSwitchDoubleL.m
//  dragTest
//
//  Created by linter on 14-3-14.
//  Copyright (c) 2014年 linter. All rights reserved.
//

#import "topSwitchDoubleL.h"

@implementation topSwitchDoubleL
@synthesize ctlList;
    
- (id)initWithOne
{
    self = [super init];
    if (self) {
        ctlList = [[NSMutableArray alloc]init];
        ctlItem *item1 = [[ctlItem alloc]init];
        item1.type = GLKeyCtlTypeCTLABUTTON;
        
 
        item1.prect = CGRectMake(80, 160, 160, 160);
       
        [ctlList addObject:item1];

        
    }
    return  self;
}
    
- (id)initWithTwo
{
    self = [super init];
    if (self) {
        ctlList = [[NSMutableArray alloc]init];
        ctlItem *item1 = [[ctlItem alloc]init];
        item1.type = GLKeyCtlTypeCTLABUTTON;
        
        ctlItem *item2 = [[ctlItem alloc]init];
        item2.type = GLKeyCtlTypeCTLBBUTTON;
        
        
        item1.prect = CGRectMake(80, 20, 160, 160);
        item2.prect = CGRectMake(80, 200, 160, 160);
        
        [ctlList addObject:item1];
        [ctlList addObject:item2];
        
        
    }
    return  self;
}
    
- (id)initWithThree
{
    self = [super init];
    if (self) {
        ctlList = [[NSMutableArray alloc]init];
        ctlItem *item1 = [[ctlItem alloc]init];
        item1.type = GLKeyCtlTypeCTLABUTTON;
        
        ctlItem *item2 = [[ctlItem alloc]init];
        item2.type = GLKeyCtlTypeCTLBBUTTON;
        
        ctlItem *item3 = [[ctlItem alloc]init];
        item3.type = GLKeyCtlTypeCTLCBUTTON;
        
        item1.prect = CGRectMake(80, 20, 80, 80);
        item2.prect = CGRectMake(80, 120, 80, 80);
        item3.prect = CGRectMake(80, 220, 80, 80);
        
        [ctlList addObject:item1];
        [ctlList addObject:item2];
        [ctlList addObject:item3];
        
    }
    return  self;
}

- (void)dealloc {
     ctlList = nil;
}


@end
