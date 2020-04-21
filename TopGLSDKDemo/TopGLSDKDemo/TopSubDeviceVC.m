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
    [[TopGLAPIManager shareManager] getSubDeviceListWithMd5:self.mainDeviceInfo.md5 complete:^(TopResultInfo * _Nonnull resucltInfo) {
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
        case TopNetworkDevice:
            typeName = @"";
            break;
        case TopDataBaseDevice:{
            switch (subDeviceInfo.databaseType) {
               
                case TopDataBaseDeviceTV:
                    typeName = @"码库电视";
                    cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", subDeviceInfo.fileId];
                    break;
                case TopDataBaseDeviceSTB:
                    typeName = @"码库机顶盒";
                    cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", subDeviceInfo.fileId];
                    break;
                case TopDataBaseDeviceIPTV:
                    typeName = @"码库IPTV";
                    cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", subDeviceInfo.fileId];
                    break;
                case TopDataBaseDeviceAC:
                      typeName = @"码库空调";
                     cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", subDeviceInfo.fileId];
                    break;
            }
        }
            
        
            break;
        case TopCunstomDevice:
            typeName = @"自定义红外设备";
            cell.detailTextLabel.text = [NSString  stringWithFormat:@"%ld个按键", subDeviceInfo.keyIdList.count];
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
    UIAlertAction * crtlAction = [UIAlertAction actionWithTitle:@"查看按键" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (subDeviceInfo.mainType == TopCunstomDevice) {
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
    UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [TopGLAPIManager.shareManager setSubDeviceWithMd5:self.mainDeviceInfo.md5 subDevInfo:subDeviceInfo action:GLActionFullTypeDelete complete:^(TopResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk) {
                NSLog(@"删除成功");
                NSMutableArray * mutSubDeviceList = [NSMutableArray arrayWithArray:self.subDeviceList];
                [mutSubDeviceList removeObjectAtIndex:indexPath.row];
                weakSelf.subDeviceList = mutSubDeviceList;
                [weakSelf.tableView reloadData];
               
            }
            
        }];
    }];
    [alertVC addAction:crtlAction];
    [alertVC addAction:deleteAction];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertVC animated:true completion:^{
        
    }];
    
   
    

   
  
    
}



@end
