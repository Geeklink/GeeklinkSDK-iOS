//
//  TopDBRCBrandTypeVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/27.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopDBRCBrandListVC.h"
#import <GeeklinkSDK/SDK.h>
#import "TopDBRCBrandFileIdListVC.h"
@interface TopDBRCBrandListVC ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray * brandList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TopDBRCBrandListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    [[TopGLSmartPiAPIManager shareManager] getDBRCBrandWithMd5:self.mainDeviceInfo.md5 databaseType:self.dataBaseDeviceType complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            weakSelf.brandList = resucltInfo.dbrcBrandList;
            [weakSelf.tableView reloadData];;
        }
    }];
    
    // Do any additional setup after loading the view.
}
- (NSArray *)brandList {
    if (_brandList == nil) {
        _brandList = [NSArray array];
    }
    return _brandList;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
     UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    TopDBRCBrand * brand = self.brandList[indexPath.row];
    cell.textLabel.text = brand.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return  cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.brandList.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TopDBRCBrandFileIdListVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"TopDBRCBrandFileIdListVC"];
    vc.mainDeviceInfo = self.mainDeviceInfo;
    vc.brand = self.brandList[indexPath.row];
    vc.dataBaseDeviceType = self.dataBaseDeviceType;
    [self showViewController:vc sender:nil];
}


@end
