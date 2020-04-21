//
//  TopSelectSubDeviceActionVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/4/1.
//  Copyright © 2020 Geeklink. All rights reserved.
//



#import "TopAddDeviceTypeVC.h"
#import "TopCustomDevKeyListVC.h"
#import "TopSelectSubDeviceActionVC.h"

@interface TopSelectSubDeviceActionVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * subDeviceList;
@end

@implementation TopSelectSubDeviceActionVC
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
                    cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", (long)subDeviceInfo.fileId];
                    break;
                case TopDataBaseDeviceSTB:
                    typeName = @"码库机顶盒";
                    cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", (long)subDeviceInfo.fileId];
                    break;
                case TopDataBaseDeviceIPTV:
                    typeName = @"码库IPTV";
                    cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", (long)subDeviceInfo.fileId];
                    break;
                case TopDataBaseDeviceAC:
                    typeName = @"码库空调";
                    cell.detailTextLabel.text = [NSString  stringWithFormat:@"fileId:%ld", (long)subDeviceInfo.fileId];
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
      TopSubDevInfo * subDeviceInfo = self.subDeviceList[indexPath.section];
    TopActionInfo * actionInfo = [[TopActionInfo alloc] init];
 
    actionInfo.subID = subDeviceInfo.subId;
    //我这里把动作延迟 以秒为单位， 0- 1800s
    actionInfo.delay = 0;
  
    switch (subDeviceInfo.mainType) {
        case TopCunstomDevice:{
            if (subDeviceInfo.keyIdList.count == 0) {
                NSLog(@"该遥控没有按键");
                return;
            }
            //我这里只拿第一个按钮作为动作
            NSNumber * keyIdNumber = subDeviceInfo.keyIdList.firstObject;
            actionInfo.value = [actionInfo getValueWithKeyId: keyIdNumber.integerValue];
            [self popVCWithACtion:actionInfo];

        }
            break;
        case TopDataBaseDevice:{
          
            switch (subDeviceInfo.databaseType) {
             
                case TopDataBaseDeviceTV: {
                    //我这里只拿开关键作为动作，你们可以通过选择方式选择需要的按键
                    actionInfo.value = [actionInfo getValueWithKeyId: TopDBTVKeyTypePOWER];
                    [self popVCWithACtion:actionInfo];
                }
                    
                    break;
                case TopDataBaseDeviceSTB:{
                    //我这里只拿开关键作为动作，你们可以通过选择方式选择需要的按键
                    actionInfo.value = [actionInfo getValueWithKeyId: TopDBSTBKeyTypeSTBWAIT];
                     [self popVCWithACtion:actionInfo];
                    
                }
                   
                    break;
                case TopDataBaseDeviceIPTV:{
                    //我这里只拿开关键作为动作，你们可以通过选择方式选择需要的按键
                    actionInfo.value = [actionInfo getValueWithKeyId: TopDBIPTVKeyTypePOWER];
                    [self popVCWithACtion:actionInfo];
                }
                  
                    break;
                case TopDataBaseDeviceAC:{
                    
                    //我这里只拿空调的一个状态作为动作，你们可以设定自己想要的状态
                    TopACStateInfo * acStateInfo = [[TopACStateInfo alloc] init];
                    acStateInfo.powerState = true;
                    acStateInfo.mode = 1;
                    acStateInfo.temperature = 27;
                    acStateInfo.dir = 0;
                    acStateInfo.speed = 0;
                    actionInfo.acStateInfo = acStateInfo;
                    
                    actionInfo.value =  [actionInfo getACValueWithACState:acStateInfo];
                    actionInfo.acStateInfo = acStateInfo;
                    [self popVCWithACtion:actionInfo];

                }
                    break;
            }
            
        }
            break;
            
        default:
            return;
    }
   
  
    
}
- (void)popVCWithACtion:(TopActionInfo *) actionInfo{
    if ([self.delegate respondsToSelector:@selector(selectSubDeviceActionVCSelectAction:)]) {
        
        [self.delegate selectSubDeviceActionVCSelectAction:actionInfo];
        [self.navigationController popViewControllerAnimated:true];
    }
}
    
    
    

@end
