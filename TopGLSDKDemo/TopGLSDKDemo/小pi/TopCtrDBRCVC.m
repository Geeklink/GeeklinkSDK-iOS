//
//  TopCtrDBRCVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/30.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopCtrDBRCVC.h"
#import "SVProgressHUD.h"
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
      
        self.dataBaseDeviceType = self.subDevInfo.databaseDevType;

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
    subInfo.mainType = GLDeviceMainTypeDatabaseDev;
 
    subInfo.databaseDevType = self.dataBaseDeviceType;
    if (subInfo.databaseDevType == GLDatabaseDevTypeAC) {
        subInfo.stateValue =  [subInfo getStateValueWithACState:self.acStateInfo];
    }
    subInfo.carrierType = GLCarrierTypeCARRIER38;
    [[TopGLSmartPiAPIManager shareManager] setSubDeviceWithMd5:self.mainDeviceInfo.md5 subDevInfo:subInfo action:GLActionFullTypeInsert complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
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

- (void)initKeyInfoListWithDatabaseDeviceType: (GLDatabaseDevType)deviceType {
    __weak typeof(self) weakSelf = self;
    switch (deviceType) {
       
        case GLDatabaseDevTypeTV:{
            [TopGLSmartPiAPIManager.shareManager getDBKeyListWithMd5:self.mainDeviceInfo.md5 databaseType:deviceType fildId:self.fileId complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
                if (resucltInfo.state == GLStateTypeOk) {
                    [weakSelf initTVKeyInfoList:resucltInfo.keyList];
                    [weakSelf.tableView reloadData];
                }
                  
            }];
        }
            break;
        case GLDatabaseDevTypeSTB:{
            [TopGLSmartPiAPIManager.shareManager getDBKeyListWithMd5:self.mainDeviceInfo.md5 databaseType:deviceType fildId:self.fileId complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
                 if (resucltInfo.state == GLStateTypeOk) {
                     [weakSelf initSTBKeyInfoList:resucltInfo.keyList];
                    [weakSelf.tableView reloadData];
                 }
                                       
            }];
                    
        }
           
            break;
        case GLDatabaseDevTypeIPTV:{
            [TopGLSmartPiAPIManager.shareManager getDBKeyListWithMd5:self.mainDeviceInfo.md5 databaseType:deviceType fildId:self.fileId complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
                if (resucltInfo.state == GLStateTypeOk) {
                    [weakSelf initIPTVKeyInfoList:resucltInfo.keyList];
                    [weakSelf.tableView reloadData];
                }
                
                                                                
            }];
                              
        }
          

            break;
        case GLDatabaseDevTypeAC:{
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
    powerKeyInfo.name = NSLocalizedString(@"Power", "");
    powerKeyInfo.key = TopDBACKeyTypePower;
    [self.keyInfoList addObject:powerKeyInfo];
    
    TopDBRCKeyInfo * modeKeyInfo = [[TopDBRCKeyInfo alloc] init];
    modeKeyInfo.name = NSLocalizedString(@"Mode",@"");
    modeKeyInfo.key = TopDBACKeyTypeMode;
    [self.keyInfoList addObject:modeKeyInfo];
    
    TopDBRCKeyInfo * dirKeyInfo = [[TopDBRCKeyInfo alloc] init];
    dirKeyInfo.name =  NSLocalizedString(@"Dir",@"");
    dirKeyInfo.key = TopDBACKeyTypeDir;
    [self.keyInfoList addObject:dirKeyInfo];
    
    TopDBRCKeyInfo * speedKeyInfo = [[TopDBRCKeyInfo alloc] init];
    speedKeyInfo.name = NSLocalizedString(@"Speed", @"");
    speedKeyInfo.key = TopDBACKeyTypeSpeed;
    [self.keyInfoList addObject:speedKeyInfo];
    
    TopDBRCKeyInfo * tempUpKeyInfo = [[TopDBRCKeyInfo alloc] init];
    tempUpKeyInfo.name = NSLocalizedString(@"Temp+",@"");
    tempUpKeyInfo.key = TopDBACKeyTypeTemp;
    [self.keyInfoList addObject:tempUpKeyInfo];
    
    
    TopDBRCKeyInfo * tempDownKeyInfo = [[TopDBRCKeyInfo alloc] init];
    tempDownKeyInfo.name = NSLocalizedString(@"Temp-",@"");
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
                name = NSLocalizedString(@"Power", @"");
                break;
            case TopDBIPTVKeyTypeUP:
                name = NSLocalizedString(@"Up", @"");
                break;
            case TopDBIPTVKeyTypeDOWN:
                name = NSLocalizedString(@"Down", @"");
                break;
            case TopDBIPTVKeyTypeLEFT:
                name = NSLocalizedString(@"Left", @"");
                break;
            case TopDBIPTVKeyTypeRIGHT:
                name = NSLocalizedString(@"Right", @"");
                break;
            case TopDBIPTVKeyTypeOK:
                name = NSLocalizedString(@"OK", @"");
                break;
            case TopDBIPTVKeyTypeMENU:
                name = NSLocalizedString(@"Menu", @"");
                break;
            case TopDBIPTVKeyTypeHOME:
                name = NSLocalizedString(@"Home", @"");
                break;
            case TopDBIPTVKeyTypeBACK:
                name = NSLocalizedString(@"Back", @"");
                break;
            case TopDBIPTVKeyTypeVOLPLUSE:
                name = NSLocalizedString(@"Volume+", @"");
                break;
            case TopDBIPTVKeyTypeVOLMINUS:
                name = NSLocalizedString(@"Volume-", @"");
                break;
            case TopDBIPTVKeyTypeSTEEING:
                name = NSLocalizedString(@"Setting", @"");
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
                name = NSLocalizedString(@"List", @"");
                break;
            case TopDBSTBKeyTypeSTBLAST:
                name =  NSLocalizedString(@"Application",@"");
                break;
            case TopDBSTBKeyTypeSTBWAIT:
                name = NSLocalizedString(@"Power",@"");
                break;
            case TopDBSTBKeyTypeSTBCHPLUS:
                name = NSLocalizedString(@"Channel+",@"");
                break;
            case TopDBSTBKeyTypeSTBCHMINUS:
                name = NSLocalizedString(@"Channel-",@"");
                break;
            case TopDBSTBKeyTypeSTBSOUNDPLUS:
                name = NSLocalizedString(@"Volume+",@"");
                break;
            case TopDBSTBKeyTypeSTBSOUNDMINUS:
                name = NSLocalizedString(@"Volume-",@"");
                break;
            case TopDBSTBKeyTypeSTBUP:
                name = NSLocalizedString(@"Up", @"");
                break;
            case TopDBSTBKeyTypeSTBDOWN:
                name = NSLocalizedString(@"Down", @"");
                break;
            case TopDBSTBKeyTypeSTBLEFT:
                name = NSLocalizedString(@"Left", @"");
                break;
            case TopDBSTBKeyTypeSTBRIGHT:
                name = NSLocalizedString(@"Right", @"");
                break;
            case TopDBSTBKeyTypeSTBOK:
                name = NSLocalizedString(@"OK",@"");
                break;
            case TopDBSTBKeyTypeSTBEXIT:
                name = NSLocalizedString(@"EXIT", @"");
                break;
            case TopDBSTBKeyTypeSTBMENU:
                name = NSLocalizedString(@"Menu", @"");
                break;
            case TopDBSTBKeyTypeSTBRED:
                name = NSLocalizedString(@"Red", @"");
                break;
            case TopDBSTBKeyTypeSTBGREEN:
                name = NSLocalizedString(@"Green", @"");
                break;
            case TopDBSTBKeyTypeSTBYELLOW:
                name = NSLocalizedString(@"Yellow", @"");
                break;
            case TopDBSTBKeyTypeSTBBLUE:
                name = NSLocalizedString(@"Blue", @"");
                break;
            case TopDBSTBKeyTypeSTBRETURN:
                name = NSLocalizedString(@"Back", @"");
                break;
            case TopDBSTBKeyTypeSTBUPPAGE:
                name = NSLocalizedString(@"Page-", @"");
                break;
            case TopDBSTBKeyTypeSTBDOWNPAGE:
                name = NSLocalizedString(@"Page+", @"");
                break;
            case TopDBSTBKeyTypeSTBSOUND:
                name = NSLocalizedString(@"Sound", @"");
                break;
            case TopDBSTBKeyTypeSTBMESSAGE:
                name = NSLocalizedString(@"Message", @"");
                break;
            case TopDBSTBKeyTypeSTBMUTE:
                name = NSLocalizedString(@"Mute", @"");
                break;
            case TopDBSTBKeyTypeSTBLOVE:
                name = NSLocalizedString(@"Love", @"");
                break;
            case TopDBSTBKeyTypeSTBGUIDES:
                name = NSLocalizedString(@"Guide", @"");
                break;
            case TopDBSTBKeyTypeSTBTV:
                name = NSLocalizedString(@"TV", @"");
                break;
            case TopDBSTBKeyTypeSTBBROADCAST:
                name = NSLocalizedString(@"Broadcast", @"");
                break;
            case TopDBSTBKeyTypeSTBNEWS:
                name = NSLocalizedString(@"News", @"");
                break;
            case TopDBSTBKeyTypeSTBSTOCK:
                name = NSLocalizedString(@"Stock", @"");
                break;
            case TopDBSTBKeyTypeSTBDEMAND:
                name = NSLocalizedString(@"Demand", @"");
                break;
            case TopDBSTBKeyTypeSTBMAIL:
                name = NSLocalizedString(@"Email", @"");
                break;
            case TopDBSTBKeyTypeSTBGAMES:
                name = NSLocalizedString(@"Games", @"");
                break;
            case TopDBSTBKeyTypeSTBLIST2:
                name = NSLocalizedString(@"List 2", @"");
                break;
            case TopDBSTBKeyTypeSTBLAST2:
                name = NSLocalizedString(@"Application 2", @"");
                break;
            case TopDBSTBKeyTypeSTBSET:
                name = NSLocalizedString(@"Setting", @"");
                break;
            case TopDBSTBKeyTypeSTBMAINPAGE:
                name = NSLocalizedString(@"Home", @"");
                break;
            case TopDBSTBKeyTypeSTBRECORD:
                name = NSLocalizedString(@"Record", @"");
                break;
            case TopDBSTBKeyTypeSTBSTOPRECORD:
                name = NSLocalizedString(@"Stop", @"");
                break;
            case TopDBSTBKeyTypeSTBA:
                name = NSLocalizedString(@"A", @"");
                break;
            case TopDBSTBKeyTypeSTBB:
                name = NSLocalizedString(@"B", @"");
                break;
            case TopDBSTBKeyTypeSTBC:
                name = NSLocalizedString(@"C", @"");
                break;
            case TopDBSTBKeyTypeSTBD:
                name = NSLocalizedString(@"D", @"");
                break;
            case TopDBSTBKeyTypeSTBE:
                name = NSLocalizedString(@"E", @"");
                break;
            case TopDBSTBKeyTypeSTBF:
                name = NSLocalizedString(@"F", @"");
           
                break;
            case TopDBSTBKeyTypeSTBREWIND:
                name = NSLocalizedString(@"Rewind", @"");
                break;
            case TopDBSTBKeyTypeSTBFAST:
                name = NSLocalizedString(@"Fast", @"");
                break;
            case TopDBSTBKeyTypeSTBPLAY:
                name = NSLocalizedString(@"Pause\\/Play", @"");
                break;
            case TopDBSTBKeyTypeSTBKEEP1:
                name = NSLocalizedString(@"Collect1", @"");
                break;
            case TopDBSTBKeyTypeSTBKEEP2:
                name = NSLocalizedString(@"Collect2", @"");
                break;
            case TopDBSTBKeyTypeSTBKEEP3:
                name = NSLocalizedString(@"Collect2", @"");
                break;
            case TopDBSTBKeyTypeSTBKEEP4:
                name = NSLocalizedString(@"Collect3", @"");
                break;
            case TopDBSTBKeyTypeSTBKEEP5:
                name = NSLocalizedString(@"Collect4", @"");
                break;
            case TopDBSTBKeyTypeSTBKEEP6:
                name = NSLocalizedString(@"Collect5", @"");
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
                name = NSLocalizedString(@"Power", @"");
                break;
              
            case TopDBTVKeyTypeLIYIN:
                name = NSLocalizedString(@"Liyin", @"");
                break;
            case TopDBTVKeyTypeBANYIN:
                name = NSLocalizedString(@"Audio", @"");
                break;
            case TopDBTVKeyTypeZHISHI:
                name = NSLocalizedString(@"Standard", @"");
                break;
            case TopDBTVKeyTypeSLEEP:
                name = NSLocalizedString(@"Sleep", @"");
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
                name = NSLocalizedString(@"Alternate programs", @"");
                break;
                
            
            case TopDBTVKeyTypeJIAOHUAN:
                name = NSLocalizedString(@"Exchange", @"");
                break;
            case TopDBTVKeyTypeHUAZHONGHUA:
                name = NSLocalizedString(@"PIP", @"");
                break;
            case TopDBTVKeyTypeNORMAL:
                name = NSLocalizedString(@"Normal", @"");
                break;
            case TopDBTVKeyTypeXUANTAI:
                name = NSLocalizedString(@"Screen Display", @"");
                break;
            case TopDBTVKeyTypePICTURE:
                name = NSLocalizedString(@"Picture", @"");
                break;
            case TopDBTVKeyTypeCHMINUS1:
                name = NSLocalizedString(@"Channel+", @"");
                break;
            case TopDBTVKeyTypeCHPLUS1:
                name = NSLocalizedString(@"Channel+", @"");
                break;
            case TopDBTVKeyTypeSOUND:
                name = NSLocalizedString(@"Sound", @"");
                break;
            case TopDBTVKeyTypeUP:
                name = NSLocalizedString(@"Up", @"");
                break;
            case TopDBTVKeyTypeDOWN:
                name = NSLocalizedString(@"Down", @"");
                break;
            case TopDBTVKeyTypeLEFT:
                name = NSLocalizedString(@"Left", @"");
                break;
            case TopDBTVKeyTypeRIGHT:
                name = NSLocalizedString(@"Rught", @"");
                break;
            case TopDBTVKeyTypeMENU:
                name = NSLocalizedString(@"Menu", @"");
                break;
            case TopDBTVKeyTypePINGXIAN:
                name = NSLocalizedString(@"Screen Display", @"");
                break;
            case TopDBTVKeyTypeAVTV:
                name = NSLocalizedString(@"AVTV", @"");
                break;
            case TopDBTVKeyTypeDONE:
                name = NSLocalizedString(@"OK", @"");
                break;
            case TopDBTVKeyTypeSOUNDPLUS:
                name = NSLocalizedString(@"Volume+", @"");
                break;
            case TopDBTVKeyTypeSOUNDMINES:
                name = NSLocalizedString(@"Volume-", @"");
                break;
            case TopDBTVKeyTypeCHPLUS:
                name = NSLocalizedString(@"Channel+", @"");
                break;
            case TopDBTVKeyTypeCHMINUS:
                name = NSLocalizedString(@"Channel-", @"");
                break;
            case TopDBTVKeyTypeMUTE:
                name = NSLocalizedString(@"Mute", @"");
                break;
            case TopDBTVKeyTypeBACK:
                name = NSLocalizedString(@"Back", @"");
                break;
            case TopDBTVKeyTypeHOME:
                name = NSLocalizedString(@"Home", @"");
                break;
            case TopDBTVKeyTypeCount:
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




- (NSMutableArray *)keyInfoList {
    if (_keyInfoList == nil) {
        _keyInfoList = [NSMutableArray array];
    }
    return _keyInfoList;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.dataBaseDeviceType == GLDatabaseDevTypeAC){
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        /**
         *power;false为关 true为开
         *mode;0自动/1制冷/2除湿/3送风/4制热
         *temp;16-30摄氏度
         *speed;码库空调风速0自动/1低/2中/3高
         *dir;0扫风/风向1/风向2/风向3/风向4
         */
        
        NSString * penStr = self.acStateInfo.powerState ? NSLocalizedString(@"ON", @"") :  NSLocalizedString(@"OFF", @"");
        NSString * modeStr = NSLocalizedString(@"AUTO", @"");
        switch (self.acStateInfo.mode) {
            case 0:
                modeStr = NSLocalizedString(@"AUTO", @"");
                break;
            case 1:
                NSLocalizedString(@"COOL", @"");
                break;
            case 2:

                 modeStr = NSLocalizedString(@"DRY", @"");
                break;
            case 3:
               modeStr = NSLocalizedString(@"FAN", @"");
                break;
                
            default:
                break;
        }
  
        cell.textLabel.text = [NSString stringWithFormat: NSLocalizedString(@"Status：%@ Mode:%ld Speed：%ld Dir：%ld, Temp：%ld", @""), penStr, (long)self.acStateInfo.mode, self.acStateInfo.speed, self.acStateInfo.mode, self.acStateInfo.temperature];
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
    if (section == 0 && self.dataBaseDeviceType == GLDatabaseDevTypeAC){
        return 1;
        
    }
    return self.keyInfoList.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.dataBaseDeviceType == GLDatabaseDevTypeAC ? 2 : 1;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
   
    TopDBRCKeyInfo * keyInfo = self.keyInfoList[indexPath.row];
    if (self.dataBaseDeviceType != GLDatabaseDevTypeAC) {
        
        if (self.subDevInfo == nil) {
            
            [TopGLSmartPiAPIManager.shareManager testDataBaseDeviceWithMd5:self.mainDeviceInfo.md5 databaseType:self.dataBaseDeviceType fildId:self.fileId acStateInfo:nil keyId:keyInfo.key complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
                if(resucltInfo.state == GLStateTypeOk) {
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
                }else {
                    
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
                }
            }];
        }else {
            
            [TopGLSmartPiAPIManager.shareManager controlSubDeviceKeyWithMd5:self.mainDeviceInfo.md5 subDevInfo:self.subDevInfo acStateInfo:nil keyId:keyInfo.key complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
                if(resucltInfo.state == GLStateTypeOk) {
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
                }else {
                    
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
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
                if ([keyInfo.name isEqualToString:NSLocalizedString(@"Temp+", nil)]) {
                    if (newAcStateInfo.temperature >= 30) {
                      
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Up to 30 degrees Celsius", @"")];
                        return;
                    }
                    newAcStateInfo.temperature += 1;
                }else {
                    if (newAcStateInfo.temperature <= 16) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Minimum 16 degrees Celsius" , @"")];
                        
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
            
            [TopGLSmartPiAPIManager.shareManager testDataBaseDeviceWithMd5:self.mainDeviceInfo.md5 databaseType:self.dataBaseDeviceType fildId:self.fileId acStateInfo:newAcStateInfo keyId:keyInfo.key complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
            
                if(resucltInfo.state == GLStateTypeOk) {
                    weakSelf.acStateInfo = newAcStateInfo;
                    [self.tableView reloadData];
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
                }else {
                    
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
                }
            }];
        }else {
           
            [TopGLSmartPiAPIManager.shareManager controlSubDeviceKeyWithMd5:self.mainDeviceInfo.md5 subDevInfo:self.subDevInfo acStateInfo:newAcStateInfo keyId:keyInfo.key complete:^(TopGLSmartPiResultInfo * _Nonnull resucltInfo) {
                
                if(resucltInfo.state == GLStateTypeOk) {
                    weakSelf.acStateInfo = newAcStateInfo;
                    [self.tableView reloadData];
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
                }else {
                    
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
                }
            }];
            
        }
    }
    
    
}

- (void)deviceStateChange:(nonnull TopGLAPIResult *)resultInfo {
    NSLog(@"%@===%@", resultInfo.md5, self.subDevInfo.md5);
    if (resultInfo.subId == self.subDevInfo.subId && [resultInfo.md5 isEqualToString:self.subDevInfo.md5]) {
        self.subDevInfo.stateValue = resultInfo.stateValue;
        self.acStateInfo = [self.subDevInfo getACStateInfoWithStateValue:resultInfo.stateValue];
        [self.tableView reloadData];
    }
 
}


@end
