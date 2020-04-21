//
//  TopAddDeviceTypeVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/27.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopAddDeviceTypeVC.h"
#import <GeeklinkSDK/SDK.h>
#import "TopDBRCBrandListVC.h"
typedef NS_ENUM(NSInteger, TopAddDeviceTypeVCCellType)
{
    /*码库电视*/
    TopAddDeviceTypeVCCellTypeDBTV,
    /*码库机顶盒*/
    TopAddDeviceTypeVCCellTypeDBSTB,
    /*码库IPTV*/
    TopAddDeviceTypeVCCellTypeDBIPTV,
    /*码库空调*/
    TopAddDeviceTypeVCCellTypeDBAC,
    /*自定义设备*/
    TopAddDeviceTypeVCCellTypeCustom,
    
};
@interface TopAddDeviceTypeVC ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * cellTypeList;
@end

@implementation TopAddDeviceTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.cellTypeList addObject:@(TopAddDeviceTypeVCCellTypeDBTV)];
    [self.cellTypeList addObject:@(TopAddDeviceTypeVCCellTypeDBSTB)];
    [self.cellTypeList addObject:@(TopAddDeviceTypeVCCellTypeDBIPTV)];
    [self.cellTypeList addObject:@(TopAddDeviceTypeVCCellTypeDBAC)];
    [self.cellTypeList addObject:@(TopAddDeviceTypeVCCellTypeCustom)];
  
}
- (NSMutableArray *)cellTypeList {
    if (_cellTypeList == nil) {
        _cellTypeList = [NSMutableArray array];
    }
    return  _cellTypeList;
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSNumber * cellTypeNum = self.cellTypeList[indexPath.section];
    TopAddDeviceTypeVCCellType cellType =   cellTypeNum.integerValue;
    switch (cellType) {
 
        case TopAddDeviceTypeVCCellTypeDBTV:
            cell.textLabel.text = @"码库电视";
            break;
        case TopAddDeviceTypeVCCellTypeDBSTB:
            cell.textLabel.text = @"码库机顶盒";
            break;
        case TopAddDeviceTypeVCCellTypeDBIPTV:
            cell.textLabel.text = @"码库IPTV";
            break;
        case TopAddDeviceTypeVCCellTypeDBAC:
            cell.textLabel.text = @"码库空调";
            break;
        case TopAddDeviceTypeVCCellTypeCustom:
            cell.textLabel.text = @"自定义学习遥控器";
            break;
    }
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  1;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellTypeList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber * cellTypeNum = self.cellTypeList[indexPath.section];
    TopAddDeviceTypeVCCellType cellType =   cellTypeNum.integerValue;
    TopDataBaseDeviceType dataBaseDeviceType = TopDataBaseDeviceAC;
    switch (cellType) {
    
        case TopAddDeviceTypeVCCellTypeDBTV:
            dataBaseDeviceType = TopDataBaseDeviceTV;
            break;
        case TopAddDeviceTypeVCCellTypeDBSTB:
             dataBaseDeviceType = TopDataBaseDeviceSTB;
            break;
        case TopAddDeviceTypeVCCellTypeDBIPTV:
             dataBaseDeviceType = TopDataBaseDeviceIPTV;
            break;
        case TopAddDeviceTypeVCCellTypeDBAC:
             dataBaseDeviceType = TopDataBaseDeviceAC;
            break;
        case TopAddDeviceTypeVCCellTypeCustom: {
            TopSubDevInfo * subDevice = [[TopSubDevInfo alloc] init];
            subDevice.mainType = TopCunstomDevice;
            subDevice.subId = 0;
            subDevice.databaseType = 0;
            subDevice.carrierType = GLCarrierTypeCARRIER38;
            subDevice.fileId = 0;
            [[TopGLAPIManager shareManager]setSubDeviceWithMd5:self.mainDeviceInfo.md5 subDevInfo:subDevice action:GLActionFullTypeInsert complete:^(TopResultInfo * _Nonnull resucltInfo) {
                if (resucltInfo.state == GLStateTypeOk) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            return;
        }
        
            break;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TopDBRCBrandListVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"TopDBRCBrandListVC"];
    vc.mainDeviceInfo = self.mainDeviceInfo;
    vc.dataBaseDeviceType = dataBaseDeviceType;
    [self showViewController:vc sender:nil];
}



@end
