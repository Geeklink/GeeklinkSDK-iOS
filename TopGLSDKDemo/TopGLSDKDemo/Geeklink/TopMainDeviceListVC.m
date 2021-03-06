//
//  TopMainDeviceListVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/26.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopMainDeviceListVC.h"
#import "TopMainDeviceInfoVC.h"
#import "SVProgressHUD/SVProgressHUD.h"
@interface TopMainDeviceListVC ()<UITableViewDelegate, UITableViewDataSource, TopGLAPIManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TopMainDeviceListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView reloadData];
    [TopGLAPIManager shareManager].delegate = self;
}

- (NSMutableArray *)mainDeviceList {
    if (_mainDeviceList == nil) {
        _mainDeviceList = [NSMutableArray array];
    }
    return _mainDeviceList;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    TopMainDeviceInfo * deviceInfo = self.mainDeviceList[indexPath.row];
    cell.textLabel.text = deviceInfo.md5;
    [[TopGLAPIManager shareManager] getDeviceStateInfo: deviceInfo.md5 complete:^(TopResultInfo * _Nonnull resucltInfo) {
        switch (resucltInfo.mainDevStateInfo.state) {
          
            case GLDevConnectStateOffline:
                cell.detailTextLabel.text = NSLocalizedString(@"Offline", @"");
                break;
            case GLDevConnectStateLocal:
                cell.detailTextLabel.text =  NSLocalizedString(@"Local online", @"");
                break;
            case GLDevConnectStateRemote:
                cell.detailTextLabel.text = NSLocalizedString(@"Remote online", @"");
                break;
            case GLDevConnectStateNeedBindAgain:
                cell.detailTextLabel.text = NSLocalizedString(@"", @"");
                break;
//            case GLDevConnectStateCount:
//                break;
        }
    }];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return self.mainDeviceList.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    TopMainDeviceInfo * mainDeivce = self.mainDeviceList[indexPath.row];
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (alertVC.popoverPresentationController != nil) {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        alertVC.popoverPresentationController.sourceView = cell;
        alertVC.popoverPresentationController.sourceRect = cell.bounds;
        
    }
    
    
 
    UIAlertAction * crtlAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"View Device", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
      
        [self gotoTopMainDeviceListVC:mainDeivce];
        
    }];
    
    __weak typeof(self) weakSelf  = self;
    UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete",@"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [TopGLAPIManager.shareManager deleteMainDevice:mainDeivce.md5 complete:^(TopResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
            
                [weakSelf.mainDeviceList removeObject:mainDeivce];
            
                [weakSelf.tableView reloadData];
                
                // 我这里只是暂时将数据保存到本地
                if ([[NSUserDefaults standardUserDefaults] objectForKey: @"deviceSaveKey"] != nil) {
                    NSArray * deviceDictList = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceSaveKey"];
                    NSMutableArray * mutDeviceDictList = [NSMutableArray array];
                    for (NSDictionary * deviceDict in deviceDictList) {
                        NSString * str = deviceDict[@"md5"];
                        if ([str isEqualToString:resucltInfo.md5] == false) {
                            [mutDeviceDictList addObject: deviceDict];
                        }
                        
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:mutDeviceDictList forKey:@"deviceSaveKey"];
                }
               
             
               
                
            }else {
                 [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failure", @"")];
            }
        }];
        
        
    }];
    [alertVC addAction:crtlAction];
    [alertVC addAction:deleteAction];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
     [self presentViewController:alertVC animated:true completion:^{
        
    }];
                    

    
    
}
- (void)gotoTopMainDeviceListVC: (TopMainDeviceInfo *)deviceInfo {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TopMainDeviceInfoVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"TopMainDeviceInfoVC"];
    vc.mainDeviceInfo = deviceInfo;
    [self showViewController:vc sender:nil];
}

- (void)deviceStateChange:(TopResultInfo *)resultInfo {
    if (resultInfo.subId == 0){//是主机状态变化
        [self.tableView reloadData];
        
    }
}
@end
