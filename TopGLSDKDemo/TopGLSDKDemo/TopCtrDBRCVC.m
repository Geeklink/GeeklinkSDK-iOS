//
//  TopCtrDBRCVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/30.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopCtrDBRCVC.h"

#import "TopSubDeviceVC.h"
//有部分遥控没有一部分按键，可以参考我们的app遥控界面进行开发。
@interface TopCtrDBRCVC ()<UITableViewDelegate, UITableViewDataSource, TopGLAPIManagerDelegate>
@property (nonatomic, strong) NSMutableArray * keyInfoList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

@property (strong, nonatomic) TopACStateInfo * acStateInfo;
@end

@implementation TopCtrDBRCVC

- (void)viewDidLoad {             
    [super viewDidLoad];
    if (self.subDevInfo != nil) {
        self.fileId = self.subDevInfo.fileId;
      
        self.dataBaseDeviceType = self.subDevInfo.databaseType;

        self.navigationItem.rightBarButtonItem = nil;
    }
 
   
    
    TopGLAPIManager.shareManager.delegate = self;
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initKeyInfoListWithDatabaseDeviceType:self.dataBaseDeviceType];
}
- (IBAction)clickedSaveBtn:(id)sender {
    TopSubDevInfo * subInfo = [[TopSubDevInfo alloc] init];
    subInfo.subId = 0;
    subInfo.fileId = self.fileId;
    subInfo.mainType = TopDataBaseDevice;
 
    subInfo.databaseType = self.dataBaseDeviceType;
    if (subInfo.databaseType == TopDataBaseDeviceAC) {
        subInfo.stateValue =  [subInfo getStateValueWithACState:self.acStateInfo];
    }
    subInfo.carrierType = GLCarrierTypeCARRIER38;
    [[TopGLAPIManager shareManager] setSubDeviceWithMd5:self.mainDeviceInfo.md5 subDevInfo:subInfo action:GLActionFullTypeInsert complete:^(TopResultInfo * _Nonnull resucltInfo) {
        if (resucltInfo.state == GLStateTypeOk) {
            for (UIViewController * vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:TopSubDeviceVC.class]) {
                    [self.navigationController popToViewController:vc animated:true];
                    break;
                }
            }
        }
    }];
}

- (void)initKeyInfoListWithDatabaseDeviceType: (TopDataBaseDeviceType)deviceType {
    __weak typeof(self) weakSelf = self;
    switch (deviceType) {
       
        case TopDataBaseDeviceTV:{
            [TopGLAPIManager.shareManager getDBKeyListWithMd5:self.mainDeviceInfo.md5 databaseType:deviceType fildId:self.fileId complete:^(TopResultInfo * _Nonnull resucltInfo) {
                if (resucltInfo.state == GLStateTypeOk) {
                    [weakSelf initTVKeyInfoList:resucltInfo.keyList];
                    [weakSelf.tableView reloadData];
                }
                  
            }];
        }
            break;
        case TopDataBaseDeviceSTB:{
            [TopGLAPIManager.shareManager getDBKeyListWithMd5:self.mainDeviceInfo.md5 databaseType:deviceType fildId:self.fileId complete:^(TopResultInfo * _Nonnull resucltInfo) {
                 if (resucltInfo.state == GLStateTypeOk) {
                     [weakSelf initSTBKeyInfoList:resucltInfo.keyList];
                    [weakSelf.tableView reloadData];
                 }
                                       
            }];
                    
        }
           
            break;
        case TopDataBaseDeviceIPTV:{
            [TopGLAPIManager.shareManager getDBKeyListWithMd5:self.mainDeviceInfo.md5 databaseType:deviceType fildId:self.fileId complete:^(TopResultInfo * _Nonnull resucltInfo) {
                if (resucltInfo.state == GLStateTypeOk) {
                    [weakSelf initIPTVKeyInfoList:resucltInfo.keyList];
                    [weakSelf.tableView reloadData];
                }
                
                                                                
            }];
                              
        }
          

            break;
        case TopDataBaseDeviceAC:{
            [self initACKeyInfoList];
            if (self.subDevInfo != nil) {
                self.acStateInfo = [self.subDevInfo getACStateInfoWithStateValue:self.subDevInfo.stateValue];
            }else {
                self.acStateInfo = [[TopACStateInfo alloc]init];
                self.acStateInfo.powerState = true;
                self.acStateInfo.temperature = 27;
                self.acStateInfo.dir = 0;
                self.acStateInfo.speed = 0;
                self.acStateInfo.mode = 1;
                
            }
            [self.tableView reloadData];
        }
          
            break;
    }
}

