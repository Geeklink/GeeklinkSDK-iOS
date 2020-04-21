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
    [[TopGLAPIManager shareManager] getActionTimerListWithMd5:self.mainDeviceInfo.md5 complete:^(TopResultInfo * _Nonnull resucltInfo) {
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
    NSString * actionStr = simpleInfo.onOff ? @"(开)" : @"(关)";
    cell.detailTextLabel.text =  [NSString stringWithFormat:@"重复:%@ %@", [self getStringWithWeek:simpleInfo.week], actionStr];
    return  cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timeList.count;
}

- (void)extracted:(TopTimerSimpleInfo *)timerSimpleInfo weakSelf:(TopTimerListVC *const __weak)weakSelf {
    [TopGLAPIManager.shareManager setActionSmartPiTimerSimpleWithMd5:self.mainDeviceInfo.md5 action:GLSingleTimerActionTypeSetOnOff timeSinpleInfo:timerSimpleInfo complete:^(TopResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk){
            NSLog(@"操作成功");
            
        }else {
            timerSimpleInfo.onOff = !timerSimpleInfo.onOff;
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
    UIAlertAction * crtlAction = [UIAlertAction actionWithTitle:timerSimpleInfo.onOff ? @"(关)" : @"(开)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        timerSimpleInfo.onOff = !timerSimpleInfo.onOff;
        [self extracted:timerSimpleInfo weakSelf:weakSelf];
        
    }];
    
    UIAlertAction * editAction = [UIAlertAction actionWithTitle:@"编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self gotoTopTimeDetialVCWith:timerSimpleInfo];
        
    }];
    
    
    UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [TopGLAPIManager.shareManager setActionSmartPiTimerSimpleWithMd5:self.mainDeviceInfo.md5 action:GLSingleTimerActionTypeDelete timeSinpleInfo:timerSimpleInfo complete:^(TopResultInfo * _Nonnull resucltInfo) {
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
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
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
        return NSLocalizedString(@"一次", nil);
    if (week == 31)
        return NSLocalizedString(@"工作日", nil);
    if (week == 96)
        return NSLocalizedString(@"周末", nil);
    if (week == 127)
        return NSLocalizedString(@"每天", nil);
    
    NSString *string = @"";
    
    if ((week >>0) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"-", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>1) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"二", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>2) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"三", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>3) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"四", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>4) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"五", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>5) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"六", nil)];
        string = [string stringByAppendingString:@" "];
    }
    if ((week >>6) & 0x01) {
        string = [string stringByAppendingString:NSLocalizedString(@"日", nil)];
        string = [string stringByAppendingString:@" "];
    }
    
    return string;
}


@end
