//
//  TopDisinfectionLampMainVC.m
//  Geeklink
//
//  Created by 杨飞飞 on 2020/5/19.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopDisinfectionLampMainVC.h"
#import <GeeklinkSDK/SDK.h>
#import "SVProgressHUD.h"
#import "TopDisinfectionLampRecordVC.h"
#import "TopDisinfectionLampTimerVC.h"
#import "TopSetTimeZoneVC.h"
typedef NS_ENUM(NSInteger, TopDisinfectionLampMainVCCellType)
{
    /*设备在线状态*/
    TopDisinfectionLampMainVCCellTypeState = 0,
    /*ip局域网状态下才有的*/
    TopDisinfectionLampMainVCCellTypeIp,
    /*设备mac*/
    TopDisinfectionLampMainVCCellTypeMac,
    /*设备当前版本*/
    TopDisinfectionLampMainVCCellTypeCurVer,
    /*设备最新版本*/
    TopDisinfectionLampMainVCCellTypeLatestVer,
    
    /*时区*/
    TopDisinfectionLampMainVCCellTypeTimezone,
    /*定时*/
    TopDisinfectionLampMainVCCellTypeTimer,
    /*历史记录*/
    TopDisinfectionLampMainVCCellTypeRecord,
    /*控制*/
    TopDisinfectionLampMainVCCellTypeCtrl,
    /*儿童锁*/
    TopDisinfectionLampMainVCCellTypeChildLock,
    
    
   
    
};
@interface TopDisinfectionLampMainVC ()<UITableViewDataSource, UITableViewDelegate, TopGLAPIManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * cellTypeList;
@property (strong, nonatomic) TopMainDevStateInfo * stateInfo;
@property (assign, nonatomic) NSInteger timezone;

@property (assign, nonatomic) BOOL child_lock;
@end

