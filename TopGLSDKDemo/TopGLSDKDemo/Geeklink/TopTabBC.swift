//
//  TopTabBC.swift
//  Geeklink
//
//  Created by 列树童 on 2018/2/26.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopTabBC: UITabBarController, TopHomeNeedVCDelegate ,TopCountryPickerDelegate, TopAlarmAlertViewDelegate, TopCameraListVCDelegate, TopMorePINVCDelegate, TopAppGuideVDelegate {

    var homeInviteCount = -1//收到的家庭邀请数量，默认-1未获取
    var voiceColVC: TopVoiceColVC?
    var homeInfoKey: String!
    var isNeedLogin = false//是否需要登录
    var isViewAppear = false//判断进入界面，来弹其他界面
    var isMorePINShowing = false//正在显示登录界面
    var isNeedCheckPIN = true//是否需要检查APP锁定密码
    var isLoginShowing = false//正在显示登录界面
    var isHomeNeedShowing = false//正在显示需要家庭界面
    var isAppGuideShowing = false//正在显示APP引导
   // var isCountryPickerShowing = false//正在显示
    var isShowCountryPicker = false // 是否检查了第一次使用
    var isCheckShowFirstGuide = false // 是否检查了第一次使用
    var timer: Timer?//检查报警定时器
    var isShowCameraListVC = false//正在展示摄像头列表界面
    weak var cameraNavc: TopNavc?
    weak var alarmAlertView: TopAlarmAlertView?
    var currentWidth: CGFloat = 0
    
    var alarmThkAckInfoList = [TopThkAckInfo]()//在报警的队列
    var _homeInfo = GLHomeInfo()//当前家庭，这个为准
   
    var micBtn = UIButton()
    weak var alarmBtn: UIButton?
    
    var tempTabIndex = 0
    var isCamLiveViewAtMyView: Bool = true
    var camLiveView: TopCameraLiveView!
    var perPonit: CGPoint!
    var camLiveViewFrame: CGRect!
    var homeInfo: GLHomeInfo! {
        set {
            _homeInfo = newValue
            SGlobalVars.curHomeInfo = _homeInfo
            //
            if _homeInfo.homeId != nil {
                 TopDataManager.shared.homeId = _homeInfo.homeId
            }
            UserDefaults.standard.set(_homeInfo.homeId, forKey: homeInfoKey)
            

            let sharedDefaults = UserDefaults(suiteName: App_Group_ID)!
            sharedDefaults.set(_homeInfo.homeId, forKey: App_Group_ID+"_currentHomeId")
            sharedDefaults.set(SGlobalVars.homeHandle.getHomeAdminIsMe(_homeInfo.homeId), forKey: App_Group_ID+"_isAdmin")
            
            NotificationCenter.default.post(name: NSNotification.Name("SwitchHomeInfo"), object: _homeInfo)

            NotificationCenter.default.addObserver(self, selector: #selector(TopLoginVCWillDismiss), name:NSNotification.Name("TopLoginVCWillDismiss"), object: nil)
            
           
        } get {
            return _homeInfo
        }
       
    }
    
    
    // MARK: - UITabBar
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        //如果是更多
        if item.tag == 3 {
            if homeInviteCount >= 0 {//如果不是获取
                item.badgeValue = nil//消除红点
            }
        }
    }
    
    // MARK: - ViewLife
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if currentWidth == self.view.width {
            return
        }
        currentWidth = self.view.width
       
        //更新麦克风按钮位置
        tabBar.bringSubviewToFront(micBtn)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute:
            {
                for view in self.tabBar.subviews {
                    
                    if view is UIControl {
                        
                        for view1 in view.subviews {
                            if view1 is UILabel {
                                let label = view1 as! UILabel
                                if label.text == NSLocalizedString("Assistant", comment: "") {
                                    self.micBtn.frame = view.frame
                                }
                            }
                        }
                    }
                }
                
                if self.alarmBtn != nil {
                    self.alarmBtn?.frame = CGRect(x: self.view.width - 80, y: 180, width: 50, height: 50)
                }
                
                if self.alarmAlertView != nil{
                    let window: UIWindow = UIApplication.shared.windows.first!
                    self.alarmAlertView?.frame = window.bounds
                }
                self.view.bringSubviewToFront(self.camLiveView)
                
                var liveViewW = self.view.width - 16
                if liveViewW > 400  {
                    liveViewW = 400
                }
                let liveViewH = liveViewW * 0.65
                let liveViewY = UIApplication.shared.statusBarFrame.maxY
                self.camLiveViewFrame = CGRect.init(x: (self.view.width - liveViewW) * 0.5, y: liveViewY, width: liveViewW, height: liveViewH)
                if self.isCamLiveViewAtMyView {
                    self.camLiveView.frame = self.camLiveViewFrame
                }
                
                
        })
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        
        //设置麦克风按钮
        micBtn.addTarget(self, action: #selector(micBtnDidClicked), for: .touchUpInside)
        tabBar.addSubview(micBtn)
        //获取马库添加方式和域名
        TopDBRCHttpTool.share().getDatabaseAddWayAndUrlPixStr()
        //设置TabBar颜色
        tabBar.tintColor = APP_Theme_Color
        if #available(iOS 13.0, *) {
            tabBar.unselectedItemTintColor = UIColor.label
        } else {
            tabBar.unselectedItemTintColor = UIColor.glLabel()
        }

        //设置文本
        for navc in self.viewControllers! {
            if navc is TopHomeNC {
                navc.tabBarItem.title = NSLocalizedString("Home", comment: "")
            } else if navc is TopRoomNC {
                navc.tabBarItem.title = NSLocalizedString("Rooms", comment: "")
            } else if navc is TopMicNC {
                navc.tabBarItem.title = NSLocalizedString("Assistant", comment: "")
            } else if navc is TopMineNC {
                navc.tabBarItem.title = NSLocalizedString("More", comment: "")
            }
        }
        
        if SGlobalVars.api.getCurUsername() != nil {
//        if SGlobalVars.api.getCurUsername() != nil {
            homeInfoKey = "TempHomeId"+(SGlobalVars.api.getCurUsername())!
//            homeInfoKey = "TempHomeId"+(SGlobalVars.api.getCurUsername())!
        } else {
            homeInfoKey = ""
        }
        
        updateLoginData()
        
        loadTempHomeInfo()
        
        //增加监听
        NotificationCenter.default.addObserver(self, selector: #selector(userNeedGoLoginPage), name: NSNotification.Name("userNeedGoLoginPage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserLogoutResponse), name: NSNotification.Name("onUserLogoutResponse"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doorBellPushMsgackground), name: NSNotification.Name("TopDoorBellPushMsgackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userActivityOpenVC), name: NSNotification.Name("NSUserActivityOpenVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationOpenURL), name: NSNotification.Name("TopApplicationOpenURL"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(homeGetResp), name: NSNotification.Name("onThinkerShowAlarmResponse"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(theApplicationWillEnterForeground), name: NSNotification.Name("applicationWillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doorBellPushMsg), name: NSNotification.Name("TopDoorBellPushMsg"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onThinkerShowAlarmResponse), name: NSNotification.Name("onThinkerShowAlarmResponse"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(homeInviteGetResp), name: NSNotification.Name("homeInviteGetResp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(homeGetResp), name: NSNotification.Name("homeGetResp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TopLoginVCWillDismiss), name: NSNotification.Name("TopLoginVCWillDismiss"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TopLoginVCDidDismiss), name: NSNotification.Name("TopLoginVCDidDismiss"), object: nil)
        
        let alarmBtn = TopFloatButton()
        self.alarmBtn = alarmBtn
    
        alarmBtn.setImage(UIImage(named: "alarm_normal"), for: .normal)
        alarmBtn.setImage(UIImage(named: "alarm_sel"), for: .highlighted)
        alarmBtn.isHidden = true
        let window = UIApplication.shared.windows.first
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            window?.addSubview(alarmBtn)
        }
        alarmBtn.addTarget(self, action: #selector(alarmBtnDidClicked), for: .touchUpInside)
        
        if SGlobalVars.api.hasLogin() {
            SGlobalVars.homeHandle.homeInviteGetReq()
        }
        initCameraView()
    }
    
    @objc func applicationOpenURL() -> Void {
        if  SGlobalVars.openAppUrl.hasPrefix(APP_URL_SCHEMES_OPEN_APP_WIDGETS) {
            SGlobalVars.showVCName = "TopMineVC"
        }
    }
    
    func updateLoginData() ->Void {
       
        if !SGlobalVars.api.hasLogin() ||  SGlobalVars.api.getCurUsername() == "User" {
            GlobalDefaulDataManager.shared.setIsLogin(false)
            GlobalDefaulDataManager.shared.setUserName("")
            
        } else {
            GlobalDefaulDataManager.shared.setIsLogin(true)
            GlobalDefaulDataManager.shared.setUserName(SGlobalVars.api.getCurUsername())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //更新家庭信息修改
        self.isShowCameraListVC = false
        for homeCell in SGlobalVars.homeHandle.getHomeList() as! [GLHomeInfo] {
            if homeInfo.homeId == homeCell.homeId {
                homeInfo = homeCell
                SGlobalVars.curHomeInfo = homeInfo
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewAppear = true
        checkNeedShow()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isViewAppear = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TopAppGuideVC {
            let vc = segue.destination as! TopAppGuideVC
            vc.delegate = self
        }
    }
    
    // MARK: -
    
    override var selectedIndex: Int{
        get {
            return super.selectedIndex
        } set {
            super.selectedIndex = newValue
            
        }
    }
    
    @objc func userActivityOpenVC(){
        self.checkNeedShow()
    }
    
    @objc func micBtnDidClicked() -> Void {
        let vc: UINavigationController = self.viewControllers![selectedIndex] as! UINavigationController
        print(selectedIndex)
        if voiceColVC == nil {
            let sb = UIStoryboard(name: "TabBar", bundle: nil)
            voiceColVC = sb.instantiateViewController(withIdentifier: "TopVoiceColVC") as? TopVoiceColVC
        }
        
        vc.show(voiceColVC!, sender: nil)
    }
    
    // MARK: - 数据处理

    @objc func homeInviteGetResp(notificatin: Notification) {//获取返回
        let info: TopHomeAckInfo = notificatin.object as! TopHomeAckInfo
        
        
        //刷新列表
        homeInviteCount = info.homeInviteList.count
        
        //更新更多的红点
        if homeInviteCount > 0 {
            let item = self.tabBar.items![3]
            item.badgeValue = String(format: "%@", String(format: "%d", homeInviteCount))
        } else {
            let item = self.tabBar.items![3]
            item.badgeValue = nil
        }
    }
    @objc func homeGetResp() -> Void {
        checkNeedShow()
        TopDataManager.shared.refeshGroupHomeInfoList()
        
    }
    
    @objc func doorBellPushMsgackground(_ notification: Notification) {
        
        if isNeedLogin || isLoginShowing || isHomeNeedShowing {
            return;
        }
        
        let msg: TopDoorBellPushMsg = notification.object as! TopDoorBellPushMsg
        
        var  deviceInfoList = Array<GLDeviceInfo>.init()
        let homeList = SGlobalVars.homeHandle.getHomeList() as! Array<GLHomeInfo>
        for theHomeInfo in homeList{
            let deviceList = SGlobalVars.roomHandle.getDeviceListAll(theHomeInfo.homeId) as! [GLDeviceInfo]
            for deviceInfo in deviceList {
                if deviceInfo.camUid == msg.did {
                    deviceInfoList.append(deviceInfo)
                    
                }
            }
        }
        
        if deviceInfoList.count == 1 {
            let sb = UIStoryboard(name: "ToSee", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "TopDoorBellPlayVC") as! TopDoorBellPlayVC
            vc.deviceInfo = deviceInfoList.first
            vc.isDismiss = true
            let navc: UINavigationController = UINavigationController.init(rootViewController: vc)
            self.show(navc, sender: nil)
        } else {
            let sb = UIStoryboard(name: "ToSee", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "TopDoorBellCallVC") as! TopDoorBellCallVC
            let navc: UINavigationController = UINavigationController.init(rootViewController: vc)
            navc.modalPresentationStyle = .fullScreen
            vc.did = msg.did
            self.present(navc, animated: true) {
            }
        }
    }
    
    @objc func doorBellPushMsg(_ notifycation: Notification) -> Void {
        
        if isNeedLogin || isLoginShowing || isHomeNeedShowing{
            return;
        }
        
        let msg: TopDoorBellPushMsg = notifycation.object as! TopDoorBellPushMsg
        let sb = UIStoryboard(name: "ToSee", bundle: nil)
        if msg.mode != "1" {
            return
        }
        
        let vc = sb.instantiateViewController(withIdentifier: "TopDoorBellCallVC") as! TopDoorBellCallVC
        let navc: UINavigationController = UINavigationController.init(rootViewController: vc)
        vc.did = msg.did
        self.present(navc, animated: true) {}
    }
    
    @objc func theApplicationWillEnterForeground() -> Void {
        isNeedCheckPIN = true
        checkNeedShow()
        
    }
    
    @objc func onThinkerShowAlarmResponse(_ notification: Notification) {
        let ackInfo = notification.object as! TopThkAckInfo
        ackInfo.coundown = 0
        var index: Int = 0
      
    
        for alarmThkAckInfo in alarmThkAckInfoList{
            if alarmThkAckInfo.homeId == ackInfo.homeId &&  alarmThkAckInfo.deviceId == ackInfo.deviceId{
                alarmThkAckInfoList[index] = ackInfo
                return
                
            }
            index += 1
        }
        alarmThkAckInfoList.append(ackInfo)
      
        if isShowCameraListVC {
            return
        }
        
        
        //插入报警队列
       
        
        showAlarmAlertView((alarmThkAckInfoList.last)!)
    }
    
    func showAlarmAlertView(_ thkAckInfo: TopThkAckInfo) -> Void {
        self.alarmBtn?.isHidden = true
        var homeName = ""
        for homeCell in SGlobalVars.homeHandle.getHomeList() as! [GLHomeInfo] {
            if homeCell.homeId == thkAckInfo.homeId {
                homeName = homeCell.name
                break
            }
        }
        
        let deviceList = NSMutableArray(array:SGlobalVars.roomHandle.getDeviceListAll(thkAckInfo.homeId)) as! [GLDeviceInfo]
        var deviceName: String = ""
        for deviceInfo in deviceList {
            if deviceInfo.deviceId == thkAckInfo.deviceId{
                deviceName = deviceInfo.name
                break
            }
        }
        
        let text = NSLocalizedString("Notice", comment: "")+":  "+homeName+NSLocalizedString(" is alarming!", comment: "")+"\n"+deviceName+NSLocalizedString("trigger", comment: "")
        if self.alarmAlertView == nil{
             let window: UIWindow = UIApplication.shared.windows.first!
            let alarmAlertView = TopAlarmAlertView(frame: window.bounds)
           
            alarmAlertView.textColor = UIColor.glLabel()
            self.alarmAlertView = alarmAlertView
            alarmAlertView.type = .viewAlarm
           
           
            
            alarmAlertView.delegate = self
            let scaleAnimation = CABasicAnimation(keyPath: "transform")
            scaleAnimation.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 1))
            scaleAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1))
            
            
            scaleAnimation.duration = 0.2;
            scaleAnimation.isCumulative = false;
            scaleAnimation.repeatCount = 1;
            
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            
            alarmAlertView.layer.add(scaleAnimation, forKey: "myScale")
            
            
            window.addSubview(alarmAlertView)
        }
        alarmAlertView?.isHidden = false
        self.alarmAlertView?.text = text
        self.alarmAlertView?.thkAckInfo = thkAckInfo
        
    }
    
    @objc func userNeedGoLoginPage() {
        isNeedLogin = true
        isLoginShowing = false
        self.updateLoginData()
        checkNeedShow()
    }
    
    @objc func onUserLogoutResponse() -> Void {
        GlobalDefaulDataManager.shared.setIsLogin(false)
        GlobalDefaulDataManager.shared.setUserName("")
    }
    
    
  
    
    // MARK: - 检查弹窗
    func checkNeedShow() {//检查需要弹窗
        if !isViewAppear {return}
      
       // if isCountryPickerShowing {return}
      //  if isNeedShowCountryPicker() {return}
        if isNeedShowFirstGuide() {return}
        if isAppGuideShowing {return}
        if isNeedShowFirstGuide() {return}
        
        if isLoginShowing {return}
        if isMorePINShowing {return}
        if isHomeNeedShowing {return}
        if checkLoginShow() {showLoginView(); return}
        if isShowCameraListVC {return}
        if checkMorePINVC() {showMorePINVC(); return}
        if checkHomeNeedShow() {showHomeNeedView(); return}
        
        
        if SGlobalVars.showVCName != "" {
            switch (SGlobalVars.showVCName) {
            case "TopHomeVC":
                selectedIndex = 0
            case "TopRoomVC":
                selectedIndex = 1
            case "TopVoiceColVC":
                self.micBtnDidClicked()
              
            case "TopMineVC", "":
                selectedIndex = 3
                
            default:
                break
            }
            SGlobalVars.showVCName  = ""
        }
       
    }
    
    func isNeedShowCountryPicker() -> Bool {
        if App_Company == .geeklink {
        
            if isShowCountryPicker == false {
                isShowCountryPicker = true
                
                if UserDefaults.standard.value(forKey: "COUNTRYPICKER_APP_FLAG") == nil {
                    let picker = TopCountryPicker { (name, code) -> () in
                        print(code)
                    }
                    
                    let path = Bundle.main.path(forResource:"code", ofType: "json")
                    let url = URL(fileURLWithPath: path!)
                    do {
                        let data = try Data(contentsOf: url)
                        let json: Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                        let dicList = json as! [NSDictionary]
                        var customCountriesCode = [TopCountry]()
                        
                        for dic in dicList {
                            let localeStr: String = (dic.value(forKey: "locale") as? String)!
                            let detailCode: NSNumber = (dic.value(forKey: "code") as? NSNumber)!
                            let detailCodeStr = "+"+detailCode.stringValue
                            if localeStr.count >= 2 && localeStr != "  " {
                                let country = TopCountry(name: "", code: localeStr, dialCode: detailCodeStr, isFrequentlyUsed: false)
                                customCountriesCode.append(country)
                            }
                        }
                        picker.customCountriesCode = customCountriesCode
                        
                    } catch let error as Error? {
                        print("读取本地数据出现错误！", error as Any)
                    }
                    
                    // Optional: To pick from custom countries list
                    
                    
                    // delegate
                    picker.delegate = self
                    
                    // Display calling codes
                    //        picker.showCallingCodes = true
                    
                    // or closure
                    picker.didSelectCountryClosure = { name, code in
                        picker.navigationController?.popToRootViewController(animated: true)
                        print(code)
                    }
                    let navc = UINavigationController(rootViewController: picker)
                    navc.modalPresentationStyle = .fullScreen
                    self.present(navc, animated: true) {}
                  //  isCountryPickerShowing = true
                    return true
                }
            }
        }
        return false
    }
    
    func countryPicker(_ picker: TopCountryPicker, didSelectCountryWithName name: String, code: String) {
//        isCountryPickerShowing = false
//        UserDefaults.standard.setValue(code, forKey: "COUNTRYPICKER_APP_FLAG")
//        self.checkNeedShow()
    }

    func isNeedShowFirstGuide() -> Bool {
        if App_Have_Guide {
            if isCheckShowFirstGuide == false {
                isCheckShowFirstGuide = true
                if UserDefaults.standard.bool(forKey: "FIRST_OPEN_APP_FLAG") != true {
                    performSegue(withIdentifier: "TopAppGuideVC", sender: nil)
                    UserDefaults.standard.set(true, forKey: "FIRST_OPEN_APP_FLAG")
                    isAppGuideShowing = true
                    return true
                }
            }
        }
        return false
    }
    
    func checkHomeNeedShow() -> Bool {//检查需要家庭
        //获取家庭列表
        let homeList = SGlobalVars.homeHandle.getHomeList() as! [GLHomeInfo]

     
        if homeList.count == 0 {//没有家庭
            return true
        } else {
            //当未设置当前家庭时，设置当前家庭
            if homeInfo.homeId == nil {
                loadTempHomeInfo()
            } else if homeInfo.homeId == "" {
                loadTempHomeInfo()
            }
            if homeInfo.homeId == nil {
                return true
            }
        }
        return false
    }
    
    func checkLoginShow() -> Bool {//检查需要登录
        if !SGlobalVars.api.hasLogin() {return true}
        if isNeedLogin {return true}
        if SGlobalVars.api.getCurUsername() == "User"{return true  }
        
        return false;
    }
    
    
    func checkMorePINVC() -> Bool {
        if isNeedCheckPIN {
            isNeedCheckPIN = false
            if UserDefaults.standard.value(forKey: SGlobalVars.pinKey) != nil  {
                return true
            }
        }
        return false
    }
    // MARK: - 显示弹窗
    
    func showMorePINVC() -> Void {
        isMorePINShowing = true
        let vc: TopMorePINVC? = TopMorePINVC(nibName: "TopMorePINVC", bundle: .main)
        vc?.delegate = self
        vc?.mode = .ver
        vc?.modalPresentationStyle = .fullScreen
        present(vc!, animated: true) {}
    }
    
    func showHomeNeedView() {
        isHomeNeedShowing = true
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let nc = sb.instantiateViewController(withIdentifier: "TopHomeNeedNC") as! UINavigationController
        let vc = nc.viewControllers[0] as! TopHomeNeedVC;
        vc.delegate = self;
        present(nc, animated: true, completion: nil)
    }
    
    func showLoginView() {
        isLoginShowing = true
        if isShowCameraListVC {
            if self.cameraNavc != nil {
                self.cameraNavc?.dismiss(animated: true, completion: {
                })
            }
        }
        
        //        self.selectedIndex = 3
        alarmThkAckInfoList.removeAll()
        self.alarmBtn?.isHidden = true
        //清除上次家庭
//        UserDefaults.standard.set(0, forKey: "TempHomeId")
        
        let sb = UIStoryboard(name: "Login", bundle: nil)
        let nc = sb.instantiateViewController(withIdentifier: "LoginNav") as! UINavigationController
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
    
    // MARK: - 弹窗完成
    
    func cameraListVCDismiss(_ homeId: String) {
        self.isShowCameraListVC = false
        
    }
    
    func topMorePINVCRemove() {
        
    }
    
    func topMorePINVCDisMiss() {
        self.isMorePINShowing = false
        checkNeedShow()
    }
    
    @objc func TopLoginVCWillDismiss() {
        //读取当前家庭
        if SGlobalVars.api.getCurUsername() != nil {
            homeInfoKey = "TempHomeId"+(SGlobalVars.api.getCurUsername())!
        } else {
            homeInfoKey = ""
        }
        loadTempHomeInfo()
    }
    
   @objc func TopLoginVCDidDismiss() {
        isLoginShowing = false
        isNeedLogin = false
        
        checkNeedShow()//检查需要弹窗
        SGlobalVars.homeHandle.homeInviteGetReq()
    }
    
    func TopHomeNeedVCDismiss() {
        
        isHomeNeedShowing = false
        
        loadTempHomeInfo()
        
        checkNeedShow()//检查需要弹窗
    }
    
    func TopAppGuideVCDismiss() {
        isAppGuideShowing = false
        checkNeedShow()//检查需要弹窗
    }
    
    // MARK: - 报警弹窗
    
    func addTimer() -> Void {
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector:#selector(checkAlarmThkAckInfoList), userInfo:nil,repeats:true)
            RunLoop.main.add(timer!, forMode:RunLoop.Mode.common)
        }
    }
    
    func removeTimer() -> Void {
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func checkAlarmThkAckInfoList() -> Void {
       
        var newAlarmThkAckInfoList = Array<TopThkAckInfo>.init()
        for thkAckInfo in alarmThkAckInfoList {
            thkAckInfo.coundown += 1
            
            if thkAckInfo.coundown < 15 {
                newAlarmThkAckInfoList.append(thkAckInfo)
            }
        }
        alarmThkAckInfoList = newAlarmThkAckInfoList
        if  self.alarmThkAckInfoList.count == 0 {
            self.alarmBtn?.isHidden = true
            self.removeTimer()
        }
    }
    
    @objc func alarmBtnDidClicked() -> Void {
  
       
        self.showAlarmAlertView((alarmThkAckInfoList.last)!)
        
    }
    
    func alarmAlertViewDidClickedLeftBtn(_ thkAckInfo: TopThkAckInfo) {
       
        
        var alarmThkAckInfoList = Array<TopThkAckInfo>.init()
        for alarm in self.alarmThkAckInfoList {
            if alarm.homeId == thkAckInfo.homeId {
                SGlobalVars.centerHandle.deviceCloseAlarmReq(thkAckInfo.homeId, deviceId: thkAckInfo.deviceId)
            }else {
                alarmThkAckInfoList.append(alarm)
            }
        }
        self.alarmThkAckInfoList = alarmThkAckInfoList
        if  self.alarmThkAckInfoList.count == 0 {
            self.removeTimer()
        }else {
            self.showAlarmAlertView((self.alarmThkAckInfoList.last)!)
        }
      
       
    }
    func chechShowOrHideAlarmBtn() -> Void {
        if  self.alarmThkAckInfoList.count > 0 {
            self.alarmBtn?.isHidden = false
            self.addTimer()
        }else {
            self.alarmBtn?.isHidden = true
            self.removeTimer()
        }
    }
    
    func alarmAlertViewDidClickedRightBtn(_ thkAckInfo: TopThkAckInfo, type: TopAlarmAlertViewRightBtnType, alarmAlertView: TopAlarmAlertView) {
        if type == .continueAlarm {
            alarmAlertView.type = .viewAlarm
            self.alarmAlertView?.isHidden = true
            self.chechShowOrHideAlarmBtn()
            return
        }else {
            let deviceList = NSMutableArray(array:SGlobalVars.roomHandle.getDeviceListAll(thkAckInfo.homeId)) as! [GLDeviceInfo]
            var isHasCamera = false
            for deviceInfo in deviceList {
                if deviceInfo.mainType == .camera || deviceInfo.mainType == .doorbell{
                    isHasCamera = true
                    break
                }
            }
            if isHasCamera {
                let sb = UIStoryboard(name: "TabBar", bundle: nil)
                
                let navc: TopNavc = sb.instantiateViewController(withIdentifier: "TopNavc") as! TopNavc
                navc.homeId = thkAckInfo.homeId
                navc.navigationBar.isTranslucent = false
                navc.modalPresentationStyle = .fullScreen
                self.isShowCameraListVC = true
                self.present(navc, animated: true) {
                    
                }
                self.cameraNavc = navc
               
                self.chechShowOrHideAlarmBtn()
              
                 self.alarmAlertView?.isHidden = true
                
            }else {
                alarmAlertView.text = NSLocalizedString("Notice", comment: "")+":  "+NSLocalizedString("There is no camera.", comment: "")
                alarmAlertView.textColor = UIColor.red
                alarmAlertView.type = .continueAlarm
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+4) {
                    var homeName = ""
                    
                    for homeCell in SGlobalVars.homeHandle.getHomeList() as! [GLHomeInfo] {
                        if homeCell.homeId == thkAckInfo.homeId {
                            homeName = homeCell.name
                        }
                    }
                    let deviceList = NSMutableArray(array:SGlobalVars.roomHandle.getDeviceListAll(thkAckInfo.homeId)) as! [GLDeviceInfo]
                    var deviceName: String = ""
                    for deviceInfo in deviceList {
                        if deviceInfo.deviceId == thkAckInfo.deviceId{
                            deviceName = deviceInfo.name
                            break
                        }
                    }
                    alarmAlertView.text = NSLocalizedString("Notice", comment: "")+":  "+homeName+NSLocalizedString(" is alarming!", comment: "")+"\n"+deviceName+NSLocalizedString("trigger", comment: "")
                    alarmAlertView.textColor = UIColor.glLabel()
                }
            }
        }
    }
    
    func alarmAlertViewDidClickedHideBtn(_ thkAckInfo: TopThkAckInfo) {
        self.chechShowOrHideAlarmBtn()
      
    }
    
    
    // MARK: - 家庭切换
    
    func loadTempHomeInfo() {//读取上次家庭
        
        SGlobalVars.curHomeInfo = nil
        
        //设置家庭
        let homeList = SGlobalVars.homeHandle.getHomeList() as! [GLHomeInfo]
        
        //
        if homeList.count != 0 {
            //读取上次家庭
            if UserDefaults.standard.string(forKey: homeInfoKey) != nil {
                let tempHomeId = UserDefaults.standard.string(forKey: homeInfoKey)!
                for homeCell in homeList {
                    if homeCell.homeId == tempHomeId {
                        updateHomeInfo(homeCell)
                        return
                    }
                }
            }
            
            //读取第一个
            for home in homeList {
                if home.homeId != nil {
                    updateHomeInfo(home)
                    break;
                    
                }
            }
        }
    }
    
    func updateHomeInfo(_ newHomeInfo: GLHomeInfo) {//切换当前家庭
        
        //设置当前家庭
        homeInfo = newHomeInfo
    }
    func initCameraView() {
        camLiveView = TopCameraLiveView()
        camLiveView.backgroundColor = .black

        camLiveView.isHidden = true
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panCamLiveView))
        camLiveView.contentView.addGestureRecognizer(pan)
        camLiveView.layer.cornerRadius = 24
        camLiveView.clipsToBounds = true
        self.view.addSubview(camLiveView)

    }
    @objc func panCamLiveView(_ pan: UIPanGestureRecognizer) -> Void {
          if isCamLiveViewAtMyView == false {
             return
          }
          switch pan.state {
          case .began:
              perPonit = pan.translation(in: self.view)
          case .changed:
              let currentPonit = pan.translation(in: self.view)
              let offSetX = currentPonit.x - perPonit.x
              let offSetY = currentPonit.y - perPonit.y
              perPonit = currentPonit
              camLiveViewFrame = CGRect.init(x: camLiveViewFrame.minX + offSetX, y:  camLiveViewFrame.minY + offSetY, width: camLiveViewFrame.width, height: camLiveViewFrame.height)
              camLiveView.frame = camLiveViewFrame
              break
          case .ended:
              let currentPonit = pan.translation(in: self.view)
              let offSetX = currentPonit.x - perPonit.x
              let offSetY = currentPonit.y - perPonit.y
               perPonit = currentPonit
              camLiveViewFrame = CGRect.init(x: camLiveViewFrame.minX + offSetX, y:  camLiveViewFrame.minY + offSetY, width: camLiveViewFrame.width, height: camLiveViewFrame.height)
               camLiveView.frame = camLiveViewFrame
              break
          default:
              break
          }
      }
 
}

