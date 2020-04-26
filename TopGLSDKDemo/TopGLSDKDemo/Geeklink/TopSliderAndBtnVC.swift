//
//  TopCurtainVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/4/28.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
enum TopSliderAndBtnVCType: Int {
    case addTask
    case editTask
}
class TopSliderAndBtnVC: TopSuperVC {
    @IBOutlet weak var controlSlider: UISlider!
    
  
    var type: TopSliderAndBtnVCType = .addTask
    @IBOutlet weak var deleteBtn: UIButton!
    var task: TopTask?
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var openBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        task = TopDataManager.shared.task
        
        initSubViews()
        let rightBarButtonItem: UIBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(rightBarButtonItemDidClicked))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        

    }
    
    func initSubViews() -> Void {
        
        
        if type == .addTask {
            
            if task?.device?.mainType == .geeklink {
                 task?.value =   SGlobalVars.actionHandle.getCurtainValueString(0)
            }else {
                 task?.value =  task?.device?.slaveType == .curtain ? SGlobalVars.actionHandle.getCurtainValueString(0) : SGlobalVars.actionHandle.getLightSwitchActionValue(GLLightSwitchState(ctrlOnOff: true, onOff: true, light: 100))
            }
            
           
            
        }
        if task?.device?.mainType == .geeklink {
            self.closeBtn.setImage(UIImage(named: "ui_icon_curtainclose_selected"), for: .normal)
            self.closeBtn.setImage(UIImage(named: "ui_icon_curtainclose_select"), for: .selected)
            closeLabel.text = NSLocalizedString("Close", comment: "")
            closeLabel.textColor = UIColor.black
            
            self.openBtn.setImage(UIImage(named: "ui_icon_curtainopen_selected"), for: .normal)
            self.openBtn.setImage(UIImage(named: "ui_icon_curtainopen_select"), for: .selected)
            
            openLabel.text = NSLocalizedString("Open", comment: "")
            openLabel.textColor = UIColor.black
        }
        
        else {
            if task?.device?.slaveType == .curtain  {
                self.closeBtn.setImage(UIImage(named: "ui_icon_curtainclose_selected"), for: .normal)
                self.closeBtn.setImage(UIImage(named: "ui_icon_curtainclose_select"), for: .selected)
                closeLabel.text = NSLocalizedString("Close", comment: "")
                closeLabel.textColor = UIColor.black
                
                self.openBtn.setImage(UIImage(named: "ui_icon_curtainopen_selected"), for: .normal)
                self.openBtn.setImage(UIImage(named: "ui_icon_curtainopen_select"), for: .selected)
                
                openLabel.text = NSLocalizedString("Open", comment: "")
                openLabel.textColor = UIColor.black
            
            
            }else{
                self.closeBtn.setImage(UIImage(named: "ui_icon_lightoff_selected"), for: .normal)
                self.closeBtn.setImage(UIImage(named: "ui_icon_lightoff_select"), for: .selected)
               
                
                self.openBtn.setImage(UIImage(named: "ui_icon_lighton_selected"), for: .normal)
                self.openBtn.setImage(UIImage(named: "ui_icon_lighton_select"), for: .selected)
               
                
                closeLabel.text = NSLocalizedString("Light off", tableName: "MacroPage")
                closeLabel.textColor = UIColor.black
                
                openLabel.text = NSLocalizedString("Light on", tableName: "MacroPage")
                openLabel.textColor = UIColor.black
                
              }
        }
     
        progressLabel.text = NSLocalizedString("0%", comment: "")
        progressLabel.backgroundColor = APP_ThemeColor
        progressLabel.layer.cornerRadius = 12
        progressLabel.clipsToBounds = true
        
        controlSlider.addTarget(self, action: #selector(controlSliderValueChanged), for: .valueChanged)
        controlSlider.thumbTintColor = APP_ThemeColor
        controlSlider.tintColor = APP_ThemeColor
        if task?.device?.mainType == .geeklink {
            let value: Float = Float(SGlobalVars.actionHandle.getCurtainState(task?.value))
            controlSlider.value = value
            
            if value == 0 {
                self.openLabel.textColor = APP_ThemeColor
                self.openBtn.isSelected = true
            }else if value == 100{
                self.closeLabel.textColor = APP_ThemeColor
                self.closeBtn.isSelected = true
            }
        }else {
            if task?.device?.slaveType == .curtain{
                let value: Float = Float(SGlobalVars.actionHandle.getCurtainState(task?.value))
                controlSlider.value = value
                
                if value == 0 {
                    self.openLabel.textColor = APP_ThemeColor
                    self.openBtn.isSelected = true
                }else if value == 100{
                    self.closeLabel.textColor = APP_ThemeColor
                    self.closeBtn.isSelected = true
                }
            }else {
                let sightSwitchState: GLLightSwitchState  = SGlobalVars.actionHandle.getLightSwitchActionInfo(task?.value)
                controlSlider.value = Float(sightSwitchState.light)
                
                if sightSwitchState.ctrlOnOff == true {
                    if sightSwitchState.onOff  == true{
                        self.openLabel.textColor = APP_ThemeColor
                        self.openBtn.isSelected = true
                    }else {
                        self.closeLabel.textColor = APP_ThemeColor
                        self.closeBtn.isSelected = true
                    }
                    self.controlSlider.tintColor = UIColor.black
                    
                }else {
                    self.controlSlider.tintColor = APP_ThemeColor
                }
            }
            
        }
       
        self.progressLabel.text = String(format: "%.0f", controlSlider.value)+"%"
        
        self.deleteBtn.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
        self.deleteBtn.setTitleColor(APP_ThemeColor, for: .normal)
        self.deleteBtn.layer.borderColor = APP_ThemeColor.cgColor
        self.deleteBtn.layer.borderWidth = 1
        self.deleteBtn.layer.cornerRadius = 22
        self.deleteBtn.clipsToBounds = true
        self.deleteBtn.isHidden = true

     
    }
    @objc func rightBarButtonItemDidClicked() -> Void {

       
        let task: TopTask  = TopDataManager.shared.task!
        if task.device?.mainType == .geeklink {
            let value: Int8 = Int8(controlSlider.value)
            task.value = SGlobalVars.actionHandle.getCurtainValueString(value)
        }else {
            if task.device?.slaveType == .curtain{
                let value: Int8 = Int8(controlSlider.value)
                task.value = SGlobalVars.actionHandle.getCurtainValueString(value)
            }
            else {
                var colOnOff = false
                var onOff = false
                let brightness: Int32 = Int32(controlSlider.value)
                if closeBtn.isSelected {
                    colOnOff = true
                    onOff = false
                }else if openBtn.isSelected {
                    colOnOff = true
                    onOff = true
                }
                task.value = SGlobalVars.actionHandle.getLightSwitchActionValue(GLLightSwitchState(ctrlOnOff: colOnOff, onOff: onOff, light: brightness))
                
            }
        }
        
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopAddTaskVC.classForCoder()) {
                let theVC: TopAddTaskVC = vc as! TopAddTaskVC
                theVC.addTask(task: task)
                
                navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
    }
    @objc func controlSliderValueChanged(_ slider: UISlider) -> Void {
       
        self.progressLabel.text = String(format: "%.0f", slider.value)+"%"
        
        self.openBtn.isSelected = false
        self.openLabel.textColor = UIColor.black
        self.closeBtn.isSelected = false
        self.closeLabel.textColor = UIColor.black
        
        controlSlider.tintColor = APP_ThemeColor
        if task?.device?.slaveType == .curtain {
            if controlSlider.value == 100.0 {
                self.closeBtn.isSelected = true
                self.closeLabel.textColor = APP_ThemeColor
            }else if  controlSlider.value == 0.0 {
                self.openBtn.isSelected = true
                self.openLabel.textColor = APP_ThemeColor
            }
        }
        
        
    }
    @IBAction func closeBtnDidClicked(_ sender: Any) {
        self.openBtn.isSelected = false
        self.openLabel.textColor = UIColor.black
        self.closeBtn.isSelected = true
        self.closeLabel.textColor = APP_ThemeColor
        
        if task?.device?.slaveType == .curtain {
            controlSlider.value = 100
            self.progressLabel.text = String(format: "%.0f", controlSlider.value)+"%"
        }else {
            controlSlider.tintColor = UIColor.black
            self.progressLabel.text = NSLocalizedString("OFF", comment: "")
        }
       
    }
    @IBAction func openBtnDidClicked(_ sender: Any) {
        self.openBtn.isSelected = true
        self.openLabel.textColor = APP_ThemeColor
        self.closeBtn.isSelected = false
        self.closeLabel.textColor = UIColor.black
        
        if task?.device?.slaveType == .curtain {
           controlSlider.value = 0
           self.progressLabel.text = String(format: "%.0f", controlSlider.value)+"%"
        }else {
            controlSlider.tintColor = UIColor.black
            self.progressLabel.text = NSLocalizedString("ON", comment: "")
        }
        
       
    }
    @IBAction func deleteBtnDidClicked(_ sender: Any) {
    }
    

  

}
