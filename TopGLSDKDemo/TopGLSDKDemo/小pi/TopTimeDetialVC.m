//
//  TopTimeDetialVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/31.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopTimeDetialVC.h"
#import <GeeklinkSDK/SDK.h>
#import "TopSelectSubDeviceActionVC.h"
#import "SVProgressHUD.h"
typedef NS_ENUM(NSInteger, TopTimeDetialVCCellType)
{
    /*设备在线状态*/
    TopTimeDetialVCCellTypeName,
    /*设备在线状态*/
    TopTimeDetialVCCellTypeTime,
    /*ip局域网状态下才有的*/
    TopTimeDetialVCCellTypeWeek,
    /*设备mac*/
    TopTimeDetialVCCellTypeActionList,
    /*设备当前版本*/
  
    
};
@interface TopTimeDetialVC ()<UITableViewDelegate, UITableViewDataSource, TopSelectSubDeviceActionVCDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * cellTypeList;
@property (strong, nonatomic) NSMutableArray * actionInfoList;
@property (strong, nonatomic) TopTimeInfo * timeInfo;
@end

@implementation TopTimeDetialVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.timerSimpleInfo == nil) {
        self.timeInfo = [[TopTimeInfo alloc] init];
        //我这里默认上午9点
        self.timeInfo.name = NSLocalizedString(@"Timer", @"");
        self.timeInfo.time =  60 * 9;
        //我这里默认工作日，具体需要你们看里边说明设置
        self.timeInfo.week = 0x3f;
    }else {
        __weak typeof(self) weakSelf = self;
        [TopGLSmartPiAPIManager.shareManager getTimeInfoDetailWithMd5:self.mainDeviceInfo.md5 timeId:self.timerSimpleInfo.timerId complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk) {
                weakSelf.timeInfo = resucltInfo.timeInfo;
                self.actionInfoList = [NSMutableArray arrayWithArray:resucltInfo.timeInfo.actionInfoList];
                [weakSelf.tableView reloadData];
                
            }
        }];
    }
    // Do any additional setup after loading the view.
}

- (IBAction)clickedSaveBtn:(id)sender {
    
    self.timeInfo.actionInfoList = self.actionInfoList;
    GLSingleTimerActionType  action = GLSingleTimerActionTypeInsert;
    
    if (self.timerSimpleInfo != nil) {
          action = GLSingleTimerActionTypeUpdate;
    }
    __weak typeof(self) weakSelf = self;
    [TopGLSmartPiAPIManager.shareManager setActionTimerInfoWithMd5:self.mainDeviceInfo.md5 action:action timeInfo:self.timeInfo complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
           [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
            [weakSelf.navigationController popViewControllerAnimated:true];
        }else if (resucltInfo.state == GLStateTypeFullError){

            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
        }
    }];
}



- (NSMutableArray *)cellTypeList {
    if (_cellTypeList == nil) {
        _cellTypeList = [NSMutableArray array];
        [_cellTypeList addObject:@(TopTimeDetialVCCellTypeName)];
        [_cellTypeList addObject:@(TopTimeDetialVCCellTypeTime)];
        [_cellTypeList addObject:@(TopTimeDetialVCCellTypeWeek)];
        [_cellTypeList addObject:@(TopTimeDetialVCCellTypeActionList)];
    }
    return _cellTypeList;
}