@implementation TopDisinfectionLampMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    TopGLAPIManager.shareManager.delegate = self;
    __weak typeof(self) weakSelf = self;
    [[TopGLAPIManager shareManager] getDeviceStateInfo:self.mainDeviceInfo.md5 complete:^(TopGLAPIResult * _Nonnull resucltInfo) {
        
        [weakSelf refreshTableViewCellWithMainDevStateInfo:resucltInfo.mainDevStateInfo];
        
    }];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    
    //Get new status. 获取最新状态
    [[TopGLDisinfectionLampAPIManager shareManager] getDisinfectionLampState:self.mainDeviceInfo.md5 complete:^(TopGLDisinfectionLampResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            [weakSelf refreshTableViewCellWithMainDevStateInfo:resucltInfo.mainDevStateInfo];
        }else {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
        }
    }];
    
    [[TopGLDisinfectionLampAPIManager shareManager] disinfectionLampChildLock:self.mainDeviceInfo.md5 action:GLActionTypeCheck child_lock:false complete:^(TopGLDisinfectionLampResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            weakSelf.child_lock = resucltInfo.child_lock;
        }
        [weakSelf.tableView reloadData];
    }];
    

 
    
}
- (void)refreshTableViewCellWithMainDevStateInfo: (TopMainDevStateInfo *) mainDevStateInfo{
    [self.cellTypeList removeAllObjects];
    
    self.stateInfo = mainDevStateInfo;
    
    if (self.stateInfo.state == GLDevConnectStateOffline) {
        [self.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeState)];
    }else {
        [self.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeState)];
        [self.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeIp)];
        [self.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeMac)];
        [self.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeCurVer)];
        [self.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeLatestVer)];
         [self.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeCtrl)];
        [self.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeTimer)];
        [self.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeRecord)];
        [self.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeChildLock)];
    }
    [self.tableView reloadData];
    
    __weak typeof(self) weakSelf = self;
    [[TopGLAPIManager shareManager] deviceTimezoneWithMd5:self.mainDeviceInfo.md5 action:GLTimezoneActionTimezoneActionGet timezone:0 complete:^(TopGLAPIResult * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            weakSelf.timezone = resucltInfo.timezone;
            [weakSelf.cellTypeList addObject:@(TopDisinfectionLampMainVCCellTypeTimezone)];
            [weakSelf.tableView reloadData];
        }
        
    }];
}
- (NSMutableArray *)cellTypeList {
    if (_cellTypeList == nil) {
        _cellTypeList = [NSMutableArray array];
    }
    return _cellTypeList;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSNumber * number = self.cellTypeList[indexPath.section];
    TopDisinfectionLampMainVCCellType  cellType =  number.integerValue;
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (cellType) {
            
        case TopDisinfectionLampMainVCCellTypeState: {
            cell.textLabel.text = NSLocalizedString(@"Status", @"");
            
            switch (self.stateInfo.state) {
                    
                case GLDevConnectStateOffline:
                    cell.detailTextLabel.text = NSLocalizedString(@"Offline",@"");
                    break;
                case GLDevConnectStateLocal:
                    cell.detailTextLabel.text = NSLocalizedString(@"Local online",@"");
                    break;
                case GLDevConnectStateRemote:
                    cell.detailTextLabel.text = NSLocalizedString(@"Remote online",@"");
                    break;
                case GLDevConnectStateNeedBindAgain:
                    cell.detailTextLabel.text = NSLocalizedString(@"",@"");
                    break;
                    //                case GLDevConnectStateCount:
                    //                    break;
            }
            break;
            
        }
            
            
        case TopDisinfectionLampMainVCCellTypeIp: {
            cell.textLabel.text = @"Ip";
            cell.detailTextLabel.text = self.stateInfo.ip;
            break;
        }
            
            
        case TopDisinfectionLampMainVCCellTypeMac: {
            cell.textLabel.text = @"MAC";
            cell.detailTextLabel.text = self.stateInfo.mac;
            break;
            
        }
            
        case TopDisinfectionLampMainVCCellTypeCurVer: {
            cell.textLabel.text = NSLocalizedString(@"Current version", @"");
            cell.detailTextLabel.text = self.stateInfo.curVer;
            break;
            
        }
            
            
            
        case TopDisinfectionLampMainVCCellTypeLatestVer: {
            cell.textLabel.text = NSLocalizedString(@"New version", @"");
            cell.detailTextLabel.text = self.stateInfo.latestVer;
            break;
        }
            
        case TopDisinfectionLampMainVCCellTypeTimezone: {
            cell.textLabel.text = NSLocalizedString(@"Device Time", @"");
            NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
            dateformatter.dateFormat = @"HH:mm";
            NSInteger time = self.timezone * 60;
            dateformatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            NSDate * newdate = [NSDate dateWithTimeInterval:(NSTimeInterval)time sinceDate: [NSDate new]];
            cell.detailTextLabel.text = [dateformatter stringFromDate:newdate];
            break;
            
        }
        
        case TopDisinfectionLampMainVCCellTypeTimer:
        {
            UITableViewCell * cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = NSLocalizedString(@"Timed list",@"");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            break;
            
        }
        case TopDisinfectionLampMainVCCellTypeChildLock:
        {
           
            cell.textLabel.text = NSLocalizedString(@"Child Lock",@"");
            cell.detailTextLabel.text = self.child_lock ? NSLocalizedString(@"ON", @"") : NSLocalizedString(@"OFF", @"");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            break;
            
        }
            
            
        case TopDisinfectionLampMainVCCellTypeCtrl: {
         
          
            switch (self.stateInfo.disinfection_state) {
              
                case TopDisinfectionStateTypeON:
                    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Disinfecting (%d s/ %d Min)", @""),self.stateInfo.disinfection_cur_dur, self.stateInfo.disinfection_all_dur];
                    cell.textLabel.text = NSLocalizedString(@"Click to Stop Disinfection", @"");
                    break;
                case TopDisinfectionStateTypeOFF:{
                    cell.textLabel.text = NSLocalizedString(@"Click to Start Disinfection", @"");
                    if (self.stateInfo.disinfection_last_time > 1) {
                        NSDate * date = [NSDate dateWithTimeIntervalSince1970:self.stateInfo.disinfection_last_time];
                        NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
                        
                        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
                        
                        NSString* timeStr =[dateFormat stringFromDate:date];
                        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last disinfection time: %@", @""), timeStr];
                    }else {
                        cell.detailTextLabel.text = NSLocalizedString(@"Not yet disinfected.", @"");
                    }
                    return  cell;
                   
                }
                    
                    break;
                case TopDisinfectionStateTypePAUSE:
                    cell.textLabel.text = NSLocalizedString(@"Someone Detected", @"");
                    
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Pause disinfection."];
                    break;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            break;
        }
        case TopDisinfectionLampMainVCCellTypeRecord: {
            UITableViewCell * cell = [[UITableViewCell alloc] init];
            cell.textLabel.text =NSLocalizedString(@"Record", @"");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            break;
        }
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.cellTypeList count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSNumber * number = self.cellTypeList[indexPath.section];
    TopDisinfectionLampMainVCCellType  cellType =  number.integerValue;
    
    switch (cellType) {
            
        case TopDisinfectionLampMainVCCellTypeRecord: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TopDisinfectionLampRecordVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"TopDisinfectionLampRecordVC"];
            vc.mainDeviceInfo = self.mainDeviceInfo;
            [self showViewController:vc sender:nil];
        }
            break;
        case TopDisinfectionLampMainVCCellTypeTimer: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TopDisinfectionLampTimerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"TopDisinfectionLampTimerVC"];
            vc.mainDeviceInfo = self.mainDeviceInfo;
            [self showViewController:vc sender:nil];
            
        }
            break;
            case TopDisinfectionLampMainVCCellTypeCtrl:
            switch (self.stateInfo.disinfection_state) {
                case TopDisinfectionStateTypeOFF:
                {
                    
                    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                    if (alertVC.popoverPresentationController != nil) {
                        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
                        alertVC.popoverPresentationController.sourceView = cell;
                        alertVC.popoverPresentationController.sourceRect = cell.bounds;
                        
                    }
                    
                    
                    UIAlertAction * action_15 = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"%d Min", @""), 15] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                       
                        [self controlDisinfectionLampWithTime:15];
                    }];
                    
                    UIAlertAction * action_30 = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"%d Min", @""), 30] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [self controlDisinfectionLampWithTime:30];
                    }];
                    
                    
                    UIAlertAction * action_60 = [UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"%d Min", @""), 60] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [self controlDisinfectionLampWithTime:60];
                    }];
                    
                    [alertVC addAction:action_15];
                    [alertVC addAction:action_30];
                    [alertVC addAction:action_60];
                    
                    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }]];
                    [self presentViewController:alertVC animated:true completion:^{
                        
                    }];
                    
                }
                    break;
                case TopDisinfectionStateTypeON:
                {
                    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                    if (alertVC.popoverPresentationController != nil) {
                        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
                        alertVC.popoverPresentationController.sourceView = cell;
                        alertVC.popoverPresentationController.sourceRect = cell.bounds;
                        
                    }
                    
                    
                    UIAlertAction * stopAcion = [UIAlertAction actionWithTitle:NSLocalizedString(@"Stop", "") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [self controlDisinfectionLampWithTime:0];
                    }];
                    [alertVC addAction:stopAcion];
                    
                    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }]];
                    [self presentViewController:alertVC animated:true completion:^{
                        
                    }];
                }
                    break;
                case TopDisinfectionStateTypePAUSE:
                    
                    break;
            }
            break;
     
        case TopDisinfectionLampMainVCCellTypeTimezone:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TopSetTimeZoneVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"TopSetTimeZoneVC"];
            vc.mainDeviceInfo = self.mainDeviceInfo;
            [self showViewController:vc sender:nil];
        }
        case TopDisinfectionLampMainVCCellTypeChildLock:{
            [[TopGLDisinfectionLampAPIManager shareManager] disinfectionLampChildLock:self.mainDeviceInfo.md5 action:GLActionTypeModify child_lock:!self.child_lock complete:^(TopGLDisinfectionLampResultInfo * _Nonnull resucltInfo) {
                self.child_lock = resucltInfo.child_lock;
                [self.tableView reloadData];
            }];
        }
            
            
        default:
            break;
            
    }
    
}
- (void)controlDisinfectionLampWithTime:(NSInteger) min {
    [[TopGLDisinfectionLampAPIManager shareManager] controlDisinfectionLamp:self.mainDeviceInfo.md5 disinfection_time:min account:@"GeeklinkTest2020@163.com" complete:^(TopGLDisinfectionLampResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk){
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
            
        }else {
           
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
        }
    }];
    
}
- (void)deviceStateChange:(nonnull TopGLAPIResult *)resultInfo {
    __weak typeof(self) weakSelf = self;
    [weakSelf refreshTableViewCellWithMainDevStateInfo:resultInfo.mainDevStateInfo];
    
   
}

@end
