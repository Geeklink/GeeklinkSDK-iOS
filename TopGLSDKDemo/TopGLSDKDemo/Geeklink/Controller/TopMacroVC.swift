//
//  TopMacroVC.swift
//  Geeklink
//
//  Created by 列树童 on 2018/3/5.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
enum TopEditType: Int{
    case normal
    case move
    case delete
   
}
class TopMacroVC: TopSuperVC, UICollectionViewDelegate, UICollectionViewDataSource, TopMacroCollectionViewCellDelegate {
   
    
    
    
    let firstAddMacroKey = "firstAddMacroKey1"
    let firstShowMacroKey = "firstShowMacroKey1"
    let firstEditMacroKey = "firstEditMacroKey1"
    
    @IBOutlet weak var noCenterTipView: UIView!
    @IBOutlet weak var noCenterTipLabel: UILabel!
    @IBOutlet weak var toConfigureBtn: UIButton!
    @IBOutlet weak var tipAddView: UIView!
    @IBOutlet weak var tipAddMacroLabel: UILabel!
    @IBOutlet weak var setOpLabel: UILabel!
    @IBOutlet weak var opTipImgView: UIImageView!
    @IBOutlet weak var humanDetectLabel: UILabel!
    
    
    
    var firstCell: TopMacroCollectionViewCell?
    
    var isControling = false
    
    var editType = TopEditType.normal
    
    weak var rightBarButtonItem: UIBarButtonItem?
    var sound: SystemSoundID?
    var homeId = ""
    var macroList = [TopMacro]()
    var currentWidth: CGFloat = 0
   
