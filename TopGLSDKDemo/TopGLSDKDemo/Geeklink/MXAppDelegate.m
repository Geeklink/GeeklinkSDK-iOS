#import "MXAppDelegate.h"
#import "MXSampleDataTableViewController.h"
#import "GLHttpObjc.h"
#import "GLEventLoopObjc.h"
#import "GLThreadLauncherObjc.h"

#import "gen/GLApiCppProxy.h"

#import "XGPush.h"
#import "XGSetting.h"
#import "pushInfo.h"
#import "GlobalVars.h"

@implementation MXAppDelegate

+ (id <GLApi>) makeApi {
    // give GL a root folder to work in
    // todo, make sure that the path exists before passing it to GL c++
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *file = [documentsFolder stringByAppendingPathComponent:@"GL"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:file]) {
        [fileManager createDirectoryAtPath:file withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
//    id <GLHttp> httpImpl = [[GLHttpObjc alloc] init];
    id <GLEventLoop> uiThread= [[GLEventLoopObjc alloc] init];
    id <GLThreadLauncher> localRecvLauncher= [[GLThreadLauncherObjc alloc] init];
    id <GLThreadLauncher> remoteRecvLauncher= [[GLThreadLauncherObjc alloc] init];
    id <GLThreadLauncher> mainLauncher = [[GLThreadLauncherObjc alloc] init];
//    id <GLThreadLauncher> sendLauncher = [[GLThreadLauncherObjc alloc] init];
//    id <GLThreadLauncher> dbLauncher = [[GLThreadLauncherObjc alloc] init];
    id <GLApi> api = [GLApiCppProxy createApi:file uiThread:uiThread mainLauncher:mainLauncher localRecvLauncher:localRecvLauncher remoteRecvLauncher:remoteRecvLauncher];
//    id <GLApi> api = [GLApiCppProxy createApi:file uiThread:uiThread receiverLauncher:recvLauncher senderLauncher:sendLauncher dbLauncher:dbLauncher];
    
//    if (![api hasUser]) {
//        NSLog(@"No user found, creating one");
//        [api setUsername: @"djinni demo"];
//    }
    return api;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.api = [MXAppDelegate makeApi];
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    // If the device is an iPad, we make it taller.
    [self xgPushInit:launchOptions];
    application.applicationIconBadgeNumber = 0;
    
    MXSampleDataTableViewController *sampleViewController = [[MXSampleDataTableViewController alloc] initWithApi:self.api];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sampleViewController];

    self.window.rootViewController = navController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}



- (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)xgPushInit:(NSDictionary *)launchOptions
{
    [XGPush startApp:2200092457 appKey:@"IDJM5W881E5R"];
    //[XGPush startApp:2290000353 appKey:@"key1"];
    
    //注销之后需要再次注册前的准备
    void (^successCallback)(void) = ^(void){
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8注册push方法
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(sysVer < 8){
                [self registerPush];
            }
            else{
                [self registerPushForIOS8];
            }
#else
            //iOS8之前注册push方法
            //注册Push服务，注册后才能收到推送
            [self registerPush];
#endif
        }
    };
    [XGPush initForReregister:successCallback];
    
    //推送反馈回调版本示例
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]handleLaunching's successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]handleLaunching's errorBlock");
    };
    
    if (launchOptions != nil)
    {
        //opened from a push notification when the app is closed
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil)
        {
            
            NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            pushInfo *pushInf= [[pushInfo alloc]init];
            pushInf.message = alert;
            pushInf.date = [NSDate date];
//            [pushInf insertToDb];
        }
        
    }
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [XGPush handleLaunching:launchOptions successCallback:successBlock errorCallback:errorBlock];
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * deviceTokenStr = [XGPush registerDevice:deviceToken];
    
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]register successBlock ,deviceToken: %@",deviceTokenStr);
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]register errorBlock");
    };
    
    //注册设备
    [[XGSetting getInstance] setChannel:@"appstore"];
    [[XGSetting getInstance] setGameServer:@"巨神峰"];
    [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];
    
    //如果不需要回调
    //[XGPush registerDevice:deviceToken];
    
    //打印获取的deviceToken的字符串
    NSLog(@"deviceTokenStr is %@,len :%d",deviceTokenStr,(int)deviceTokenStr.length);
    GlobalVars *global = [GlobalVars shareGlobalVars];
    global.devToken = deviceTokenStr;
}

//如果deviceToken获取不到会进入此事件
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@",err];
    
    NSLog(@"%@",str);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    NSLog(@"Receive Notify: %@", [userInfo JSONString]);
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
//    if (application.applicationState == UIApplicationStateActive) {
//        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
//        CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:NSLocalizedString(@"pushTitle",nil) message:alert cancelButtonTitle:NSLocalizedString(@"sure", nil)];
//        [alertView show];
//    }
//    
    pushInfo *pushInf= [[pushInfo alloc]init];
    pushInf.message = alert;
    pushInf.date = [NSDate date];
    [pushInf insertToDb];
    
    [application setApplicationIconBadgeNumber:0];
    
    [XGPush handleReceiveNotification:userInfo];
    
    //    self.viewController.textView.text = [self.viewController.textView.text stringByAppendingFormat:@"Receive notification:\n%@", [userInfo JSONString]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.api networkStop];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.api networkContinue];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}



@end
