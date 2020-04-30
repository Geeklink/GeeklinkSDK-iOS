//
//  TopTestVC.m
//  Geeklink
//
//  Created by YanFeiFei on 2020/3/13.
//  Copyright © 2020 Geeklink. All rights reserved.
//

#import "TopTestVC.h"
#import <GeeklinkSDK/SDK.h>
#import "TopMainDeviceListVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>
#import "SVProgressHUD/SVProgressHUD.h"

@interface TopTestVC ()<CLLocationManagerDelegate>  {
    
    NSString *apSsid;//当前Wi-Fi的SSID名
    NSString *apBssid;//当前Wi-Fi的BSSID名
    bool isConfigureRunning;//是否正在配置
    CGFloat textFieldBottomY;//输入框底部的屏幕高度
    
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel1;
@property (weak, nonatomic) IBOutlet UILabel *tiplabel2;
@property (weak, nonatomic) IBOutlet UIButton *otherWifiBtn;


@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;//当前Wi-Fi
@property (weak, nonatomic) IBOutlet UITextField *textField;//密码
@property (weak, nonatomic) IBOutlet UILabel *guideLabel;//提示
@property (weak, nonatomic) IBOutlet UIButton *configureButton;//配置按钮
@property (nonatomic, strong) CLLocationManager         *locationManager;       // 定位获取Wi-Fi
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deviceListItem;

@property (copy, nonatomic) NSString * deviceSaveKey;//本地设备保存的key

@property (strong, nonatomic) NSMutableArray * mainDeviceList;//这设备列表
@end

@implementation TopTestVC


//MARK: - viewDidLoad 视图

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"Please connect to the Wi-Fi of the device ready to configure", @"");
    self.tipLabel1.text = NSLocalizedString(@"If the router supports dual-band Wi-Fi, please connect to 2.4G Wi-Fi, do not connect to 5G Wi-Fi, and do not turn on the router dual-band integration function.", @"");
    self.tiplabel2.text = NSLocalizedString(@"The device needs to be connected to the same LAN as the mobile phone. Please do not use the router guest network or turn on the router AP isolation function.", @"");
    [self.otherWifiBtn setTitle:NSLocalizedString(@"Switch Other Wifi", @"") forState:UIControlStateNormal];
    [self.configureButton setTitle:NSLocalizedString(@"Configure", @"") forState:UIControlStateNormal];
    self.textField.placeholder = NSLocalizedString(@"Please input pass word", @"");
     self.guideLabel.text = NSLocalizedString(@"Clicked To Configure", @"");
    
    self.titleLabel.adjustsFontSizeToFitWidth = true;
    self.deviceSaveKey = @"deviceSaveKey";
    self.deviceListItem.title = NSLocalizedString(@"Device List", @"");
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey: self.deviceSaveKey] != nil) {
        NSArray * deviceDictList = [[NSUserDefaults standardUserDefaults] objectForKey:self.deviceSaveKey];
        
        for (NSDictionary * deviceDict in deviceDictList) {
            TopMainDeviceInfo * mainDeviceInfo = [[TopMainDeviceInfo alloc] init];
            mainDeviceInfo.md5 = deviceDict[@"md5"];
            mainDeviceInfo.token = deviceDict[@"token"];
            NSNumber * mainTypeNum = deviceDict[@"mainType"];
            mainDeviceInfo.mainType = mainTypeNum.integerValue;
            NSNumber * subTypeNum = deviceDict[@"subType"];
            mainDeviceInfo.subType = subTypeNum.integerValue;
            [self.mainDeviceList addObject:mainDeviceInfo];
            
        }
    }
    
    
    //
    //   TopMainDeviceInfo * mainDeviceInfo = [[TopMainDeviceInfo alloc] init];
    //    mainDeviceInfo.md5 = @"b97c1b579a595eeb4b5fd36e28b771a0".lowercaseString;
    //    mainDeviceInfo.token = @"2ACE5E33";
    //
    //
    //    mainDeviceInfo.mainType = TopNetworkDevice;
    //    mainDeviceInfo.subType = TopNetworkDeviceTypeSmartpi;
    //    [self.mainDeviceList addObject:mainDeviceInfo];
    
    [[TopGLAPIManager shareManager] linKAllMainDevice:self.mainDeviceList];
    
    
    BOOL enable = [CLLocationManager locationServicesEnabled];
    NSInteger state = [CLLocationManager authorizationStatus];
    
    if (!enable || 2 > state) {// 尚未授权位置权限
        if (8 <= [[UIDevice currentDevice].systemVersion floatValue]) {
            // 系统位置权限授权弹窗
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            [self.locationManager requestAlwaysAuthorization];
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    else {
        if (state == kCLAuthorizationStatusDenied) {// 授权位置权限被拒绝
            
            UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Hint", @"")
                                                                              message:NSLocalizedString(@"Hint", @"Unauthorized access to location")
                                                                       preferredStyle:UIAlertControllerStyleAlert];
            [alertCon addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Not Set", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            
            [alertCon addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Set",@"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                dispatch_after(0.2, dispatch_get_main_queue(), ^{
                    NSURL *url = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];// 跳转至系统定位授权
                    if( [[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                            
                        }];
                    }
                });
            }]];
            
            [self presentViewController:alertCon animated:YES completion:^{
                
            }];
        }
    }
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    //读取当前Wi-Fi名字
    apSsid = @"";
    apBssid = @"";
    for (NSString *cfa in CFBridgingRelease(CNCopySupportedInterfaces())) {
        NSDictionary *dict = CFBridgingRelease(CNCopyCurrentNetworkInfo((CFStringRef)cfa));
        if (dict) {
            apSsid = dict[@"SSID"];
            apBssid = dict[@"BSSID"];
            break;
        }
    }
    
    
    //更新界面显示
    self.ssidLabel.text = [NSString stringWithFormat:@"Current Wi-Fi：%@", ([apSsid isEqualToString:@""] ? NSLocalizedString(@"Not Find", @""): apSsid)];
    
}

