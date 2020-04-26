//
//  TopTemAndHumSetVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/21.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
enum TopTemAndHumSetVCType:Int {
    case TopTemAndHumSetVCTypeAdd
    case TopTemAndHumSetVCTypeEdit
}

protocol TopContentScollViewDelegate : class {
    
    
    func topContentScollViewDidClickedDeleteBtn(_ btn: UIButton)
    
}

class TopContentScollView: UIScrollView, UITextFieldDelegate{
    
    
    weak var theDelegate : TopContentScollViewDelegate?
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var lessBtn: UIButton!
    @IBOutlet weak var unitLabel: UILabel!
  
    @IBOutlet weak var selectTemAndHumLabel: UILabel!
    
    @IBOutlet weak var biggerBtn: UIButton!
    
    @IBOutlet weak var humBtn: UIButton!
    
    @IBOutlet weak var temBtn: UIButton!
    @IBOutlet weak var selectBitAndLittleLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    var _value: Int8 = 0
    var value: Int8?{
        set{
            _value = (newValue as Int8?)!
        }get{
            _value = Int8(inputTextField.text!)!
            return _value
        }
    }
    
    var _condition: TopCondition?
    var condition: TopCondition?{
        set{
            _condition  = newValue as TopCondition?
            
            if condition?.type ==  .humidity {
                humBtn.backgroundColor = APP_ThemeColor
                self.unitLabel.text = "%"
            }else{
                temBtn.backgroundColor = APP_ThemeColor
                 self.unitLabel.text = "℃"
            }
            if  condition?.isBigger == true{
                biggerBtn.backgroundColor = APP_ThemeColor
            }else{
                lessBtn.backgroundColor = APP_ThemeColor
            }
            
            
            self.inputTextField?.text = NSString.localizedStringWithFormat("%d", (condition?.thiValue)!) as String
        }
        get{
            return _condition
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        initSubViews()
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.contentOffset = CGPoint(x: 0, y: 120)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.contentOffset = CGPoint(x: 0, y: 0)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        NSLog("%@", string)
        
        if (!onlyInputTheNumber(string)) && (string != ""){
            GlobarMethod.notifyInfo(withStatus: NSLocalizedString("Only input numbers", tableName: "MacroPage"))
            return false
        }

      
        var newString: NSString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        if newString.intValue > 100{
            GlobarMethod.notifyInfo(withStatus: NSLocalizedString("Less than 100", tableName: "MacroPage"))
            return false

        }
        if(newString.length == 0){
            newString = "0"
        }
        
        if textField.text == "0" && newString.length > 0{
            textField.text = ""
        }

        condition?.thiValue = Int32(newString.intValue)


      
        
        
        
        return true
    }
    
    
    func onlyInputTheNumber(_ string: String) -> Bool {
        let numString = "[0-9]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", numString)
        let number = predicate.evaluate(with: string)
        return number
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = ((touches as NSSet).anyObject() as AnyObject)     //进行类  型转化
        
        let view:UIView = touch.view
        
        if view != inputTextField {
            inputTextField.endEditing(true)
        }
        
        
        
    }
    
    
    