    weak var delegate : TopHomeImgVCDelegate?
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - viewDidLoad
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Scenarios", comment: "")
        NotificationCenter.default.addObserver(self, selector: #selector(macroGetResp), name:NSNotification.Name("macroGetResp"), object: nil)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(onCollectionViewLongGesture))
        collectionView.addGestureRecognizer(longGesture)
      
        setCollectionViewlayout()
        setupRefresh(collectionView)
       // self.tipAddView.isHidden = true
        self.initTipView()
    
        let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "Macro_Mini", withExtension: "gif")!)
        opTipImgView.image = UIImage.gif(data: imageData)
        opTipImgView.backgroundColor = UIColor.clear
      
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        setCollectionViewlayout()
    }
  
    func setCollectionViewlayout() {
        if currentWidth == self.view.width {
            return
        }
        currentWidth = self.view.width
        self.collectionView.collectionViewLayout = GlobalGetCollectionViewLayout(self.view.frame.size.width, miniWidth: 140, heigh: 100, insetWidth: 8)
        self.collectionView.reloadData()
    }
    func checkFirstAddMacro() -> Void {
       
        if !UserDefaults.standard.bool(forKey: firstAddMacroKey) {
            let guianceView: TopGuidanceView = TopGuidanceView()
           
            guianceView.imageView?.image = UIImage(named: "scene_add_guide")
            
            guianceView.imageX = (self.view.width) - (guianceView.imageView?.image?.size.width)!
            guianceView.imageY =  UIApplication.shared.statusBarFrame.height - 4
            guianceView.labelAlignment = .right
            guianceView.key = firstAddMacroKey
            guianceView.tipLabel?.text = NSLocalizedString("Click the button to add scenario", tableName: "MacroPage")
            guianceView.frame = UIScreen.main.bounds
            for view in (self.navigationController?.view.subviews)!{
                if view.isKind(of: TopGuidanceView.classForCoder()){
                    guianceView.alpha = 0
                }
            }
            self.navigationController?.view.addSubview(guianceView)
        }
    }
    func checkFirstEditAndShowMacro() -> Void {
        
        
        if !UserDefaults.standard.bool(forKey: firstEditMacroKey) {
            let guianceView: TopGuidanceView = TopGuidanceView()
            
            guianceView.imageView?.image = UIImage(named: "scene_Edit_guide")
            
            guianceView.imageX = (self.view.width) - (guianceView.imageView?.image?.size.width)! - 30 - 16 - 2
            guianceView.imageY =  UIApplication.shared.statusBarFrame.height - 4
            guianceView.labelAlignment = .right
            guianceView.key = firstEditMacroKey
            guianceView.tipLabel?.text = NSLocalizedString("Click the button to edit scenario. When scenario icon shake, click the scenario icon go to edit scenario page, hold  scenario icon to move scenario", tableName: "MacroPage")
            guianceView.frame = UIScreen.main.bounds
            for view in (self.navigationController?.view.subviews)!{
                if view.isKind(of: TopGuidanceView.classForCoder()){
                    guianceView.alpha = 0
                }
            }
            self.navigationController?.view.addSubview(guianceView)
        }
        
        if self.firstCell == nil {
            return
        }
       
       
        
        if !UserDefaults.standard.bool(forKey: firstShowMacroKey) {
            
            let rect = (self.firstCell?.convert((self.firstCell?.bounds)!, to: self.navigationController?.view))!
            let guianceView: TopGuidanceView = TopGuidanceView()
            
            guianceView.imageView?.image = UIImage(named: "scene_icon_guide")
            
            guianceView.imageX = 0
            guianceView.imageY = rect.minY - 8
            guianceView.labelAlignment = .bottomCenter
            guianceView.key = firstShowMacroKey
            guianceView.tipLabel?.text = NSLocalizedString("Click the scenario to run the scenario, hold the scenario go to edit scenario page", tableName: "MacroPage")
            guianceView.frame = UIScreen.main.bounds
            for view in (self.navigationController?.view.subviews)!{
                if view.isKind(of: TopGuidanceView.classForCoder()){
                    
                    guianceView.alpha = 0
                }
            }
             self.navigationController?.view.addSubview(guianceView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //增加监听
        
        NotificationCenter.default.addObserver(self, selector: #selector(macroSetResp), name:NSNotification.Name("macroSetResp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(macroExecuteResp), name:NSNotification.Name("macroExecuteResp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(macroOrderResp), name:NSNotification.Name("macroOrderResp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(macroMultipleDeleteResp), name:NSNotification.Name("fromDeviceMacroMultiDelete"), object: nil)
        
      
//        if TopDataManager.shared.homeId != nil {
            self.homeId = TopDataManager.shared.homeId
//        }
        //获取家庭请求场景
        
       
        collectionView.reloadData()
        macroList = TopDataManager.shared.getMacroList(TopDataManager.shared.homeId)
        if macroList.count == 0 {
            self.getRefreshData()
        }else {
            self.collectionView.reloadData()
        }
        
        TopDataManager.shared.refreshHostDeviceInfo()
        refreshView()
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //移除监听事件
 
      
   
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("macroOrderResp"), object: nil)
 
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("macroExecuteResp"), object: nil)
    
        NotificationCenter.default.removeObserver(self, name:  NSNotification.Name("macroSetResp"), object: nil)
        
         NotificationCenter.default.removeObserver(self, name:  NSNotification.Name("fromDeviceMacroMultiDelete"), object: nil)
    }
    
    //MARK: - Notification
    
  
    @objc func macroSetResp(_ notificatin: Notification) -> Void {
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
            var newMacroList = Array<TopMacro>.init()
            for macro in self.macroList {
                if macro.isSelected == false {
                    newMacroList.append(macro)
                }
                self.macroList = newMacroList
                self.editType = .normal
                self.refreshView()
                self.collectionView.reloadData()
            }
        } else {
            GlobarMethod.notifyNetworkError()
        }
    }
    
    @objc func macroExecuteResp(notificatin: Notification) {
        //获取返回
       if isControling == false {
           return
        }
        isControling = false
        processTimerStop()
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
        } else {
            GlobarMethod.notifyFailed()
        }
        
        collectionView.reloadData()
        refreshView()
    }
    @objc func macroMultipleDeleteResp(_ notificatin: Notification) -> Void {
       
        processTimerStop()
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
           
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    
    @objc func macroOrderResp(notificatin: Notification) {//获取返回
        processTimerStop()
     
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    
    @objc func macroGetResp(notificatin: Notification) {
        
        //获取返回

        macroList.removeAll()
        
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok  {
            macroList = TopDataManager.shared.getMacroList(TopDataManager.shared.homeId)
            if macroList.count > 0 && SGlobalVars.homeHandle.getHomeAdminIsMe(homeId){
                checkFirstEditAndShowMacro()
            }
            collectionView.reloadData()
            refreshView()
        }
    }
    
    //MARK: - Notification
    
    override func getRefreshData() {
//        if  homeId == nil {
//            return
//        }
        TopDataManager.shared.homeId = homeId
     
       if SGlobalVars.macroHandle.macroGetReq(homeId) == 0 {
    
       } else {
         
       }
    }
    
    @objc func onCollectionViewLongGesture(longGesture: UILongPressGestureRecognizer) {
        let indexPath = collectionView.indexPathForItem(at: longGesture.location(in: collectionView))
        if editType == .delete{
            return
        }
        switch longGesture.state {
     
        case .began://开始长按
            
            AudioServicesPlaySystemSound(1519)
       
//            let time: TimeInterval = 0.2
//            weak var weakSelf = self
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
//                AudioServicesRemoveSystemSoundCompletion(1519)
//                AudioServicesDisposeSystemSoundID((weakSelf?.sound!)!)
//            }
            //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            
            if editType == .normal{
                if macroList.count == 0{
                    return
                }
                let macro:TopMacro =  macroList[indexPath!.row]
                TopDataManager.shared.macro = macro
                pushEditMacroVCWithMacro(macro)
                return
            }
          
           
            if indexPath != nil && indexPath?.row != macroList.count {
                collectionView.beginInteractiveMovementForItem(at: indexPath!)
            }
            break
        case .changed://变化位置

            collectionView.updateInteractiveMovementTargetPosition(longGesture.location(in: collectionView))
            break
        case .ended://结束
            collectionView.endInteractiveMovement()
            break
        default://其他
            collectionView.cancelInteractiveMovement()
            break
        }
    }
    
    func pushEditMacroVCWithMacro(_ macro: TopMacro){
        
        TopDataManager.shared.macro = macro
        let sb = UIStoryboard(name: "Macro", bundle: nil)
        let macroVc = sb.instantiateViewController(withIdentifier: "TopEditMacroVC")
        show(macroVc, sender: nil)
    }
    
    func shakeStatus(view: UIView, state: Bool) {//设置抖动动画
        if state {
         
            let rotation: CGFloat = 0.04
            let shake = CABasicAnimation(keyPath: "transform")
            shake.duration = 0.10
            shake.autoreverses = true
            shake.repeatCount  = MAXFLOAT
            shake.isRemovedOnCompletion = false
            shake.fromValue = NSValue(caTransform3D: CATransform3DRotate(view.layer.transform, -rotation, 0.0, 0.0, 1.0))
            shake.toValue = NSValue(caTransform3D: CATransform3DRotate(view.layer.transform, rotation, 0.0, 0.0, 1.0))
            view.layer.add(shake, forKey: "shakeAnimation")
        } else {
            view.layer.removeAnimation(forKey: "shakeAnimation")
        }
    }
    
    func homeVCAlertAddHost() {//提示添加主机
        
        let alertController = UIAlertController(title:NSLocalizedString("Hint",  tableName: "HomePage"), message: NSLocalizedString("To configure control center, need add host to home.", tableName: "HomePage", bundle: Bundle.main, value: "" , comment: ""), preferredStyle: .alert)
        weak var weakSelf = self
        let ok = UIAlertAction(title: NSLocalizedString("Add Host", tableName: "HomePage", bundle: Bundle.main, value: "",  comment: ""), style: .default, handler: {
            (action) -> Void in
            let sb = UIStoryboard(name: "DeviceGuide", bundle: nil)
            let camVc = sb.instantiateViewController(withIdentifier: "TopCenterTypeSelectVC") as! TopCenterTypeSelectVC
            camVc.homeInfo = SGlobalVars.curHomeInfo
            weakSelf?.show(camVc, sender: nil)
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func refreshView() {
        if SGlobalVars.roomHandle.isHomeHaveCenter(homeId) == false {
            noCenterTipView.isHidden = false
             tipAddView.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
            return
        }
        noCenterTipView.isHidden = true
        if macroList.count == 0 {
            self.editType = .normal
            let items2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(clickAddItem))
            tipAddView.isHidden = false
            navigationItem.rightBarButtonItems=[items2]
            return
        }
        
        noCenterTipView.isHidden = true
        if editType == .delete {
            
            let items1 = UIBarButtonItem.init(barButtonSystemItem: .trash, target: self, action:#selector(clickeDeleteSelectMacro))
            
            let items2 = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(clickCancelItem))
            
            if macroList.count == 0 {
                tipAddView.isHidden = false
                navigationItem.rightBarButtonItems=[items2]
            } else {
                tipAddView.isHidden = true
                navigationItem.rightBarButtonItems=[items2,items1]
            }
        }
        if editType == .move {
             let items1 = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action:#selector(doneItmDidClicked))
            navigationItem.rightBarButtonItems=[items1]
        }
        if editType == .normal {
            let items1 = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action:#selector(clickEidtItem))
            
            let items2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(clickAddItem))
            
            if macroList.count == 0 {
                tipAddView.isHidden = false
                navigationItem.rightBarButtonItems=[items2]
            } else {
                tipAddView.isHidden = true
                navigationItem.rightBarButtonItems=[items2,items1]
            }
            
        }
      
        
      
        if SGlobalVars.homeHandle.getHomeAdminIsMe(homeId){
            
             checkFirstAddMacro()
        }else{
            navigationItem.rightBarButtonItems = []
        }
       
       
    }
    @objc func doneItmDidClicked() -> Void {
        self.editType = .normal
        self.collectionView.reloadData()
        self.refreshView()
    }
    @objc func clickEidtItem(_ item: UIBarButtonItem) -> Void {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //设置动作
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            (UIAlertAction) -> Void in
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Batch Deletion", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.editType = .delete
            self.refreshView()
            self.collectionView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Move Sort", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.editType = .move
            self.refreshView()
            self.collectionView.reloadData()
        }))
        if (alert.popoverPresentationController != nil) {
                alert.popoverPresentationController?.barButtonItem = item
        }
        //显示弹窗
        present(alert, animated: true, completion: nil)
        
    }
    @objc func clickeDeleteSelectMacro() -> Void {
        var hasSelected = false
        for macro in self.macroList {
            if macro.isSelected {
                hasSelected = true
                break
            }
        }
        if hasSelected == false {
            GlobarMethod.notifyError(withStatus: NSLocalizedString("Please select the scenario that needs to be deleted.", tableName: "MacroPage"))
            return
        }
        
        let alert = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: NSLocalizedString("Are you sure you want to delete the selected Scenarios?", tableName: "MacroPage") , preferredStyle: .alert)
        
        //设置动作
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            (UIAlertAction) -> Void in
            
            self.editType = .delete
            self.refreshView()
            self.collectionView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default, handler: {
            (UIAlertAction) -> Void in
            
            if GlobarMethod.isDebug() {
                var macroIDList = [Int32]()
                for macro in self.macroList {
                    if macro.isSelected {
                        macroIDList.append(macro.macroID)
                    }
                }
          
                if SGlobalVars.macroHandle.macroMultipleDeleteReq(self.homeId, macroIdList: macroIDList) == 0 {
                    self.processTimerStart(3)
                }else {
                    GlobarMethod.notifyNetworkError()
                }
            }else {
                for macro in self.macroList {
                    if macro.isSelected {
                        SGlobalVars.macroHandle.macroSetReqDeleteSimpleMacro(self.homeId, macroInfo: (macro.macroInfo)!)
                    }
                }
                self.processTimerStart(3)
            }
           
            
        }))
       
        //显示弹窗
        present(alert, animated: true, completion: nil)
        
    }
    @objc func clickCancelItem() -> Void {
        for macro in macroList {
            macro.isSelected = false
        }
        self.editType = .normal
        self.collectionView.reloadData()
        self.refreshView()
    }
   
    func initTipView() {
        tipAddMacroLabel.text = NSLocalizedString("You don't have any scenes, please add some!", tableName: "MacroPage")
        setOpLabel.text = NSLocalizedString("You can set a device to present a certain state, Automatic triggering devices perform related operations", tableName: "MacroPage")
        
        opTipImgView.backgroundColor = UIColor.black
        
        humanDetectLabel.text = NSLocalizedString("Human body detector", tableName: "MacroPage")
        
        noCenterTipLabel.text = NSLocalizedString("Only the central controller has been configured, the scenario can be setted.", tableName: "MacroPage")
        toConfigureBtn.setTitle("  "+NSLocalizedString("To configure", tableName: "MacroPage")+"  ", for: .normal)
        toConfigureBtn.addTarget(self, action: #selector(setCenterDeviceBtnDidClicked), for: .touchUpInside)
        toConfigureBtn.setTitleColor(APP_ThemeColor, for: .normal)
        toConfigureBtn.layer.cornerRadius = 3
        toConfigureBtn.layer.borderColor = APP_ThemeColor.cgColor
        toConfigureBtn.layer.borderWidth = 0.5
        toConfigureBtn.clipsToBounds = true
    }
    
    //MARK: - Notification
    
  
    
    @objc func clickAddItem() {
        
//        let macro = TopMacro()
//        macro.autoOnOff = false
//        macro.pushOnOff = false
//        macro.icon = 0
//        macro.action = .insert
//        macro.name = NSLocalizedString("Go Home", tableName: "MacroPage")
//        TopDataManager.shared.macro = macro
        let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
        switch hostSubType {
        case .thinker, .thinkerPro:
            if self.macroList.count >= 100{
                GlobarMethod.notifyFullError()
                return
            }
        case .thinkerMini:
            if self.macroList.count >= 16{
                GlobarMethod.notifyFullError()
                return
            }
        default:
            break
        }
       
        self.performSegue(withIdentifier: "TopMacroTypeVC", sender: nil)
    }
    
    
    @objc func setCenterDeviceBtnDidClicked() -> Void {
        if SGlobalVars.homeHandle.getHomeAdminIsMe(homeId) {//管理员
            //如果有主机
            if SGlobalVars.roomHandle.getHostList(homeId).count != 0 {
                //前往设置
                let sb = UIStoryboard(name: "Home", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "TopHomeCenterVC") as! TopHomeCenterVC
                let tabbVC = tabBarController as! TopTabBC
                vc.homeInfo = tabbVC.homeInfo
                self.show(vc, sender: nil)
               
            } else {
                //提示添加思想者
                homeVCAlertAddHost()
            }
        } else {//普通用户
            //提示需要管理员
            alertNeedAdmin()
        }
    
    }
    
    // MARK: - 本地方法
    
    @objc func implementMacro(_ macro: TopMacro) {
        if SGlobalVars.macroHandle.macroExecuteReq(TopDataManager.shared.homeId, macroId: macro.macroID) == 0 {
            isControling = true
            processTimerStart(3)
        } else {
            isControling = false
            GlobarMethod.notifyFailed()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return macroList.count
    }
    
    // MARK: - UICollectionView MoveItem
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var macro : TopMacro!
        if indexPath.row < macroList.count{
            macro = macroList[indexPath.row]
        }else{
           macro = TopMacro()
        }
        
        let cell : TopMacroCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopMacroCollectionViewCell", for: indexPath) as! TopMacroCollectionViewCell
        if indexPath.row == 0 {
            self.firstCell = cell
        }
        cell.selectImgView.isHidden = self.editType != .delete
        cell.macro = macro
        cell.isEditing = self.editType != .normal
        cell.indexPath = indexPath
        cell.delegate = self
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        shakeStatus(view: cell, state: self.editType == .move)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.editType == .normal || self.editType == .move {
            let cell = collectionView.cellForItem(at: indexPath) as! TopMacroCollectionViewCell
            cell.contentView.backgroundColor = UIColor.clear
            GlobarMethod.addAnimation(to: cell)
            let macro = cell.macro
            pushEditMacroVCWithMacro(macro!)
            
        } else {
            
            //统计选中数量
            var selectCount = 0
            for macro in macroList {
                if macro.isSelected {
                    selectCount += 1
                }
            }
            
            //判读选择数量
            let macro = macroList[indexPath.row]
            if (selectCount >= 10) && (macro.isSelected == false) {
                GlobarMethod.notifyInfo(withStatus: NSLocalizedString("Delete up to 10 scenarios at a time", tableName: "MacroPage"))
            } else {
                macro.isSelected = !macro.isSelected
                collectionView.reloadData()
            }
        }
    }
    
    func macroCollectionViewCellDidClickedIcon(_ cell: TopMacroCollectionViewCell) {
        
        //延时
       
        GlobarMethod.addAnimation(to: cell)

        implementMacro(cell.macro!)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let oldIndex = sourceIndexPath.row;
        var newIndex = destinationIndexPath.row;
        
        if (newIndex == macroList.count) {
            newIndex = macroList.count-1;
        }
        
        //修改位置
        let object = macroList[oldIndex]
        macroList.remove(at: oldIndex)
        macroList.insert(object, at: newIndex)
        
        //创建Order合集
        var orderList = Array<GLOrderInfo>()
        var i: Int32 = 0
       
        for macro in macroList {
            let orderInfo = GLOrderInfo(id: macro.macroID, order: i)
            orderList.append(orderInfo!)
            i = i+1
        }
        
        //更新Order
        if SGlobalVars.macroHandle.macroOrderReq(homeId, list: orderList) == 0 {
           
            processTimerStart(3)
        } else {
           
            GlobarMethod.notifyFailed()
        }
       
        collectionView.reloadData()
    }
    
    //MARK: - Notification
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .lightGray
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .clear
    }
    
    
}