-  (void)initACKeyInfoList {
    
    TopDBRCKeyInfo * powerKeyInfo = [[TopDBRCKeyInfo alloc] init];
    powerKeyInfo.name = @"开关";
    powerKeyInfo.key = TopDBACKeyTypePower;
    [self.keyInfoList addObject:powerKeyInfo];
    
    TopDBRCKeyInfo * modeKeyInfo = [[TopDBRCKeyInfo alloc] init];
    modeKeyInfo.name = @"模式";
    modeKeyInfo.key = TopDBACKeyTypeMode;
    [self.keyInfoList addObject:modeKeyInfo];
    
    TopDBRCKeyInfo * dirKeyInfo = [[TopDBRCKeyInfo alloc] init];
    dirKeyInfo.name = @"风向";
    dirKeyInfo.key = TopDBACKeyTypeDir;
    [self.keyInfoList addObject:dirKeyInfo];
    
    TopDBRCKeyInfo * speedKeyInfo = [[TopDBRCKeyInfo alloc] init];
    speedKeyInfo.name = @"风速";
    speedKeyInfo.key = TopDBACKeyTypeSpeed;
    [self.keyInfoList addObject:speedKeyInfo];
    
    TopDBRCKeyInfo * tempUpKeyInfo = [[TopDBRCKeyInfo alloc] init];
    tempUpKeyInfo.name = @"温度+";
    tempUpKeyInfo.key = TopDBACKeyTypeTemp;
    [self.keyInfoList addObject:tempUpKeyInfo];
    
    
    TopDBRCKeyInfo * tempDownKeyInfo = [[TopDBRCKeyInfo alloc] init];
    tempDownKeyInfo.name = @"温度-";
    tempDownKeyInfo.key = TopDBACKeyTypeTemp;
    [self.keyInfoList addObject:tempDownKeyInfo];
    
    
    
}