- (NSMutableArray *)actionInfoList {
    if (_actionInfoList == nil) {
        _actionInfoList = [NSMutableArray array];
    }
    return _actionInfoList;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSNumber * cellTypeNum = self.cellTypeList[section];
    TopTimeDetialVCCellType cellType = cellTypeNum.integerValue;
    switch (cellType) {
  
        case TopTimeDetialVCCellTypeName:
            return @"";
            break;
        case TopTimeDetialVCCellTypeTime:
            return @"";
            break;
        case TopTimeDetialVCCellTypeWeek:
            return @"";
            break;
        case TopTimeDetialVCCellTypeActionList:
            return NSLocalizedString(@"Perform action", nil);
            break;
    }
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSNumber * cellTypeNum = self.cellTypeList[indexPath.section];
    TopTimeDetialVCCellType cellType = cellTypeNum.integerValue;
    switch (cellType) {
       
        case TopTimeDetialVCCellTypeName:
            cell.textLabel.text = self.timeInfo.name;
            cell.detailTextLabel.text = NSLocalizedString(@"Name（Cannot exceed 24 bytes）", nil);
            break;
        case TopTimeDetialVCCellTypeTime:
            cell.textLabel.text = [self getStringWithMin:self.timeInfo.time];
            cell.detailTextLabel.text = NSLocalizedString(@"Startup time（minutes）", nil);
            break;
        case TopTimeDetialVCCellTypeWeek:
            cell.textLabel.text = [self getStringWithWeek:self.timeInfo.week];
            cell.detailTextLabel.text =NSLocalizedString( @"Repeat（See parameter description）", nil);
            break;
        case TopTimeDetialVCCellTypeActionList:
        {
            if (indexPath.row < self.actionInfoList.count) {
                TopActionInfo * action = self.actionInfoList[indexPath.row];
                NSLog(@"%@", action.value);
                if (action.value != nil && action.value.length == 10) {
                    action.acStateInfo = [action getACStateWithValue:action.value];
                    NSString * penStr = action.acStateInfo.powerState ? NSLocalizedString(@"ON", nil) :  NSLocalizedString(@"OFF", nil);
                

                    NSString * modeStr = NSLocalizedString(@"AUTO", @"");
                    switch (action.acStateInfo.mode) {
                        case 0:
                            modeStr = NSLocalizedString(@"AUTO", @"");
                            break;
                        case 1:
                            modeStr = NSLocalizedString(@"COOL", @"");
                            break;
                        case 2:
                            modeStr = NSLocalizedString(@"DRY", @"");
                            break;
                        case 3:
                            modeStr = NSLocalizedString(@"FAN", @"");
                            break;
                        case 4:
                            modeStr = NSLocalizedString(@"HEAT", @"");
                            break;
                            
                        default:
                            break;
                    }
                    
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"subID:%ld Status：%@ Mode: Speed：%ld Dir：%ld, Temp：%ld",nil), action.subID ,penStr, action.acStateInfo.speed, action.acStateInfo.mode, action.acStateInfo.temperature];
                
                }else {
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"subID:%ld keyID:%ld", nil), action.subID, [action getKeyIndWithValue:action.value]];
                }
                cell.detailTextLabel.text = action.delay == 0 ? NSLocalizedString(@"Execute the action immediately after the last action is executed", @"") : [NSString stringWithFormat:NSLocalizedString(@"Perform the action %d minutes after the last action", @""), action.delay / 60];
                return  cell;
                
            }else {
                UITableViewCell * cell = [[UITableViewCell alloc] init];
                cell.textLabel.text = NSLocalizedString(@"Add", nil);
                return  cell;
            }
        }
            break;
    }
    return cell;
}
- (NSString *)getStringWithMin:(NSInteger)totalMin {
  
    NSInteger hour = totalMin / 60;
    NSInteger min = totalMin % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)hour, (long)min];
}

- (NSString *)getStringWithWeek:(NSInteger)week {
    if (week == 0)
        return NSLocalizedString(@"Once", nil);
    if (week == 31)
        return NSLocalizedString(@"Working Day", nil);
    if (week == 96)
        return NSLocalizedString(@"WeenEnd", nil);
    if (week == 127)
        return NSLocalizedString(@"Evety day", nil);
    
    NSString *string = @"";
    
    if ((week >>0) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"Mon", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>1) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"Tue", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>2) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"Wed", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>3) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"Thu", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>4) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"Fri", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>5) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"Sat", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>6) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"Sun", nil)];
        string = [string stringByAppendingString:@" "];
    }
    
    return string;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSNumber * cellTypeNum = self.cellTypeList[section];
    if (cellTypeNum.integerValue == TopTimeDetialVCCellTypeActionList){
        return  self.actionInfoList.count + 1;
    }
    return  1;
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    NSNumber * cellTypeNum = self.cellTypeList[indexPath.section];
    if (cellTypeNum.integerValue == TopTimeDetialVCCellTypeActionList){
        if (indexPath.row >= self.actionInfoList.count) {
            [self gotoSelectSubDeviceActionVC];
        }
    }
 
}
- (void)gotoSelectSubDeviceActionVC{
    if (self.actionInfoList.count > 16) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Add up to 16 actions", @"")];
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TopSelectSubDeviceActionVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"TopSelectSubDeviceActionVC"];
    vc.mainDeviceInfo = self.mainDeviceInfo;
    vc.delegate = self;
    [self showViewController:vc sender:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellTypeList.count;
}

- (void)selectSubDeviceActionVCSelectAction:(TopActionInfo *)actionInfo {
    [self.actionInfoList addObject:actionInfo];
    [self.tableView reloadData];
}
@end
