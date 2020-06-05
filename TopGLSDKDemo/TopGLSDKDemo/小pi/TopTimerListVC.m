//
//  TopTimerListVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/31.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopTimerListVC.h"
#import <GeeklinkSDK/SDK.h>
#import "TopTimeDetialVC.h"
#import "SVProgressHUD.h"
@interface TopTimerListVC () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray * timeList;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TopTimerListVC

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [[TopGLSmartPiAPIManager shareManager] getActionTimerListWithMd5:self.mainDeviceInfo.md5 complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
        if ( resucltInfo.state == GLStateTypeOk) {
            weakSelf.timeList = resucltInfo.timerSimpleArray;
            [weakSelf.tableView reloadData];
        }
    }];
}
- (IBAction)clickedAddBtn:(id)sender {
    [self gotoTopTimeDetialVCWith:nil];
}
- (void)gotoTopTimeDetialVCWith: (TopTimerSimpleInfo *) timerSimpleInfo{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TopTimeDetialVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"TopTimeDetialVC"];
    vc.mainDeviceInfo = self.mainDeviceInfo;
    vc.timerSimpleInfo = timerSimpleInfo;
    [self showViewController:vc sender:nil];
}

- (NSArray *)timeList {
    if (_timeList == nil) {
        _timeList = [NSArray array];
    }
    return _timeList;
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    TopTimerSimpleInfo * simpleInfo = self.timeList[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",simpleInfo.name,[self getStringWithMin:simpleInfo.time]];
    NSString * actionStr = simpleInfo.onOff ? NSLocalizedString(@"(On)", @"") :  NSLocalizedString(@"(Off)", @"");
    cell.detailTextLabel.text =  [NSString stringWithFormat:NSLocalizedString(@"Repeat:%@ %@", @""), [self getStringWithWeek:simpleInfo.week], actionStr];
    return  cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timeList.count;
}

- (void)extracted:(TopTimerSimpleInfo *)timerSimpleInfo weakSelf:(TopTimerListVC *const __weak)weakSelf {
    [TopGLSmartPiAPIManager.shareManager setActionSmartPiTimerSimpleWithMd5:self.mainDeviceInfo.md5 action:GLSingleTimerActionTypeSetOnOff timeSinpleInfo:timerSimpleInfo complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk){
           [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
            
        }else {
            timerSimpleInfo.onOff = !timerSimpleInfo.onOff;
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
        }
        [weakSelf.tableView reloadData];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TopTimerSimpleInfo *  timerSimpleInfo = self.timeList[indexPath.row];
 
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (alertVC.popoverPresentationController != nil) {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        alertVC.popoverPresentationController.sourceView = cell;
        alertVC.popoverPresentationController.sourceRect = cell.bounds;
        
    }
   
    __weak typeof(self) weakSelf  = self;
    UIAlertAction * crtlAction = [UIAlertAction actionWithTitle:timerSimpleInfo.onOff ? NSLocalizedString(@"(Off)", @"") :  NSLocalizedString(@"(On)", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        timerSimpleInfo.onOff = !timerSimpleInfo.onOff;
        [self extracted:timerSimpleInfo weakSelf:weakSelf];
        
    }];
    
    UIAlertAction * editAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Edit", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self gotoTopTimeDetialVCWith:timerSimpleInfo];
        
    }];
    
    
    UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [TopGLSmartPiAPIManager.shareManager setActionSmartPiTimerSimpleWithMd5:self.mainDeviceInfo.md5 action:GLSingleTimerActionTypeDelete timeSinpleInfo:timerSimpleInfo complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk){
                NSMutableArray * mutTimeList = [NSMutableArray arrayWithArray:weakSelf.timeList];
                [mutTimeList removeObjectAtIndex:indexPath.row];
                weakSelf.timeList = mutTimeList;
                
            }
            [weakSelf.tableView reloadData];
        }];
    }];
    
    [alertVC addAction:editAction];
    [alertVC addAction:crtlAction];
    [alertVC addAction:deleteAction];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertVC animated:true completion:^{
        
    }];
}

- (NSString *)getStringWithMin:(NSInteger)totalMin {
 
    NSInteger hour = totalMin / 60;
    NSInteger min = totalMin % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)hour, (long)min];
}

- (NSString *)getStringWithWeek:(int8_t)week {
    if (week == 0)
        return NSLocalizedString(@"Once", nil);
    if (week == 31)
        return NSLocalizedString(@"Working Day", nil);
    if (week == 96)
        return NSLocalizedString(@"Weekend", nil);
    if (week == 127)
        return NSLocalizedString(@"Every Day", nil);
    
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
        string = [string stringByAppendingString:NSLocalizedString(@"Thur", nil)];
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


@end
