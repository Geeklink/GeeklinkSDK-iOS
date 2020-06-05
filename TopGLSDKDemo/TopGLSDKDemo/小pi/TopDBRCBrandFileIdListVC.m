//
//  TopDBRCBrandFileIdListVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/27.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopDBRCBrandFileIdListVC.h"
#import <GeeklinkSDK/SDK.h>
#import "TopCtrDBRCVC.h"
@interface TopDBRCBrandFileIdListVC ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray * brandFileIdList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TopDBRCBrandFileIdListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    self.title = self.brand.name;
    [[TopGLSmartPiAPIManager shareManager] getDBRCBrandFlieIdWithMd5:self.mainDeviceInfo.md5 databaseType:self.dataBaseDeviceType andBrand:self.brand complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            weakSelf.brandFileIdList = resucltInfo.dbrcBrandFileIdList;
            [weakSelf.tableView reloadData];
        }
    }];
    // Do any additional setup after loading the view.
}
- (NSArray *)brandFileIdList {
    if (_brandFileIdList == nil){
        _brandFileIdList = [NSArray array];
    }
    return _brandFileIdList;
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    TopDBRCBrandFileId * brandFileId = self.brandFileIdList[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",brandFileId.fileID];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.brandFileIdList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TopCtrDBRCVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"TopCtrDBRCVC"];
    vc.mainDeviceInfo = self.mainDeviceInfo;
    TopDBRCBrandFileId * brandFileId = self.brandFileIdList[indexPath.row];
    vc.fileId =  brandFileId.fileID;
    vc.dataBaseDeviceType = self.dataBaseDeviceType;
    [self showViewController:vc sender:nil];
 
}

@end