#pragma mark - 定位回调(CLLocationManagerDelegate)
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusNotDetermined) return; // 因为会多次回调，所以未确认权限不反悔
    
}
- (void)gotoTopMainDeviceListVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TopMainDeviceListVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"TopMainDeviceListVC"];
    vc.mainDeviceList = self.mainDeviceList;
    [self showViewController:vc sender:nil];
}
- (IBAction)clickDeviceListBtn:(id)sender {
    
    [self gotoTopMainDeviceListVC];
}

- (NSMutableArray *)mainDeviceList {
    if (_mainDeviceList == nil) {
        _mainDeviceList = [NSMutableArray array];
    }
    return _mainDeviceList;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //停止配置
    [self onConfigureStop];
}

//MARK: - Notification 通知

//APP返回前台
- (void)didBecomeActiveNotification:(NSNotification *)notification {
    
    //读取当前Wi-Fi名字
    apSsid = @"";
    apBssid = @"";
    for (NSString *cfa in CFBridgingRelease(CNCopySupportedInterfaces())) {
        NSDictionary *dict = CFBridgingRelease(CNCopyCurrentNetworkInfo((CFStringRef)cfa));
        if (dict) {
            apSsid = dict[@"SSID"];
            apBssid = dict[@"BSSID"];
            break;
        }
    }
    
    //更新界面显示
    self.ssidLabel.text =  [NSString stringWithFormat:@"Current Wi-Fi：%@", ([apSsid isEqualToString:@""] ? NSLocalizedString(@"Not Find", @""): apSsid)];
}

//键盘边距变化
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    //获取键盘高度和动画时长
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //计算键盘顶部比输入框底部高度差
    CGFloat offsetY = frame.origin.y - textFieldBottomY;
    //执行界面移动动画
    [UIView animateWithDuration:duration animations:^{
        if (offsetY < 0)//如果键盘顶部比输入框底部高，提高界面高度
            [self.view setTransform:CGAffineTransformMakeTranslation(0, offsetY)];
        else//否则还原界面高度
            [self.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
    }];
}

//MARK: - UITextFieldDelegate 输入框

//点击键盘返回按键
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //关闭编辑模式隐藏键盘
    [self.view endEditing:YES];
    return YES;
}

//MARK: - IBAction 按键

