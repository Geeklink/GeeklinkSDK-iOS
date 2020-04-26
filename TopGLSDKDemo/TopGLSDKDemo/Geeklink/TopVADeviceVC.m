//
//  TopVADeviceVC.m
//  Top
//
//  Created by 列树童 on 2017/1/11.
//  Copyright © 2017年 Geeklink. All rights reserved.
//

#import "TopVADeviceVC.h"
#import "TopVADeviceCell.h"
#import "TopVAAckInfo.h"
//#import "TopCommonAddCell.h"
#import "TopVAAddPhoneVC.h"

@interface TopVADeviceVC () {
    BOOL tempAlarmState;
    NSArray *tempPhoneList;
    NSString *tempDelPhone;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end

@implementation TopVADeviceVC

#pragma mark - View Life 视图事件

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"报警管理"];
//    self.icon.image = [self getDevInfoImage80:self.devInfo];
//    self.name.text = self.devInfo.devName;
    
    [self.tableView setTableFooterView:[UIView new]];
}

- (void)viewWillAppear:(BOOL)animated {
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVADevSwitchResp:) name:DATA_USER_VA_DEV_SWITCH_RESP object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVADevPhoneGetResp:) name:DATA_USER_VA_DEV_PHONE_GET_RESP object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVADevPhoneActResp:) name:DATA_USER_VA_DEV_PHONE_ACT_RESP object:nil];
    
    [self getVADevAlarmState];
    [self getVADevPhoneList];

}

- (void)viewWillDisappear:(BOOL)animated {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_USER_VA_DEV_SWITCH_RESP object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_USER_VA_DEV_PHONE_GET_RESP object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_USER_VA_DEV_PHONE_ACT_RESP object:nil];
}

#pragma mark - Local Method

- (void)getVADevAlarmState {
    
//    if ([global.userDataHandle.handle voiceAlarmDevSwitch:YES setAlarm:NO devId:self.devInfo.devId] == 0)
//        [self processTimerStart:3.0];
//    else
//        [GlobarMethod notifyNetworkError];
}

- (void)getVADevPhoneList {
//    if ([global.userDataHandle.handle voiceAlarmDevPhoneGet:self.devInfo.devId] == 0)
//        [self processTimerStart:3.0];
//    else
//        [GlobarMethod notifyNetworkError];
}


- (void)changeVCDevAlarmState {
//    if ([global.userDataHandle.handle voiceAlarmDevSwitch:NO setAlarm:!tempAlarmState devId:self.devInfo.devId] == 0)
//        [self processTimerStart:3.0];
//    else
//        [GlobarMethod notifyNetworkError];
}

- (void)delVCDevBindPhone {
//    uint8_t session[16];
//    NSData *data = [NSData dataWithBytes:session length:16];
//    if ([global.userDataHandle.handle voiceAlarmDevPhoneAction:NO devId:self.devInfo.devId phone:tempDelPhone codeSession:data] == 0)
//        [self processTimerStart:3.0];
//    else
//        [GlobarMethod notifyNetworkError];
}

- (void)alertDelPhoneCon {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:tempDelPhone
//                                message:@"是否删除改手机号"
//                               delegate:self
//                      cancelButtonTitle:@"取消"
//                      otherButtonTitles:@"确定", nil];
//    alertView.tag = 002;
//    [alertView show];
}

//跳转到安防设备列表
- (void)goToSecurityDeviceListVC {
    
    [global updateGlDevList];
//    for (TopGlDevDes *dev in global.glDeviceList) {
//        if (dev.devInfo.devId == self.devInfo.devId) {
//            global.curHost = dev;//设置当前主机
//        }
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_PHONE_ALARM_GOTO_SECYRITY_DEV_LIST" object:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goToAddAlarmPhoneVC {
    TopVAAddPhoneVC *topVAAddPhoneVC = [TopVAAddPhoneVC new];
//    topVAAddPhoneVC.devInfo = self.devInfo;
    [self.navigationController pushViewController:topVAAddPhoneVC animated:YES];
}

#pragma mark - UIAlertView delegate

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    
//    if (alertView.tag == 001) {
//        
//        if (buttonIndex == 1) {
//            [self goToSecurityDeviceListVC];
//        }
//        
//    } else if (alertView.tag == 002) {
//
//        if (buttonIndex == 1) {
//            [self delVCDevBindPhone];
//        }
//        
//    } else if (alertView.tag == 003) {
//        
//        if (buttonIndex == 1) {
//            [self goToAddAlarmPhoneVC];
//        }
//    }
//}

