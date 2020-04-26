//
//  cameraTypeLayout.m
//  topt1
//
//  Created by linter on 15/1/23.
//  Copyright (c) 2015年 linter. All rights reserved.
//

#import "cameraTypeLayout.h"

@implementation cameraTypeLayout

@synthesize ctlList;
- (id)init
{
    self = [super init];
    if (self) {
        global = [GlobalVars shareGlobalVars];
        ctlList = [[NSMutableArray alloc]init];
        ctlItem *item1 = [[ctlItem alloc]init];
        item1.type = GLKeyCtlTypeCTLCURTAINOPEN;
        item1.name = [global getDefaultNameStrForCtl:item1.type];
        
        
        ctlItem *item2 = [[ctlItem alloc]init];
        item2.type = GLKeyCtlTypeCTLCURTAINSTOP;
        item2.name = [global getDefaultNameStrForCtl:item2.type];
        
        ctlItem *item3 = [[ctlItem alloc]init];
        item3.type = GLKeyCtlTypeCTLCURTAINCLOSE;
        item3.name = [global getDefaultNameStrForCtl:item3.type];
        
        
        ctlItem *item4 = [[ctlItem alloc]init];
        item4.type = GLKeyCtlTypeCTLPLUG;
        item4.name = [global getDefaultNameStrForCtl:item4.type];
        
        ctlItem *item5 = [[ctlItem alloc]init];
        item5.type = GLKeyCtlTypeCTLOUTLET;
        item5.name = [global getDefaultNameStrForCtl:item5.type];
        
        
        ctlItem *item6 = [[ctlItem alloc]init];
        item6.type = GLKeyCtlTypeCTLLIGHT;
        item6.name = [global getDefaultNameStrForCtl:item6.type];
        
        ctlItem *item7 = [[ctlItem alloc]init];
        item7.type = GLKeyCtlTypeCTLCAMERA;
        item7.name = [global getDefaultNameStrForCtl:item7.type];
        
        item1.prect = CGRectMake(35, 200, 60, 80);
        item2.prect = CGRectMake(130, 200, 60, 80);
        item3.prect = CGRectMake(225, 200, 60, 80);
        item4.prect = CGRectMake(35, 290, 60, 80);
        item5.prect = CGRectMake(130, 290, 60, 80);
        item6.prect = CGRectMake(225, 290, 60, 80);
        item7.prect = CGRectMake(0, 0, 320, 180);
        
        [ctlList addObject:item1];
        [ctlList addObject:item2];
        [ctlList addObject:item3];
        [ctlList addObject:item4];
        [ctlList addObject:item5];
        [ctlList addObject:item6];
        [ctlList addObject:item7];
        
    }
    return  self;
}

- (void)dealloc {
    ctlList = Nil;
}

@end