//点击配置
- (IBAction)onConfigureStart:(id)sender {
    if (isConfigureRunning) {
        //停止配置
        [self onConfigureStop];
        
    } else {
        //检查配置信息
        if ([apSsid isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Not Connect Wi-Fi", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else if ((self.textField.text.length > 0) && (self.textField.text.length < 8)) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Wi-Fi password length is wrong", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else if ([apSsid containsString:@"5G"] || [apSsid containsString:@"5g"]) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"5g Wi-Fi is not supported", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Switch Wifi", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //切换Wi-Fi
                [self onChangeWifi:[UIButton new]];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                //开始配网
                [self onConfigureStart];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            
            //开始配网
            [self onConfigureStart];
        }
    }
}

//点击切换Wi-Fi
- (IBAction)onChangeWifi:(id)sender {
    //前往系统设置
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:"] options:@{} completionHandler:^(BOOL success) {}];
}

//MARK: - Configure 配网

//开始配网
- (void)onConfigureStart {
    
    isConfigureRunning = YES;
    
    //更新界面显示
    self.guideLabel.text = NSLocalizedString(@"Configuring", @"");
    [self.configureButton setTitle:NSLocalizedString(@"Stop configuration",@"") forState:UIControlStateNormal];
    //获取Wi-Fi密码，在非主线程时获取会报异常
    NSString *apPwd = self.textField.text;
    [TopGLAPIManager.shareManager configerWifiWithApBssid:apBssid andApSsid:apSsid andPassword:apPwd configerResult:^(TopConfigerDevResult * _Nonnull configerDevResult) {
        NSMutableArray * mutDeviceDictList = [NSMutableArray array];
        if (configerDevResult.state == GLStateTypeOk) {
            // 我这里只是暂时将数据保存到本地
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"")];
            if ([[NSUserDefaults standardUserDefaults] objectForKey: self.deviceSaveKey] != nil) {
                NSArray * deviceDictList = [[NSUserDefaults standardUserDefaults] objectForKey:self.deviceSaveKey];
                
                for (NSDictionary * deviceDict in deviceDictList) {
                    NSString * str = deviceDict[@"md5"];
                    if ([str isEqualToString:configerDevResult.md5] == false) {
                        [mutDeviceDictList addObject: deviceDict];
                    }
                    
                }
                
            }
            NSMutableDictionary * mutDeviceDict = [NSMutableDictionary dictionary];
            mutDeviceDict[@"md5"] = configerDevResult.md5;
            
            mutDeviceDict[@"token"] = configerDevResult.token;
            
            mutDeviceDict[@"mainType"] = [NSNumber numberWithInteger:configerDevResult.mainType];
            mutDeviceDict[@"subType"] = [NSNumber numberWithInteger:configerDevResult.subType];;
            [mutDeviceDictList addObject:mutDeviceDict];
            
            TopMainDeviceInfo * mainDeviceInfo = [[TopMainDeviceInfo alloc] init];
            mainDeviceInfo.md5 = configerDevResult.md5;
            mainDeviceInfo.token = configerDevResult.token;
            mainDeviceInfo.mainType = configerDevResult.mainType;
            mainDeviceInfo.subType = configerDevResult.subType;
            [self.mainDeviceList addObject:mainDeviceInfo];
            
            [[NSUserDefaults standardUserDefaults] setObject:mutDeviceDictList forKey:self.deviceSaveKey];
            
        }else if (configerDevResult.state == GLStateTypeFullError){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"The test device is full. For cooperation, please contact Geeklink Technology Co.Ltd", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else{
            
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failure", @"")];
        }
        
    }];
    
    
    //开始异步配置
    
    
    
    
}

//停止配网
- (void)onConfigureStop {
    isConfigureRunning = NO;
    self.guideLabel.text = NSLocalizedString(@"Clicked To Configure", @"");
    [self.configureButton setTitle:NSLocalizedString(@"Configure", @"") forState:UIControlStateNormal];
    [[TopGLAPIManager shareManager] stopConfigureWifi];
    
}

//MARK: - GeeklinkDelegate 代理实现

/**日志输出 */
- (void)geeklinkLogOutput:(NSString *)log {
    printf("GeeklinkWifiSwiftVC geeklinkLogOutput: %s\n", [log UTF8String]);
}



@end


