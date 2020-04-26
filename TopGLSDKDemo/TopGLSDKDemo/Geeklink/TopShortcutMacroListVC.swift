//
//  TopShortcutMacroListVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2018/12/28.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit
import Intents
import IntentsUI
@available(iOS 12.0, *)
class TopShortcutMacroListVC:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, INUIAddVoiceShortcutViewControllerDelegate {
    
    @IBOutlet weak var tipView: UIView!
    
    @IBOutlet weak var tipLabel: UILabel!
     var addVoiceShortcutVC :INUIAddVoiceShortcutViewController!
    @IBOutlet weak var collectionView: UICollectionView!
    
   
    var currentWidth: CGFloat = 0
    var macroList = Array<TopMacro>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Scenario List", tableName: "MorePage")
        collectionView.register(UINib(nibName: "TopHomeVCMacroCLCell", bundle: nil), forCellWithReuseIdentifier: "TopHomeVCMacroCLCell")
        
        self.tipView.layer.cornerRadius = 24
        self.tipView.clipsToBounds = true
        self.tipLabel.text = NSLocalizedString("No Scenario, please go to \"Home\" to add.", tableName: "MorePage")
        
      
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRefreshData()
        NotificationCenter.default.addObserver(self, selector: #selector(macroOrderResp), name:NSNotification.Name("macroOrderResp"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("macroOrderResp"), object: nil)
    }
    
    @objc func macroOrderResp(notificatin: Notification) {//获取返回
        processTimerStop()
        
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
            
        } else {
            GlobarMethod.notifyFailed()
        }
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if currentWidth == self.view.width {
            return
        }
        currentWidth = self.view.width
        setCollectionViewLayout()
        
    }
    func setCollectionViewLayout(){
        self.collectionView.collectionViewLayout = getCollectionViewLayout(self.view.width, miniWidth: 140, heigh: 44, insetWidth: 16)
        
        self.collectionView.reloadData()
    }
    func getCollectionViewLayout(_ totleWidth: CGFloat, miniWidth: CGFloat, heigh: CGFloat, insetWidth: CGFloat) -> UICollectionViewFlowLayout {
        var width = miniWidth
        var theHeight = heigh
        if totleWidth >= 768 {
            width = miniWidth * 1.25
            theHeight = heigh * 1.25
        }
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        
        var itemCol: Int = 0
        itemCol = Int((totleWidth - insetWidth * 2 + 16) / (width + 16))
        
        let itemW: CGFloat = CGFloat(totleWidth - CGFloat(itemCol - 1) * 16 - insetWidth * 2) / CGFloat(itemCol)
        
        layout.itemSize = CGSize(width: itemW, height: theHeight)
        layout.sectionInset = UIEdgeInsets.init(top: insetWidth, left: insetWidth, bottom: insetWidth, right: insetWidth)
        layout.headerReferenceSize = CGSize.init(width: self.view.width, height: 52)
        return layout
    }
    
    override func getRefreshData() {
        macroList = TopDataManager.shared.getMacroList(TopDataManager.shared.homeId)
        self.tipView.isHidden = macroList.count != 0
        
        
        self.collectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            for view in reusableview.subviews {
                if view.isKind(of: UILabel.classForCoder())  {
                    let label = view as! UILabel
                    label.text = NSLocalizedString("Hint", comment: "")+": "+NSLocalizedString("Click on the scene for voice recording.", tableName: "Shortcuts")
                    break
                }
            }
            return reusableview
        }
        let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        return reusableview
    }
 
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return macroList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopHomeVCMacroCLCell", for: indexPath) as! TopHomeVCMacroCLCell
        cell.setMacro(macroList[indexPath.row])
       
        return cell
    }
   
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //设置高亮
        let macro = macroList[indexPath.row]
        

        
        let intent  = TopIntent()
        //intent.homeId = Globa
        
        intent.homeID = TopDataManager.shared.homeId
        intent.iD = String.init(format: "%d", macro.macroID)
        intent.action = "0"
        intent.md5 = "0"
        intent.subId = "0"
        intent.oem = String.init(format: "%d", Int(App_Company.rawValue))
        intent.remarks = "Execution"
        intent.type = "macro"
        let interaction: INInteraction  = INInteraction.init(intent: intent, response: nil)
        interaction.identifier = String.init(format: "%d", macro.macroID)
        
        interaction.donate { (error) in
            
        }
        
        guard let shortcut = INShortcut.init(intent: intent) else { return }
        
        let controller = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        controller.delegate = self
        addVoiceShortcutVC = controller
        self.present(controller, animated: true) {
            
        }
        
        //延时
    }
    @available(iOS 12.0, *)
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        addVoiceShortcutVC.dismiss(animated: true) {
            
        }
        GlobarMethod.notifySuccess()
        for vc in (self.navigationController?.viewControllers)! {
            if vc is TopSiriShortCutsListVC {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        
        
        
    }
    
    @available(iOS 12.0, *)
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        addVoiceShortcutVC.dismiss(animated: true) {
            
        }
    }
    
}


    


