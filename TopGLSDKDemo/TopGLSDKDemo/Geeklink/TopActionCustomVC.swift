//
//  TopActionCustomVC.swift
//  Geeklink
//
//  Created by Lieshutong on 2018/3/22.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopActionCustomVC: TopSuperVC, UICollectionViewDelegate, UICollectionViewDataSource {
    var type: TopActionType = .macroAction
    var homeInfo = GLHomeInfo()//必须填
   // var macroInfo = GLMacroInfo()//必须填
    var deviceInfo = GLDeviceInfo()//必须填
    var oldActionInfo = GLActionInfo()//修改时需要填, 添加时不需要填
    
    var keyList = [GLKeyInfo]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置文本
        title = deviceInfo.name
        
        //设置宫格图样式
        let screenW = UIScreen.main.bounds.size.width
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        if UIDevice.current.userInterfaceIdiom == .pad {//iPad
            layout.sectionInset = UIEdgeInsets(top: 35.0, left: 0.0, bottom: 35.0, right: 0.0)
            layout.itemSize = CGSize(width: 100*(screenW/320), height: 140)
        } else {//iPhone
            layout.sectionInset = UIEdgeInsets(top: 30.0, left: 0.0, bottom: 30.0, right: 0.0)
            layout.itemSize = CGSize(width: 100*(screenW/320), height: 120)
        }
        collectionView.collectionViewLayout = layout
        
      
    }

   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //增加监听事件
        NotificationCenter.default.addObserver(self, selector: #selector(reloadKeyList), name:NSNotification.Name("thinkerKeyGetResp"), object: nil)
       
        
        //刷新数据
        reloadKeyList()
        getRefreshData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //移除监听事件
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("thinkerKeyGetResp"), object: nil)
    
    }
    override func getRefreshData() {
        SGlobalVars.rcHandle.thinkerKeyGetReq(homeInfo.homeId, deviceIdSub: deviceInfo.deviceId)
    }
    @objc func reloadKeyList() {
        keyList = SGlobalVars.rcHandle.getKeyList(homeInfo.homeId, deviceId: deviceInfo.deviceId) as! [GLKeyInfo]
        collectionView.reloadData()
    }
    
    
 
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return keyList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = UIDevice.current.userInterfaceIdiom == .pad ? "CellPad" : "CellPhone"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TopCustomKeyVCCell
        
        let keyInfo = keyList[indexPath.row]
        cell.textLbl.text = keyInfo.name
        cell.imgView.image = GlobarMethod.getKeyIconSelect(keyInfo.icon)
        cell.imgView.highlightedImage = GlobarMethod.getKeyIconSelect(keyInfo.icon)
        return cell
    }
    
    func collectionView(_ collectionVsiew: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionVsiew.deselectItem(at: indexPath, animated: true)
        
        let value = SGlobalVars.actionHandle.getRCValueString(Int8(keyList[indexPath.row].keyId))
        
        switch type {
        case .macroAction:
           
            let task: TopTask  = TopDataManager.shared.task!
            task.value = value
            for vc in (navigationController?.viewControllers)! {
                if vc.isKind(of: TopAddTaskVC.classForCoder()) {
                    let theVC: TopAddTaskVC = vc as! TopAddTaskVC
                    theVC.addTask(task: task)
                    navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        default:
            let smartPiTimerAction  = TopDataManager.shared.smartPiTimerAction!
            smartPiTimerAction.value = value!
            
            for vc in (navigationController?.viewControllers)! {
                if vc.isKind(of: TopAddOREditTimingVC.classForCoder()) {
                    let theVC: TopAddOREditTimingVC = vc as! TopAddOREditTimingVC
                    theVC.addOrUpdateTask(smartPiTimerAction)
                    navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
      

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
