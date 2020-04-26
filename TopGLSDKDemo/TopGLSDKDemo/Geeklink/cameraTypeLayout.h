//
//  cameraTypeLayout.h
//  topt1
//
//  Created by linter on 15/1/23.
//  Copyright (c) 2015年 linter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ctlItem.h"
#import "GlobalVars.h"

@interface cameraTypeLayout : NSObject
{
    GlobalVars *global;
}

@property (nonatomic,retain) NSMutableArray *ctlList;
@end
