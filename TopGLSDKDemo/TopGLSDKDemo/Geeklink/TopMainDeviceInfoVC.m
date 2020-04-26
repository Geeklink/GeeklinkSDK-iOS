//
//  TopMainDeviceInfoVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/27.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopMainDeviceInfoVC.h"
#import <GeeklinkSDK/SDK.h>
#import "TopSubDeviceVC.h"
#import "TopCodeVC.h"
#import "TopTimerListVC.h"
#import "TopSetTimeZoneVC.h"
typedef NS_ENUM(NSInteger, TopMainDeviceInfoVCCellType)
{
    /*设备在线状态*/
    TopMainDeviceInfoVCCellTypeState = 0,
    /*ip局域网状态下才有的*/
    TopMainDeviceInfoVCCellTypeIp,
    /*设备mac*/
    TopMainDeviceInfoVCCellTypeMac,
    /*设备当前版本*/
    TopMainDeviceInfoVCCellTypeCurVer,
    /*设备最新版本*/
    TopMainDeviceInfoVCCellTypeLatestVer,
    
    /*定时*/
    TopMainDeviceInfoVCCellTypeTimezone,
    
    
    /*设备最新版本*/
    TopMainDeviceInfoVCCellTypeSubDevice,
    
    /*定时*/
    TopMainDeviceInfoVCCellTypeTime,
    
    /*红外码操作*/
    TopMainDeviceInfoVCCellTypeCode,
    
};
@interface TopMainDeviceInfoVC ()<UITableViewDataSource, UITableViewDelegate, TopGLAPIManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * cellTypeList;
@property (strong, nonatomic) TopMainDevStateInfo * stateInfo;
@property (assign, nonatomic) NSInteger timezone;
@end

@implementation TopMainDeviceInfoVC


- (void)viewDidLoad {
    [super viewDidLoad];
   
  
    TopGLAPIManager.shareManager.delegate = self;
   
  
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cellTypeList removeAllObjects];
     __weak typeof(self) weakSelf = self;
    [[TopGLAPIManager shareManager]getDeviceStateInfo:self.mainDeviceInfo.md5 complete:^(TopResultInfo * _Nonnull resucltInfo) {
        weakSelf.stateInfo = resucltInfo.mainDevStateInfo;
        if (weakSelf.stateInfo.state == GLDevConnectStateOffline) {
            [weakSelf.cellTypeList addObject:@(TopMainDeviceInfoVCCellTypeState)];
        }else {
            [weakSelf.cellTypeList addObject:@(TopMainDeviceInfoVCCellTypeState)];
            [weakSelf.cellTypeList addObject:@(TopMainDeviceInfoVCCellTypeIp)];
            [weakSelf.cellTypeList addObject:@(TopMainDeviceInfoVCCellTypeMac)];
            [weakSelf.cellTypeList addObject:@(TopMainDeviceInfoVCCellTypeCurVer)];
            [weakSelf.cellTypeList addObject:@(TopMainDeviceInfoVCCellTypeLatestVer)];
            [weakSelf.cellTypeList addObject:@(TopMainDeviceInfoVCCellTypeSubDevice)];
            [weakSelf.cellTypeList addObject:@(TopMainDeviceInfoVCCellTypeTime)];
            [weakSelf.cellTypeList addObject:@(TopMainDeviceInfoVCCellTypeCode)];
        }
        [weakSelf.tableView reloadData];
    }];
    [[TopGLAPIManager shareManager] deviceTimezoneWithMd5:self.mainDeviceInfo.md5 action:GLTimezoneActionTimezoneActionGet timezone:0 complete:^(TopResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            weakSelf.timezone = resucltInfo.timezone;
            [weakSelf.cellTypeList addObject:@(TopMainDeviceInfoVCCellTypeTimezone)];
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
    TopMainDeviceInfoVCCellType  cellType =  number.integerValue;
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (cellType) {
    
        case TopMainDeviceInfoVCCellTypeState: {
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
            
          
        case TopMainDeviceInfoVCCellTypeIp: {
            cell.textLabel.text = @"Ip";
            cell.detailTextLabel.text = self.stateInfo.ip;
            break;
        }
            
          
        case TopMainDeviceInfoVCCellTypeMac: {
            cell.textLabel.text = @"MAC";
            cell.detailTextLabel.text = self.stateInfo.mac;
             break;
            
        }
           
        case TopMainDeviceInfoVCCellTypeCurVer: {
            cell.textLabel.text = NSLocalizedString(@"Current version", @"");
            cell.detailTextLabel.text = self.stateInfo.curVer;
            break;
            
        }
            
            
            
        case TopMainDeviceInfoVCCellTypeLatestVer: {
            cell.textLabel.text = NSLocalizedString(@"New version", @"");
            cell.detailTextLabel.text = self.stateInfo.latestVer;
            break;
        }
            
        case TopMainDeviceInfoVCCellTypeTimezone: {
            cell.textLabel.text = NSLocalizedString(@"Device Time", @"");
            NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
            dateformatter.dateFormat = @"HH:mm";
            NSInteger time = self.timezone * 60;
            dateformatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            NSDate * newdate = [NSDate dateWithTimeInterval:(NSTimeInterval)time sinceDate: [NSDate new]];
            cell.detailTextLabel.text = [dateformatter stringFromDate:newdate];
            break;
          
        }
        case TopMainDeviceInfoVCCellTypeSubDevice:
        {
             UITableViewCell * cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = NSLocalizedString(@"Sub Deivce",@"");
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
             return cell;
            break;
            
        }
        case TopMainDeviceInfoVCCellTypeTime:
        {
            UITableViewCell * cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = NSLocalizedString(@"Timed list",@"");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            break;
            
        }
       
            
        case TopMainDeviceInfoVCCellTypeCode: {
            UITableViewCell * cell = [[UITableViewCell alloc] init];
            cell.textLabel.text =NSLocalizedString(@"Infrared code reading and sending", @"");
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
    TopMainDeviceInfoVCCellType  cellType =  number.integerValue;
  
    switch (cellType) {
            
        case TopMainDeviceInfoVCCellTypeSubDevice: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TopSubDeviceVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"TopSubDeviceVC"];
            vc.mainDeviceInfo = self.mainDeviceInfo;
            [self showViewController:vc sender:nil];
        }
             break;
        case TopMainDeviceInfoVCCellTypeTime: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TopTimerListVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"TopTimerListVC"];
            vc.mainDeviceInfo = self.mainDeviceInfo;
            [self showViewController:vc sender:nil];

        }
            break;
        case TopMainDeviceInfoVCCellTypeCode:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TopCodeVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"TopCodeVC"];
            vc.mainDeviceInfo = self.mainDeviceInfo;
            [self showViewController:vc sender:nil];
        }
             break;
        case TopMainDeviceInfoVCCellTypeTimezone:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TopSetTimeZoneVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"TopSetTimeZoneVC"];
            vc.mainDeviceInfo = self.mainDeviceInfo;
            [self showViewController:vc sender:nil];
        }
            
            
            default:
            break;
            
    }
  
}

- (void)deviceStateChange:(nonnull TopResultInfo *)resultInfo {
    [self.tableView reloadData];
}

@end
