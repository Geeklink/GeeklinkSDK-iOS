//
//  TopDisinfectionLampTimerVC.m
//  Geeklink
//
//  Created by 杨飞飞 on 2020/5/19.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopDisinfectionLampTimerVC.h"
#import "SVProgressHUD.h"
@interface TopDisinfectionLampTimerVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * timeList;
@property (assign, nonatomic) NSInteger index;
@end

@implementation TopDisinfectionLampTimerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshTimeList];
    
    // Do any additional setup after loading the view.
}
- (void)refreshTimeList {
    __weak typeof(self) weakSelf = self;
    [[TopGLDisinfectionLampAPIManager shareManager] getDisinfectionLampTimerInfoList:self.mainDeviceInfo.md5 complete:^(TopGLDisinfectionLampResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            [weakSelf.timeList removeAllObjects];
            [weakSelf.timeList addObjectsFromArray: resucltInfo.disinfectionTimerList];
            [weakSelf.tableView reloadData];
        }
    }];
    
}
- (NSMutableArray *)timeList {
    if (_timeList == nil) {
        _timeList = [NSMutableArray array];
    }
    return _timeList;
}
- (IBAction)clickedAddBtn:(id)sender {
    TopGLDisinfectionTimerInfo * timeInfo =  [[TopGLDisinfectionTimerInfo alloc] init];
    timeInfo.timerId = 0;
    timeInfo.name = NSLocalizedString(@"Timer Name", @"");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    NSString *time = [formatter stringFromDate:[NSDate date]];
    NSArray * timeStr = [time componentsSeparatedByString:@" "];
    NSString * hourMinStr = timeStr[1];
    NSArray * hour_minStr = [hourMinStr componentsSeparatedByString:@":"];
    NSString * hourStr = hour_minStr[0];
    NSString * minStr = hour_minStr[1];
    int hour = [hourStr intValue];
    int min = [minStr intValue];
    timeInfo.startTime = hour * 60 + min + 1;
    if (self.index % 3 == 0) {
          timeInfo.week = 0;
    }else  if(self.index % 3 == 1){
        timeInfo.week = 0x13;
    }if(self.index % 2 == 2){
        timeInfo.week = 0x11;
    }
    self.index += 1;
   
  
    timeInfo.onOff = true;
    timeInfo.disinfectionTime = 15;
     __weak typeof(self) weakSelf = self;
    [[TopGLDisinfectionLampAPIManager shareManager] setDisinfectionLampTimerInfo:self.mainDeviceInfo.md5 actionFullType:GLActionFullTypeInsert disinfectionLampTimerInfo:timeInfo  complete:^(TopGLDisinfectionLampResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            [weakSelf refreshTimeList];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
            
        }else  if (resucltInfo.state == GLStateTypeFullError) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Full Error", @"")];
        }
        else {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
        }
    }];
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    TopGLDisinfectionTimerInfo * timeInfo = self.timeList[indexPath.section];

    NSString * timeStr = [self getStringWithMin:timeInfo.startTime];
    NSString * onOffStr = timeInfo.onOff ? NSLocalizedString(@"ON", @"") : NSLocalizedString(@"OFF", @"");
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@: %d    %@",timeStr, NSLocalizedString(@"Disinfection duration", @""),timeInfo.disinfectionTime, onOffStr];
    cell.detailTextLabel.text = [self getStringWithWeek:timeInfo.week];
    return cell;
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

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.timeList count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    TopGLDisinfectionTimerInfo * timeInfo =  self.timeList[indexPath.section];
    
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (alertVC.popoverPresentationController != nil) {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        alertVC.popoverPresentationController.sourceView = cell;
        alertVC.popoverPresentationController.sourceRect = cell.bounds;
        
    }
    
     __weak typeof(self) weakSelf = self;
    UIAlertAction * updateAcion = [UIAlertAction actionWithTitle:NSLocalizedString(@"Update", "") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        timeInfo.name = NSLocalizedString(@"Timer Name", @"");
        timeInfo.startTime = rand() % 1440;
        timeInfo.week = rand() % 0x80;
        timeInfo.disinfectionTime = rand() % 120;
       
        [[TopGLDisinfectionLampAPIManager shareManager] setDisinfectionLampTimerInfo:self.mainDeviceInfo.md5 actionFullType:GLActionFullTypeUpdate disinfectionLampTimerInfo:timeInfo  complete:^(TopGLDisinfectionLampResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk) {
                [weakSelf refreshTimeList];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
                
            } else {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
            }
            
        }];
       
    }];
    [alertVC addAction:updateAcion];
    UIAlertAction * deleteAcion = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", "") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[TopGLDisinfectionLampAPIManager shareManager] setDisinfectionLampTimerInfo:self.mainDeviceInfo.md5 actionFullType:GLActionFullTypeDelete disinfectionLampTimerInfo:timeInfo  complete:^(TopGLDisinfectionLampResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk) {
                [weakSelf refreshTimeList];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
                
            } else {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
            }
            
        }];
        
    }];
    [alertVC addAction:deleteAcion];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertVC animated:true completion:^{
        
    }];
  
}


@end
