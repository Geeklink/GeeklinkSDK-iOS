//
//  AppDelegate.swift
//  MyTest
//
//  Created by 列树童 on 2019/11/21.
//  Copyright © 2019 列树童. All rights reserved.
//

import UIKit

var AppOrientationMask = UIInterfaceOrientationMask.portrait;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var conn: Reachability!
    var oldTaskId: UIBackgroundTaskIdentifier!
    var window: UIWindow?
    var isInitAiSpeakerSDK = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
     
        
        //修改弹窗气泡配置
        SVProgressHUD.setBackgroundColor(UIColor.init(red: 240, green: 240, blue: 240, alpha: 0.8))
        SVProgressHUD.setMaximumDismissTimeInterval(1.5)
        
        //初始化第三方SDK
        return true
    }
    
   
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppOrientationMask
    }
   
    
    func applicationWillResignActive(_ application: UIApplication) {
        oldTaskId = UIBackgroundTaskIdentifier.invalid
        oldTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
    }
    
 
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    
      
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name("applicationWillEnterForeground"), object: nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
       
    
    }

    
}


