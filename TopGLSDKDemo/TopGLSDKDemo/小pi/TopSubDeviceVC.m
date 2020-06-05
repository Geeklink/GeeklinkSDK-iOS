//
//  TopSubDeviceVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/27.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopSubDeviceVC.h"

#import "TopAddDeviceTypeVC.h"
#import "TopCustomDevKeyListVC.h"
#import "TopCtrDBRCVC.h"
#import "SVProgressHUD.h"
@interface TopSubDeviceVC ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * subDeviceList;
@end
//说明：子设备数据需要保存到你们的服务器，名称是你们自己来定义
@implementation TopSubDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [[TopGLSmartPiAPIManager shareManager] getSubDeviceListWithMd5:self.mainDeviceInfo.md5 complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
        weakSelf.subDeviceList = resucltInfo.subDevList;
        [weakSelf.tableView reloadData];
    }];
}
- (IBAction)clickAddSubDeviceListBtn:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TopAddDeviceTypeVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"TopAddDeviceTypeVC"];
    vc.mainDeviceInfo = self.mainDeviceInfo;
    [self showViewController:vc sender:nil];
}

- (NSArray *)subDeviceList {
    if (_subDeviceList == nil) {
        _subDeviceList = [NSMutableArray array];
    }
    return  _subDeviceList;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    TopSubDevInfo * subDeviceInfo = self.subDeviceList[indexPath.section];
    NSString * typeName = @"";
    switch (subDeviceInfo.mainType) {
        case GLDeviceMainTypeGeeklinkDev:
            typeName = @"";
            break;
        case GLDeviceMainTypeDatabaseDev:{
            switch (subDeviceInfo.databaseDevType) {
               
                case GLDatabaseDevTypeTV:
                    typeName = NSLocalizedString(@"TV", "");
                    cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", subDeviceInfo.fileId];
                    break;
                case GLDatabaseDevTypeSTB:
                    typeName = NSLocalizedString(@"STB", "");
                    cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", subDeviceInfo.fileId];
                    break;
                case GLDatabaseDevTypeIPTV:
                    typeName = NSLocalizedString(@"IPTV", "");
                    cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", subDeviceInfo.fileId];
                    break;
                case GLDatabaseDevTypeAC:
                      typeName = NSLocalizedString(@"AC", "");
                     cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", subDeviceInfo.fileId];
                    break;
            }
        }
            
        
            break;
        case GLDeviceMainTypeCustomDev:
            typeName = NSLocalizedString(@"Custom", "");
            cell.detailTextLabel.text = [NSString  stringWithFormat:@"%ld keys", subDeviceInfo.keyIdList.count];
            break;

    }
    cell.textLabel.text = [NSString  stringWithFormat:@"%@ subId:%ld", typeName, subDeviceInfo.subId];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.subDeviceList.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (alertVC.popoverPresentationController != nil) {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        alertVC.popoverPresentationController.sourceView = cell;
        alertVC.popoverPresentationController.sourceRect = cell.bounds;
        
    }
   
    
    TopSubDevInfo * subDeviceInfo = self.subDeviceList[indexPath.section];
    UIAlertAction * crtlAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Keys List", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (subDeviceInfo.mainType == GLDeviceMainTypeCustomDev) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TopCustomDevKeyListVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"TopCustomDevKeyListVC"];
            vc.mainDeviceInfo = self.mainDeviceInfo;
            
            vc.subDevInfo =  subDeviceInfo;
            vc.keyIdList = [NSMutableArray arrayWithArray: subDeviceInfo.keyIdList];;
            [self showViewController:vc sender:nil];
        }else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TopCtrDBRCVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"TopCtrDBRCVC"];
            vc.mainDeviceInfo = self.mainDeviceInfo;
        
            vc.subDevInfo = subDeviceInfo;
            [self showViewController:vc sender:nil];
        }
        
    }];
 
    __weak typeof(self) weakSelf  = self;
    UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete",@"") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [TopGLSmartPiAPIManager.shareManager setSubDeviceWithMd5:self.mainDeviceInfo.md5 subDevInfo:subDeviceInfo action:GLActionFullTypeDelete complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk) {
               
                NSMutableArray * mutSubDeviceList = [NSMutableArray arrayWithArray:self.subDeviceList];
                [mutSubDeviceList removeObjectAtIndex:indexPath.row];
                weakSelf.subDeviceList = mutSubDeviceList;
                [weakSelf.tableView reloadData];
               [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
            }else {
                 [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
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



@end
