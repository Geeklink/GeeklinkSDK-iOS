//
//  CameraListForLiveViewController.m
//  IOTCamViewer
//
//  Created by tutk on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraListForLiveViewController.h"
#import "CameraLiveViewController.h"
#import "EditCameraDefaultController.h"

@interface CameraListForLiveViewController()
{
    UIButton *editBtn;
}

//@property (strong, nonatomic) AddCameraController *addCameraCtl;
@end

@implementation CameraListForLiveViewController

@synthesize tableView;
@synthesize searchBar;
@synthesize tableViewCell;
//@synthesize addCameraCtl;

//编辑点击按钮
- (IBAction)toggleEdit:(id)sender {
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.editing)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEdit:)];
    else
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)];
}
//文件路径
- (NSString *) pathForDocumentsResource:(NSString *) relativePath {
    
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [dirs objectAtIndex:0] ;
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}
//删除摄像机
- (void)deleteCamera:(NSString *)uid {
    
    /* delete camera lastframe snapshot file */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", uid];
    [fileManager removeItemAtPath:[self pathForDocumentsResource: imgName] error:NULL];    
    
    if (database != NULL) {
        
        if (![database executeUpdate:@"DELETE FROM device where dev_uid=?", uid]) {
            NSLog(@"Fail to remove device from database.");
        }
    }
}
//删除截图
- (void)deleteSnapshotRecords:(NSString *)uid {
        
    if (database != NULL) {
        
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM snapshot WHERE dev_id=?", uid];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        while([rs next]) {
            
            NSString *filePath = [rs stringForColumn:@"file_path"];
            [fileManager removeItemAtPath:[self pathForDocumentsResource: filePath] error:NULL];        
            NSLog(@"camera(%@) snapshot removed", filePath);
        }
        
        [rs close];        
        
        [database executeUpdate:@"DELETE FROM snapshot WHERE dev_uid=?", uid];
    }  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - View lifecycle
- (void) viewDidLoad {
//    global = [GlobalVars share];
    
    self.view.frame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    [self setTitle:NSLocalizedString(@"Camera List", @"")];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:) ] ;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    searchedData = [[NSMutableArray alloc] init];
    searchBar.hidden = YES;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor whiteColor];
   
//    NSLog(@"topbnarHight:%f",topBar.view.frame.size.height);
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.toolbarHidden = YES;
//    tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [searchedData removeAllObjects];
    [searchedData addObjectsFromArray:ITOCameraList];    
    self.navigationItem.rightBarButtonItem.enabled = [searchedData count] > 0;
    
#ifndef SIMULATOR
    for (MyCamera *camera in ITOCameraList)
        camera.delegate2 = self;
#endif
    
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [searchedData removeAllObjects];
    [super viewDidDisappear:animated];
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0)
        return [searchedData count];
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"====>>>row:%d",indexPath.row);
    if (indexPath.section == 1) {
        static NSString *AddCellIdentifier = @"addCellIdentifier";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AddCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:AddCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            [cell GeekCellStyle:cell];
            
            //        cell.backgroundView = nil
        }else{
            //cell中本来就有一个subview，如果是重用cell，则把cell中自己添加的subview清除掉，避免出现重叠问题
            //         [[cell.subviews objectAtIndex:1] removeFromSuperview];
            for (UIView *subView in cell.contentView.subviews){
                
                [subView removeFromSuperview];
            }
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
        cell.textLabel.text = NSLocalizedString(@"clickToAddCam", nil);
        UIImage *image = [UIImage imageNamed:@"ic_add_camera"];
        cell.imageView.image = image;
                
        return cell;
        
    }else{
        
        static NSString *CameraListCellIdentifier = @"CameraListCellIdentifier";
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CameraListCellIdentifier];
        
        if (cell == nil) {
         
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CameraListCell" owner:self options:nil];
            if ([nib count] > 0) 
                cell = self.tableViewCell;
//            cell.backgroundColor = [GlobarMethod getThemeColor];
        }
        
#ifndef SIMULATOR
        NSUInteger row = [indexPath row];
        Camera *camera = [searchedData objectAtIndex:row];
        
        /* load camera name */
        UILabel *cameraNameLabel = (UILabel *)[cell viewWithTag:CAMERA_NAME_TAG];
        if (cameraNameLabel != nil)
        {
            cameraNameLabel.text = camera.name;
            cameraNameLabel.textColor = [UIColor whiteColor];
        }
        /* load camera status */
        UILabel *cameraStatusLabel = (UILabel *)[cell viewWithTag:CAMERA_STATUS_TAG];