-  (void)initIPTVKeyInfoList: (NSArray *)keyList {
    NSMutableArray * newkeyList = [NSMutableArray array];
    for (NSInteger index = 0; index < keyList.count; index ++) {
        NSNumber * keyNum = keyList[index];
        NSString * name = @"";
        TopDBIPTVKeyType keyType = keyNum.integerValue;
        switch (keyType) {
                
            case TopDBIPTVKeyTypePOWER:
                name = @"电源";
                break;
            case TopDBIPTVKeyTypeUP:
                name = @"上";
                break;
            case TopDBIPTVKeyTypeDOWN:
                name = @"下";
                break;
            case TopDBIPTVKeyTypeLEFT:
                name = @"左";
                break;
            case TopDBIPTVKeyTypeRIGHT:
                name = @"右";
                break;
            case TopDBIPTVKeyTypeOK:
                name = @"OK";
                break;
            case TopDBIPTVKeyTypeMENU:
                name = @"菜单";
                break;
            case TopDBIPTVKeyTypeHOME:
                name = @"首页";
                break;
            case TopDBIPTVKeyTypeBACK:
                name = @"返回";
                break;
            case TopDBIPTVKeyTypeVOLPLUSE:
                name = @"音量+";
                break;
            case TopDBIPTVKeyTypeVOLMINUS:
                name = @"音量-";
                break;
            case TopDBIPTVKeyTypeSTEEING:
                name = @"设置";
                break;
            case TopDBIPTVKeyTypeCount:
                name = @"";
                break;
        }
        if (name.length > 0) {
            TopDBRCKeyInfo * keyInfo = [[TopDBRCKeyInfo alloc] init];
            keyInfo.name = name;
            keyInfo.key = keyType;
            [newkeyList addObject:keyInfo];
        }
        
    }
    self.keyInfoList = newkeyList;
  
}
-  (void)initSTBKeyInfoList: (NSArray *)keyList {
    NSMutableArray * newkeyList = [NSMutableArray array];
    for (NSInteger index = 0; index < keyList.count; index ++) {
        NSNumber * keyNum = keyList[index];
        NSString * name = @"";
        TopDBSTBKeyType keyType = keyNum.integerValue;
        switch (keyType) {
            case TopDBSTBKeyTypeSTB1:
                name = @"1";
                break;
            case TopDBSTBKeyTypeSTB2:
                name = @"2";
                break;
            case TopDBSTBKeyTypeSTB3:
                name = @"3";
                break;
            case TopDBSTBKeyTypeSTB4:
                name = @"4";
                break;
            case TopDBSTBKeyTypeSTB5:
                name = @"5";
                break;
            case TopDBSTBKeyTypeSTB6:
                name = @"6";
                break;
            case TopDBSTBKeyTypeSTB7:
                name = @"7";
                break;
            case TopDBSTBKeyTypeSTB8:
                name = @"8";
                break;
            case TopDBSTBKeyTypeSTB9:
                name = @"9";
                break;
            case TopDBSTBKeyTypeSTB0:
                name = @"0";
                break;
            case TopDBSTBKeyTypeSTBLIST:
                name = @"列表";
                break;
            case TopDBSTBKeyTypeSTBLAST:
                name = @"应用";
                break;
            case TopDBSTBKeyTypeSTBWAIT:
                name = @"电源";
                break;
            case TopDBSTBKeyTypeSTBCHPLUS:
                name = @"频道+";
                break;
            case TopDBSTBKeyTypeSTBCHMINUS:
                name = @"频道-";
                break;
            case TopDBSTBKeyTypeSTBSOUNDPLUS:
                name = @"音量+";
                break;
            case TopDBSTBKeyTypeSTBSOUNDMINUS:
                name = @"音量-";
                break;
            case TopDBSTBKeyTypeSTBUP:
                name = @"上";
                break;
            case TopDBSTBKeyTypeSTBDOWN:
                name = @"下";
                break;
            case TopDBSTBKeyTypeSTBLEFT:
                name = @"左";
                break;
            case TopDBSTBKeyTypeSTBRIGHT:
                name = @"右";
                break;
            case TopDBSTBKeyTypeSTBOK:
                name = @"确认";
                break;
            case TopDBSTBKeyTypeSTBEXIT:
                name = @"EXIT";
                break;
            case TopDBSTBKeyTypeSTBMENU:
                name = @"菜单";
                break;
            case TopDBSTBKeyTypeSTBRED:
                name = @"红";
                break;
            case TopDBSTBKeyTypeSTBGREEN:
                name = @"绿";
                break;
            case TopDBSTBKeyTypeSTBYELLOW:
                name = @"黄";
                break;
            case TopDBSTBKeyTypeSTBBLUE:
                name = @"蓝";
                break;
            case TopDBSTBKeyTypeSTBRETURN:
                name = @"返回";
                break;
            case TopDBSTBKeyTypeSTBUPPAGE:
                name = @"上页";
                break;
            case TopDBSTBKeyTypeSTBDOWNPAGE:
                name = @"下页";
                break;
            case TopDBSTBKeyTypeSTBSOUND:
                name = @"声音";
                break;
            case TopDBSTBKeyTypeSTBMESSAGE:
                name = @"信息";
                break;
            case TopDBSTBKeyTypeSTBMUTE:
                name = @"静音";
                break;
            case TopDBSTBKeyTypeSTBLOVE:
                name = @"喜爱";
                break;
            case TopDBSTBKeyTypeSTBGUIDES:
                name = @"导视";
                break;
            case TopDBSTBKeyTypeSTBTV:
                name = @"电视";
                break;
            case TopDBSTBKeyTypeSTBBROADCAST:
                name = @"广播";
                break;
            case TopDBSTBKeyTypeSTBNEWS:
                name = @"资讯";
                break;
            case TopDBSTBKeyTypeSTBSTOCK:
                name = @"股票";
                break;
            case TopDBSTBKeyTypeSTBDEMAND:
                name = @"点播";
                break;
            case TopDBSTBKeyTypeSTBMAIL:
                name = @"邮件";
                break;
            case TopDBSTBKeyTypeSTBGAMES:
                name = @"游戏";
                break;
            case TopDBSTBKeyTypeSTBLIST2:
                name = @"列表2";
                break;
            case TopDBSTBKeyTypeSTBLAST2:
                name = @"应用2";
                break;
            case TopDBSTBKeyTypeSTBSET:
                name = @"设置";
                break;
            case TopDBSTBKeyTypeSTBMAINPAGE:
                name = @"主页";
                break;
            case TopDBSTBKeyTypeSTBRECORD:
                name = @"录制";
                break;
            case TopDBSTBKeyTypeSTBSTOPRECORD:
                name = @"停止";
                break;
            case TopDBSTBKeyTypeSTBA:
                name = @"A";
                break;
            case TopDBSTBKeyTypeSTBB:
                name = @"B";
                break;
            case TopDBSTBKeyTypeSTBC:
                name = @"C";
                break;
            case TopDBSTBKeyTypeSTBD:
                name = @"D";
                break;
            case TopDBSTBKeyTypeSTBE:
                name = @"E";
                break;
            case TopDBSTBKeyTypeSTBF:name = @"F";
                name = @"";
                break;
            case TopDBSTBKeyTypeSTBREWIND:
                name = @"快退";
                break;
            case TopDBSTBKeyTypeSTBFAST:
                name = @"快进";
                break;
            case TopDBSTBKeyTypeSTBPLAY:
                name = @"播放\\/暂停";
                break;
            case TopDBSTBKeyTypeSTBKEEP1:
                name = @"收藏1";
                break;
            case TopDBSTBKeyTypeSTBKEEP2:
                name = @"收藏2";
                break;
            case TopDBSTBKeyTypeSTBKEEP3:
                name = @"收藏2";
                break;
            case TopDBSTBKeyTypeSTBKEEP4:
                name = @"收藏3";
                break;
            case TopDBSTBKeyTypeSTBKEEP5:
                name = @"收藏4";
                break;
            case TopDBSTBKeyTypeSTBKEEP6:
                name = @"收藏5";
                break;
            case TopDBSTBKeyTypeCount:
                name = @"";
                break;
        }
        if (name.length > 0) {
            TopDBRCKeyInfo * keyInfo = [[TopDBRCKeyInfo alloc] init];
            keyInfo.name = name;
            keyInfo.key = keyType;
            [newkeyList addObject:keyInfo];
        }
    }
    self.keyInfoList = newkeyList;
            
        

}