#pragma mark - Data Handle

//- (void)handleVADevSwitchResp:(NSNotification *)notification {
//    [self processTimerStop];
//    TopVAAckInfo *info = [notification object];
//
//    tempAlarmState = info.alarmStatus;
//
//    if (info.isCheck == NO) {
//        if (info.alarmStatus) {
////            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设置成功"
////                                                                message:@"请务必在安防->查看设备中，打开需要报警的安防设备的电话报警开关 ，才能接到报警电话"
////                                                               delegate:self
////                                                      cancelButtonTitle:@"取消"
////                                                      otherButtonTitles:@"去设置", nil];
////            alertView.tag = 001;
////            [alertView show];
//        }
//    }
//
//    [self.tableView reloadData];
//}

//- (void)handleVADevPhoneGetResp:(NSNotification *)notification {
//    [self processTimerStop];
//    TopVAAckInfo *info = [notification object];
//    
//    tempPhoneList = info.phoneList;
//    [self.tableView reloadData];
//}
//
//- (void)handleVADevPhoneActResp:(NSNotification *)notification {
//    [self processTimerStop];
//    TopVAAckInfo *info = [notification object];
//    if (info.status == 0)
//        [self getVADevPhoneList];
//}

#pragma mark - TableView DataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        self.headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 88);
        return self.headerView;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 5)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;

}//自定义section的头部

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0)
        return 88;
    
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0)
        return 1;
    
    return tempPhoneList.count+2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == tempPhoneList.count+1) {
        
//        UINib *nib = [UINib nibWithNibName:@"TopCommonAddCell" bundle:nil];
//        [tableView registerNib:nib forCellReuseIdentifier:@"TopCommonAddCell"];
//        TopCommonAddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopCommonAddCell"];
//
//        [cell.btn setImage:[UIImage imageNamed:@"room_add_dev_add_icon_normal"]];
//        cell.separatorInset = UIEdgeInsetsMake([UIScreen mainScreen].bounds.size.width*2, [UIScreen mainScreen].bounds.size.width*2, 0, 0);//去掉分割线
//
//        return cell;
    }
    
    UINib *nib = [UINib nibWithNibName:@"TopVADeviceCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"TopVADeviceCell"];
    TopVADeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopVADeviceCell"];
    
    if (indexPath.section == 0) {
        cell.lbl.textColor = [UIColor blackColor];
        cell.lbl.text = @"开启报警通知";
        
        if (tempAlarmState) {
            cell.img.image = [UIImage imageNamed:@"scene_switchbutton_on"];
        } else {
            cell.img.image = [UIImage imageNamed:@"scene_switchbutton_off"];
        }
        
    } else {
        
        if (indexPath.row == 0) {
            cell.lbl.textColor = [UIColor blackColor];
            cell.lbl.text = @"接受通知的手机";
            
            cell.img.image = [UIImage imageNamed:@""];
        } else {
            NSString *phone = [tempPhoneList objectAtIndex:indexPath.row-1];
            cell.lbl.text = phone;
        }
    }
    
    return cell;
    
    return [UITableViewCell new];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
//    if (self.devInfo.devAdminFlag != GLDeviceAdminFlagTypeIsMe) {
//        [[[UIAlertView alloc] initWithTitle:@"提示"
//                                    message:@"只有设备管理员用户才能对该设备进行设置，请联系设备管理员用户"
//                                   delegate:nil
//                          cancelButtonTitle:@"我知道了"
//                          otherButtonTitles:nil, nil] show];
//
//        return;
//    }
    
    if (indexPath.section == 0) {
        
        if (tempAlarmState == NO) {
            
            if (tempPhoneList.count == 0) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
//                                            message:@"当前未设置接受报警的手机，请先设置添加一个手机号。"
//                                           delegate:self
//                                  cancelButtonTitle:@"取消"
//                                  otherButtonTitles:@"设置", nil];
//                alertView.tag = 003;
//                [alertView show];
                return;
            }
        }
        
        
//        if (indexPath.row == 1) {
            [self changeVCDevAlarmState];
//        }
    } else {
        
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == tempPhoneList.count + 1) {
            
            [self goToAddAlarmPhoneVC];
            
        } else {
            
            tempDelPhone = [tempPhoneList objectAtIndex:indexPath.row-1];
            [self alertDelPhoneCon];
        }
    }
}

@end
