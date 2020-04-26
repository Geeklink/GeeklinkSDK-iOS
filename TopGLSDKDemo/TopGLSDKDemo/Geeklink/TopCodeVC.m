//
//  TopCodeVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/4/2.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopCodeVC.h"
#import <GeeklinkSDK/SDK.h>
#import "SVProgressHUD.h"
@interface TopCodeVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray * codeList;
 @property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TopCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // Do any additional setup after loading the view.
}

- (NSMutableArray *)codeList {
    if (_codeList == nil) {
        _codeList = [NSMutableArray array];
    }
    return _codeList;
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = self.codeList[indexPath.row];
    cell.detailTextLabel.text = NSLocalizedString(@"Clicked to send", nil);
    return  cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.codeList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [TopGLAPIManager.shareManager controlSubDeviceWithMd5:self.mainDeviceInfo.md5 andIrCode:self.codeList[indexPath.row] complete:^(TopResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", nil)];
        }else {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", nil)];
        }
    }];
}
- (IBAction)clickedAddBtn:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Hint", nil) message:NSLocalizedString(@"Please point the infrared remote control at the main unit and press the remote control button within 20 seconds.", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [TopGLAPIManager.shareManager getCodeFromDeviceWithMd5:self.mainDeviceInfo.md5 andCodeType:GLKeyStudyTypeKeyStudyCancel complete:^(TopResultInfo * _Nonnull resucltInfo) {
            if (resucltInfo.state == GLStateTypeOk) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Cancel success", nil)];
            }
          }];
    }]];
                        
    [self presentViewController:alertVC animated:true completion:^{
        
    }];
    
    [TopGLAPIManager.shareManager getCodeFromDeviceWithMd5:self.mainDeviceInfo.md5 andCodeType:GLKeyStudyTypeKeyStudyIr complete:^(TopResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            [weakSelf.codeList addObject:resucltInfo.irCode];
            [weakSelf.tableView reloadData];
            
        }
        [alertVC dismissViewControllerAnimated:true completion:^{
            
        }];
     }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertVC dismissViewControllerAnimated:true completion:^{
            
        }];
        
    });
}


@end