-  (void)initTVKeyInfoList: (NSArray *)keyList {
    NSMutableArray * newkeyList = [NSMutableArray array];
    for (NSInteger index = 0; index < keyList.count; index ++) {
        NSNumber * keyNum = keyList[index];
        NSString * name = @"";
        TopDBTVKeyType keyType = keyNum.integerValue;
        switch (keyType) {
            case TopDBTVKeyTypePOWER:
                name = @"电源";
                break;
            case TopDBTVKeyTypeLIYIN:
                name = @"丽音";
                break;
            case TopDBTVKeyTypeBANYIN:
                name = @"伴音";
                break;
            case TopDBTVKeyTypeZHISHI:
                name = @"制式";
                break;
            case TopDBTVKeyTypeSLEEP:
                name = @"睡眠";
                break;
            case TopDBTVKeyType1:
                name = @"1";
                break;
            case TopDBTVKeyType2:
                name = @"2";
                break;
            case TopDBTVKeyType3:
                name = @"3";
                break;
            case TopDBTVKeyType4:
                name = @"4";
                break;
            case TopDBTVKeyType5:
                name = @"5";
                break;
            case TopDBTVKeyType6:
                name = @"6";
                break;
            case TopDBTVKeyType7:
                name = @"7";
                break;
            case TopDBTVKeyType8:
                name = @"8";
                break;
            case TopDBTVKeyType9:
                name = @"9";
                break;
            case TopDBTVKeyType10:
                name = @"#";
                break;
            case TopDBTVKeyType0:
                name = @"0";
                break;
            case TopDBTVKeyTypeJIAOTI:
                name = @"节目交替";
                break;
            case TopDBTVKeyTypeJIAOHUAN:
                name = @"交换";
                break;
            case TopDBTVKeyTypeHUAZHONGHUA:
                name = @"画中画";
                break;
            case TopDBTVKeyTypeNORMAL:
                name = @"正常";
                break;
            case TopDBTVKeyTypeXUANTAI:
                name = @"屏显";
                break;
            case TopDBTVKeyTypePICTURE:
                name = @"频道-";
                break;
            case TopDBTVKeyTypeCHMINUS1:
                name = @"频道+";
                break;
            case TopDBTVKeyTypeCHPLUS1:
                name = @"频道+";
                break;
            case TopDBTVKeyTypeSOUND:
                name = @"声音";
                break;
            case TopDBTVKeyTypeUP:
                name = @"上";
                break;
            case TopDBTVKeyTypeDOWN:
                name = @"下";
                break;
            case TopDBTVKeyTypeLEFT:
                name = @"左";
                break;
            case TopDBTVKeyTypeRIGHT:
                name = @"右";
                break;
            case TopDBTVKeyTypeMENU:
                name = @"菜单";
                break;
            case TopDBTVKeyTypePINGXIAN:
                name = @"屏显";
                break;
            case TopDBTVKeyTypeAVTV:
                name = @"信号源";
                break;
            case TopDBTVKeyTypeDONE:
                name = @"OK";
                break;
            case TopDBTVKeyTypeSOUNDPLUS:
                name = @"音量+";
                break;
            case TopDBTVKeyTypeSOUNDMINES:
                name = @"音量-";
                break;
            case TopDBTVKeyTypeCHPLUS:
                name = @"频道+";
                break;
            case TopDBTVKeyTypeCHMINUS:
                name = @"频道-";
                break;
            case TopDBTVKeyTypeMUTE:
                name = @"静音";
                break;
            case TopDBTVKeyTypeBACK:
                name = @"返回";
                break;
            case TopDBTVKeyTypeHOME:
                name = @"首页";
                break;
            case TopDBTVKeyTypeCount:
                name = @"正常";
                break;
        }
        if (name.length > 0) {
            TopDBRCKeyInfo * keyInfo = [[TopDBRCKeyInfo alloc] init];
            keyInfo.name = name;
            keyInfo.key = keyType;
            [newkeyList addObject:keyInfo];
        }
  
    }
    self.keyInfoList = newkeyList;
  
}




