//
//  CameraListForLiveViewController.h
//  IOTCamViewer
//
//  Created by tutk on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "MyCamera.h"


//#define HIRESDEVICE (((int)rintf([[[UIScreen mainScreen] currentMode] size].width/[[UIScreen mainScreen] bounds].size.width ) > 1))

#define CAMERA_NAME_TAG 1
#define CAMERA_STATUS_TAG 2
#define CAMERA_UID_TAG 3
#define CAMERA_SNAPSHOT_TAG 4

extern NSMutableArray *ITOCameraList;
extern FMDatabase *database;
//extern NSString *deviceTokenString;

@class Camera;

@interface CameraListForLiveViewController : UIViewController 
    <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MyCameraDelegate> {

    NSMutableArray *searchedData;
    UITableView *tableView;
    UISearchBar *searchBar;
    UITableViewCell *tableViewCell;
//    GlobalVars *global;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableViewCell *tableViewCell;


- (IBAction)toggleEdit:(id)sender;

@end
