//
//  TopCustomDevKeyListVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/30.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopCustomDevKeyListVC.h"

#import <GeeklinkSDK/SDK.h>
@interface TopCustomDevKeyListVC ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TopCustomDevKeyListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)clickedAddBtn:(id)sender {
    [self addOrUptateKey:true andKeyID:0];
   
}
- (void)addOrUptateKey:(BOOL)isAdd andKeyID:(NSInteger)keyid {
    __weak typeof(self) weakSelf = self;
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在20秒内将红外遥控器对准主机并且按下遥控器按键。" preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [TopGLAPIManager.shareManager cancelSetKeyWithMd5:self.mainDeviceInfo.md5 complete:^(TopResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk) {
                NSLog(@"取消成功");
            }
        }];
    }]];
    [self presentViewController:alertVC animated:true completion:^{
        
    }];
    
    [TopGLAPIManager.shareManager setSubDeviceKeyWithMd5:self.mainDeviceInfo.md5 action:isAdd ? GLActionFullTypeInsert : GLActionFullTypeUpdate subDeviceId:self.subDevInfo.subId keyId:keyid complete:^(TopResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {

            if (isAdd) {
                NSLog(@"OK");
                [weakSelf.keyIdList addObject:@(resucltInfo.keyId)];
                [weakSelf.tableView reloadData];
            }
          
        }
        [alertVC dismissViewControllerAnimated:true completion:^{
            
        }];
    }];
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertVC dismissViewControllerAnimated:true completion:^{
            
        }];
        
    });
}
- (NSMutableArray *)keyIdList {
    if (_keyIdList == nil) {
        _keyIdList = [NSMutableArray array];
    }
    return _keyIdList;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSNumber * keyNum = self.keyIdList[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",keyNum];
    return  cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.keyIdList.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (alertVC.popoverPresentationController != nil) {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        alertVC.popoverPresentationController.sourceView = cell;
        alertVC.popoverPresentationController.sourceRect = cell.bounds;
        
    }
    NSNumber * keyNum = self.keyIdList[indexPath.row];
    
    __weak typeof(self) weakSelf  = self;
    UIAlertAction * crtlAction = [UIAlertAction actionWithTitle:@"控制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [TopGLAPIManager.shareManager controlSubDeviceKeyWithMd5:self.mainDeviceInfo.md5 subDevInfo:self.subDevInfo acStateInfo:[[TopACStateInfo alloc] init] keyId:keyNum.intValue complete:^(TopResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk) {
                NSLog(@"控制成功");
            }
        }];
       
        
    }];
    
    UIAlertAction * updateAction = [UIAlertAction actionWithTitle:@"更新按键" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self addOrUptateKey:false andKeyID:keyNum.integerValue];
        
        
    }];
    
    
    UIAlertAction * deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [TopGLAPIManager.shareManager setSubDeviceKeyWithMd5:self.mainDeviceInfo.md5 action:GLActionFullTypeDelete subDeviceId:self.subDevInfo.subId keyId:keyNum.intValue complete:^(TopResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk) {
                [weakSelf.keyIdList removeObjectAtIndex:indexPath.row];
                [weakSelf.tableView reloadData];
            }
        }];
    }];
    [alertVC addAction:crtlAction];
     [alertVC addAction:updateAction];
    [alertVC addAction:deleteAction];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertVC animated:true completion:^{
        
    }];
    
    
}

@end