//        cameraStatusLabel.textColor = [UIColor grayColor];
        
        if (camera.sessionState == CONNECTION_STATE_CONNECTING) {
            cameraStatusLabel.text = NSLocalizedString(@"Connecting...", @"");
            NSLog(@"%@ connecting", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_DISCONNECTED) {
            cameraStatusLabel.text = NSLocalizedString(@"Offline", @"");
            NSLog(@"%@ off line", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE) {
            cameraStatusLabel.text = NSLocalizedString(@"Unknown Device", @"");
            NSLog(@"%@ unknown device", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
            cameraStatusLabel.text = NSLocalizedString(@"Timeout", @"");
            NSLog(@"%@ timeout", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_UNSUPPORTED) {
            cameraStatusLabel.text = NSLocalizedString(@"Unsupported", @"");
            NSLog(@"%@ unsupported", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECT_FAILED) {
            cameraStatusLabel.text = NSLocalizedString(@"Connect Failed", @"");
            NSLog(@"%@ connected failed", camera.uid);
        }
        
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
            cameraStatusLabel.text = NSLocalizedString(@"Online", @"");
            NSLog(@"%@ online", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTING) {
            cameraStatusLabel.text = NSLocalizedString(@"Connecting...", @"");
            NSLog(@"%@ connecting", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_DISCONNECTED)
        {
            cameraStatusLabel.text = NSLocalizedString(@"Offline", @"");
            NSLog(@"%@ off line", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNKNOWN_DEVICE) {
            cameraStatusLabel.text = NSLocalizedString(@"Unknown Device", @"");
            NSLog(@"%@ unknown device", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_WRONG_PASSWORD) {
            cameraStatusLabel.text = NSLocalizedString(@"Wrong Password", @"");
            NSLog(@"%@ wrong password", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_TIMEOUT) {
            cameraStatusLabel.text = NSLocalizedString(@"Timeout", @"");
            NSLog(@"%@ timeout", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNSUPPORTED) {
            cameraStatusLabel.text = NSLocalizedString(@"Unsupported", @"");
            NSLog(@"%@ unsupported", camera.uid);
        }
        else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_NONE) {
            cameraStatusLabel.text = NSLocalizedString(@"Connecting...", @"");
            NSLog(@"%@ wait for connecting", camera.uid);
        }
        
        /* load camera UID */
        UILabel *cameraUIDLabel = (UILabel *)[cell viewWithTag:CAMERA_UID_TAG];
//        cameraUIDLabel.textColor = [GlobarMethod getColorFromARGB:geek_cellDetailTextColor];
        if (cameraUIDLabel != nil)
            cameraUIDLabel.text = camera.uid;    
            
        /* load camera snapshot */
        UIImageView *cameraSnapshotImageView = (UIImageView *)[cell viewWithTag:CAMERA_SNAPSHOT_TAG];
        if (cameraSnapshotImageView != nil) {
            NSString *imgFullName = [self pathForDocumentsResource:[NSString stringWithFormat:@"%@.jpg", camera.uid]];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imgFullName];
            NSLog(@"exist:%d",fileExists);
            cameraSnapshotImageView.image = fileExists ? [UIImage imageWithContentsOfFile:imgFullName] : [UIImage imageNamed:@"videoClip.png"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
#endif
        return cell;
    }
}

#pragma mark - TableView Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [searchBar resignFirstResponder];
    return indexPath;
}
//选中状态
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0){
        
#ifndef SIMULATOR
        MyCamera *camera = [searchedData objectAtIndex:[indexPath row]];
        CameraLiveViewController *controller = [[CameraLiveViewController alloc] initWithNibName:@"CameraLiveView" bundle:nil];
        
        controller.camera = camera;
        controller.selectedChannel = camera.lastChannel;
        controller.hidesBottomBarWhenPushed = YES;
    
        // controller.selectedAudioMode = AUDIO_MODE_SPEAKER;
        
        [self.navigationController pushViewController:controller animated:YES];
#endif
//        [controller release];
    } else if (indexPath.section == 1){
        
    }
}
//可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return YES;
    else
        return NO;
}
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 50;
    }
    return 70;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
    if (indexPath.section == 0) {
#ifndef SIMULATOR
        NSString *uid = nil;
        
        Camera *camera = [searchedData objectAtIndex:[indexPath row]];
        [camera stop:0];
        [camera disconnect];
        
        uid = camera.uid;
        
        [searchedData removeObjectAtIndex:[indexPath row]];
        [ITOCameraList removeObject:camera];
        
        if (uid != nil) {
            
            // delete camera & snapshot file in db
            [self deleteCamera:uid];
            [self deleteSnapshotRecords:uid];

        }
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
#endif
    }
}
//查看摄像机信息
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{    
    EditCameraDefaultController *controller = [[EditCameraDefaultController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.camera = [searchedData objectAtIndex:[indexPath row]];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
//    [controller release];
}

#pragma mark - SearchBar Delegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    self.searchBar.showsCancelButton = YES;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [searchedData removeAllObjects];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    self.searchBar.showsCancelButton = NO;
    self.navigationItem.rightBarButtonItem.enabled = [searchedData count] > 0; 
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
 
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
 
    [searchedData removeAllObjects];
    
    if ([searchText isEqualToString:@""]) {
        [self.tableView reloadData];
        return;
    }    
    
#ifndef SIMULATOR
    for (Camera *camera in ITOCameraList) {
        
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSRange range = [camera.name rangeOfString:searchText];
        
        if (range.location != NSNotFound && range.location == 0)             
            [searchedData addObject:camera];    
        
//        [pool release];
    }
#endif

    self.navigationItem.rightBarButtonItem.enabled = [searchedData count] > 0;    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchedData removeAllObjects];
    [searchedData addObjectsFromArray:ITOCameraList];
    
    @try {
        [self.tableView reloadData];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [self.searchBar resignFirstResponder];
        self.searchBar.text = @"";
    }
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] 
             URLsForDirectory:NSDocumentDirectory 
             inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - MyCameraDelegate Methods

#ifndef SIMULATOR
- (void)camera:(MyCamera *)camera _didChangeSessionStatus:(NSInteger)status
{
    if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [camera disconnect];
            
        });
    }
    
    if (!self.tableView.editing)
        [self.tableView reloadData];
}

- (void)camera:(MyCamera *)camera _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
    if (status == CONNECTION_STATE_TIMEOUT) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [camera stop:channel];
            
            usleep(500 * 1000);
            
            [camera disconnect];
        });
    }
    
    if (!self.tableView.editing)
        [self.tableView reloadData];
}
#endif

@end