- (NSMutableArray *)keyInfoList {
    if (_keyInfoList == nil) {
        _keyInfoList = [NSMutableArray array];
    }
    return _keyInfoList;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.dataBaseDeviceType == TopDataBaseDeviceAC){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        /**
         *power;false为关 true为开
         *mode;0自动/1制冷/2除湿/3送风/4制热
         *temp;16-30摄氏度
         *speed;码库空调风速0自动/1低/2中/3高
         *dir;0扫风/风向1/风向2/风向3/风向4
         */
        
        NSString * penStr = self.acStateInfo.powerState ? @"开" : @"关";
        NSString * modeStr = @"自动";
        switch (self.acStateInfo.mode) {
            case 0:
                modeStr = @"自动";
                break;
            case 1:
                modeStr = @"制冷";
                break;
            case 2:
                modeStr = @"除湿";
                break;
            case 3:
                modeStr = @"送风";
                break;
                
            default:
                break;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"状态：%@ 模式:%ld 风速：%ld 风向：%ld, 温度：%ld", penStr, (long)self.acStateInfo.mode, self.acStateInfo.speed, self.acStateInfo.mode, self.acStateInfo.temperature];
        cell.textLabel.numberOfLines = 0;
        return  cell;
    }
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    TopDBRCKeyInfo * keyInfo = self.keyInfoList[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = keyInfo.name;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.dataBaseDeviceType == TopDataBaseDeviceAC){
        return 1;
        
    }
    return self.keyInfoList.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.dataBaseDeviceType == TopDataBaseDeviceAC ? 2 : 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
   
    TopDBRCKeyInfo * keyInfo = self.keyInfoList[indexPath.row];
    if (self.dataBaseDeviceType != TopDataBaseDeviceAC) {
        
        if (self.subDevInfo == nil) {
            
            [TopGLAPIManager.shareManager testDataBaseDeviceWithMd5:self.mainDeviceInfo.md5 databaseType:self.dataBaseDeviceType fildId:self.fileId acStateInfo:nil keyId:keyInfo.key complete:^(TopResultInfo * _Nonnull resucltInfo) {
                if(resucltInfo.state == GLStateTypeOk) {
                    NSLog(@"控制成功");
                }
            }];
        }else {
            
            [TopGLAPIManager.shareManager controlSubDeviceKeyWithMd5:self.mainDeviceInfo.md5 subDevInfo:self.subDevInfo acStateInfo:nil keyId:keyInfo.key complete:^(TopResultInfo * _Nonnull resucltInfo) {
                if(resucltInfo.state == GLStateTypeOk) {
                    NSLog(@"控制成功");
                }
                
            }];
          
        }
    }else {
        TopACStateInfo * newAcStateInfo = [[TopACStateInfo alloc] init];
        newAcStateInfo.powerState = self.acStateInfo.powerState;
        newAcStateInfo.temperature = self.acStateInfo.temperature;
        newAcStateInfo.dir = self.acStateInfo.dir;
        newAcStateInfo.mode = self.acStateInfo.mode;
        newAcStateInfo.speed = self.acStateInfo.speed;
        TopDBACKeyType keyType= keyInfo.key;
        switch (keyType) {
         
            case TopDBACKeyTypePower:
                newAcStateInfo.powerState = !newAcStateInfo.powerState;
                break;
            case TopDBACKeyTypeTemp:
                if ([keyInfo.name isEqualToString:@"温度+"]) {
                    if (newAcStateInfo.temperature >= 30) {
                        NSLog(@"最高30摄氏度");
                        return;
                    }
                    newAcStateInfo.temperature += 1;
                }else {
                    if (newAcStateInfo.temperature <= 16) {
                        NSLog(@"最低16摄氏度");
                        return;
                    }
                    newAcStateInfo.temperature -= 1;
                }
                    
               
                break;
            case TopDBACKeyTypeSpeed:
                newAcStateInfo.speed += 1;
                if (newAcStateInfo.speed >= 4) {
                    newAcStateInfo.speed = 0;
                }
                break;
            case TopDBACKeyTypeDir:
                newAcStateInfo.dir += 1;
                if (newAcStateInfo.dir >= 5) {
                    newAcStateInfo.dir = 0;
                }
                break;
            case TopDBACKeyTypeMode:
                newAcStateInfo.mode += 1;
                if (newAcStateInfo.mode >= 5) {
                    newAcStateInfo.mode = 0;
                }
                break;
            case TopDBACKeyTypecount:
                break;
        }
        __weak typeof(self) weakSelf = self;
        if (self.subDevInfo == nil) {
            
            [TopGLAPIManager.shareManager testDataBaseDeviceWithMd5:self.mainDeviceInfo.md5 databaseType:self.dataBaseDeviceType fildId:self.fileId acStateInfo:newAcStateInfo keyId:keyInfo.key complete:^(TopResultInfo * _Nonnull resucltInfo) {
                if(resucltInfo.state == GLStateTypeOk) {
                    weakSelf.acStateInfo = newAcStateInfo;
                    [self.tableView reloadData];
                    NSLog(@"Success");
                }
            }];
        }else {
           
            [TopGLAPIManager.shareManager controlSubDeviceKeyWithMd5:self.mainDeviceInfo.md5 subDevInfo:self.subDevInfo acStateInfo:newAcStateInfo keyId:keyInfo.key complete:^(TopResultInfo * _Nonnull resucltInfo) {
                if(resucltInfo.state == GLStateTypeOk) {
                    weakSelf.acStateInfo = newAcStateInfo;
                    [self.tableView reloadData];
                    NSLog(@"Success");
                }
                
            }];
            
        }
    }
    
    
}

- (void)deviceStateChange:(nonnull TopResultInfo *)resultInfo {
    NSLog(@"%@===%@", resultInfo.md5, self.subDevInfo.md5);
    if (resultInfo.subId == self.subDevInfo.subId && [resultInfo.md5 isEqualToString:self.subDevInfo.md5]) {
        self.subDevInfo.stateValue = resultInfo.stateValue;
        self.acStateInfo = [self.subDevInfo getACStateInfoWithStateValue:resultInfo.stateValue];
        [self.tableView reloadData];
    }
 
}


@end
