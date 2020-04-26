//
//  TopSirenTimePickerVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2019/4/24.
//  Copyright © 2019 Geeklink. All rights reserved.
//

import UIKit
enum TopSirenTimePickerVCType:Int {
    case add
    case edit
  
}
class TopSirenTimePickerVC: TopSuperVC, UIPickerViewDelegate, UIPickerViewDataSource {
  
    
   var type = TopSirenTimePickerVCType.add

    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    var task: TopTask!
    var secound: Int = 10
    override func viewDidLoad() {
        super.viewDidLoad()
       
        task = TopDataManager.shared.task
        self.title = NSLocalizedString("Siren", comment: "")
        if task.value.count > 2{
            secound = Int(SGlobalVars.actionHandle.getSirenSecond(task.value))
        }
        self.pickerView.selectRow(secound + 15000 - 1, inComponent: 0, animated: false)
        self.textLabel.text = NSLocalizedString("Ringing the doorbell time", tableName: "MacroPage")+": "+String.init(format: "%d", secound)+NSLocalizedString("S", comment: "")
      
       
        self.confirmBtn.backgroundColor = APP_ThemeColor
        self.confirmBtn.layer.cornerRadius = 22
        self.confirmBtn.setTitle(NSLocalizedString("Confirm", comment: ""), for: UIControl.State.normal)

    }
    @IBAction func clickConfirmBtn(_ sender: Any) {
        let value = SGlobalVars.actionHandle.getSirenValueString(Int16(secound))
        
        
        task?.value = value
        task?.delay = 0
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopAddTaskVC.classForCoder()) {
                let theVC: TopAddTaskVC = vc as! TopAddTaskVC
                theVC.addTask(task: task!)
                navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
    }
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 30000
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let dateLabel = UILabel()
        
        // 字体大小
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textAlignment = .center
        
        dateLabel.text = String.init(format: "%d", row % 300 + 1)+" "+NSLocalizedString("S", comment: "")

        return dateLabel
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        secound =  row % 300 + 1
         self.textLabel.text = NSLocalizedString("Ringing the doorbell time", tableName: "MacroPage")+": "+String.init(format: "%d", secound)+NSLocalizedString("S", comment: "")
    }
    

}