    func initSubViews() -> Void {
        selectTemAndHumLabel.text = NSLocalizedString("Please select humidity or temperature", tableName: "MacroPage")
        selectBitAndLittleLabel.text = NSLocalizedString("Please select the comparison value", tableName: "MacroPage")
      
        temBtn.setTitle(NSLocalizedString("Temperture", tableName: "MacroPage"), for: .normal)
        temBtn.setTitleColor(UIColor.white, for: .normal)
        temBtn.layer.cornerRadius = 5
        temBtn.addTarget(self, action: #selector(btnDidClicked), for: .touchUpInside)
        temBtn.clipsToBounds = true
        temBtn.backgroundColor = UIColor.gray
        
        humBtn.setTitle(NSLocalizedString("Humidity", tableName: "MacroPage"), for: .normal)
        humBtn.addTarget(self, action: #selector(btnDidClicked), for: .touchUpInside)
        humBtn.setTitleColor(UIColor.white, for: .normal)
        humBtn.layer.cornerRadius = 5
        humBtn.clipsToBounds = true
        humBtn.backgroundColor = UIColor.gray
        
     
        
       
        
        biggerBtn.setTitle(NSLocalizedString("Higher", tableName: "MacroPage"), for: .normal)
        biggerBtn.addTarget(self, action: #selector(btnDidClicked), for: .touchUpInside)
        biggerBtn.setTitleColor(UIColor.white, for: .normal)
        biggerBtn.layer.cornerRadius = 5
        biggerBtn.clipsToBounds = true
        biggerBtn.backgroundColor = UIColor.gray
        
        lessBtn.setTitle(NSLocalizedString("Lower", tableName: "MacroPage"), for: .normal)
        lessBtn.addTarget(self, action: #selector(btnDidClicked), for: .touchUpInside)
        lessBtn.setTitleColor(UIColor.white, for: .normal)
        lessBtn.layer.cornerRadius = 5
        lessBtn.clipsToBounds = true
        lessBtn.backgroundColor = UIColor.gray
        
        deleteBtn.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteBtnDiclicked), for: .touchUpInside)
        deleteBtn.setTitleColor(UIColor.white, for: .normal)
        deleteBtn.layer.cornerRadius = 5
        deleteBtn.clipsToBounds = true
        deleteBtn.backgroundColor = APP_ThemeColor
      
        inputTextField.delegate = self
        inputTextField.tintColor = APP_ThemeColor
        
    }
    @objc func deleteBtnDiclicked(_ btn : UIButton) -> Void {
        theDelegate?.topContentScollViewDidClickedDeleteBtn(btn)
    }
   
    
    @objc func btnDidClicked(_ btn:UIButton) -> Void {
        btn.isSelected = true
        btn.backgroundColor = APP_ThemeColor
        if btn == temBtn {
            humBtn.backgroundColor = UIColor.gray
            condition?.type = .temperature
             self.unitLabel.text = "℃"
        } else if btn == humBtn {
            temBtn.backgroundColor = UIColor.gray
            condition?.type = .humidity
            self.unitLabel.text = "%"
        } else if btn == biggerBtn {
            lessBtn.backgroundColor = UIColor.gray
            
            condition?.isBigger = true
        } else if btn == lessBtn {
            biggerBtn.backgroundColor = UIColor.gray
            condition?.isBigger = false
        }
       
    }
    
    
    
}


class TopTemAndHumSetVC: TopSuperVC,UITextFieldDelegate,TopContentScollViewDelegate{
  
    
    
     @IBOutlet weak var contentScrollView: TopContentScollView!
   
  
    var condition: TopCondition?
    var type: TopTemAndHumSetVCType = .TopTemAndHumSetVCTypeAdd
    
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        contentScrollView.theDelegate = self
         condition = TopDataManager.shared.condition
        self.title = NSLocalizedString("H&T", tableName: "MacroPage")
        if (condition?.type == nil) {
            condition?.type = .temperature
            
        }
        
        
//        contentScrollView.showsVerticalScrollIndicator = false
//        contentScrollView.showsHorizontalScrollIndicator = false
//        contentScrollView.bounces = true
        
        if type == .TopTemAndHumSetVCTypeEdit {
            contentScrollView.frame = self.view.frame
        
            contentScrollView.deleteBtn.isHidden = false
        }else{
            contentScrollView.deleteBtn.isHidden = true
        }
        contentScrollView.condition = condition
        
        
       
        title = NSLocalizedString("T&H", tableName: "MacroPage")
        
        
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
      
        
        
       
    }
    
    
 
   
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
    }
    
    
    
    
 
    
    
    
    func macroConditionSetResp(notificatin: Notification) {//请求条件列表回复
        processTimerStop()
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            
            GlobarMethod.notifySuccess()
            self.navigationController?.popViewController(animated: true)
            
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    
    
    func deleteCondition(){
        
        let alertController = UIAlertController(title: NSLocalizedString("Delete",  comment: "")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: {
            (action) -> Void in
            let currentCondition: TopCondition  = TopDataManager.shared.condition!
         
            
            for vc in (weakSelf?.navigationController?.viewControllers)! {
                if vc.isKind(of: TopAditionVC.classForCoder()) {
                    let theVC: TopAditionVC = vc as! TopAditionVC
                    theVC.removeCondetion(currentCondition)
                    weakSelf?.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
            for vc in (weakSelf?.navigationController?.viewControllers)! {
                if vc.isKind(of: TopTriggerVC.classForCoder()) {
                    let theVC: TopTriggerVC = vc as! TopTriggerVC
                    theVC.removeCondetion(currentCondition)
                    weakSelf?.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
            
           
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func processTimerStart(){
        processTimerStart(3.0)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
    
    
    
    @IBAction func saveBtnDidCilcked(_ sender: Any) {
       
        condition?.thiValue = Int32(self.contentScrollView.value!)
      
        
        let  value = SGlobalVars.conditionHandle.getTempHumValueString(( self.contentScrollView.value!), bigger: (condition?.isBigger)!)
        
       NSLog("%d", self.contentScrollView.value!)
    
        condition?.value = value
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopAditionVC.classForCoder()) {
                let theVC: TopAditionVC = vc as! TopAditionVC
                let isAdded = theVC.addCondition(condition!)
                if isAdded{
                    navigationController?.popToViewController(vc, animated: true)
                    
                } else {
                     self.alertMessage(NSLocalizedString("The condition have been added", tableName: "MacroPage") )
                }
                return
            }
            
            if vc.isKind(of: TopTriggerVC.classForCoder()) {
                let theVC: TopTriggerVC = vc as! TopTriggerVC
                let isAdded = theVC.addCondition(condition!)
                if isAdded{
                    navigationController?.popToViewController(vc, animated: true)
                    
                } else {
                     self.alertMessage(NSLocalizedString("The condition have been added", tableName: "MacroPage") )
                }
                return
            }
        }
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopTriggerVC.classForCoder()) {
                let theVC = vc as! TopTriggerVC
                let isAdded = theVC.addCondition(condition!)
                print("isAdded", isAdded)
                navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
    }
    
    func deleteBtnDiclicked(_ btn: UIButton) -> Void{
        let alertController = UIAlertController(title: NSLocalizedString("Delete", value: "", comment: "")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        if (alertController.popoverPresentationController != nil) {
            alertController.popoverPresentationController?.sourceView = btn
            alertController.popoverPresentationController?.sourceRect = btn.bounds
        }
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: {
            (action) -> Void in
            
            let currentCondition: TopCondition  = TopDataManager.shared.condition!
            
            for vc in (weakSelf?.navigationController?.viewControllers)! {
                if vc.isKind(of: TopAditionVC.classForCoder()) {
                    let theVC: TopAditionVC = vc as! TopAditionVC
                    theVC.removeCondetion(currentCondition)
                    weakSelf?.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
            
            
            for vc in (weakSelf?.navigationController?.viewControllers)! {
                if vc.isKind(of: TopTriggerVC.classForCoder()) {
                    let theVC: TopTriggerVC = vc as! TopTriggerVC
                    theVC.removeCondetion(currentCondition)
                    weakSelf?.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
    }
    
    func topContentScollViewDidClickedDeleteBtn(_ btn: UIButton) {
        deleteBtnDiclicked(btn)
    }
    

   
    
}





