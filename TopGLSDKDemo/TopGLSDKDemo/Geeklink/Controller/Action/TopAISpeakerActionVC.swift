
//
//  TopAISpeakerActionVC.swift
//  JiuLing
//
//  Created by YanFeiFei on 2018/11/8.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit
enum TopAISpeakerActionVCType:Int {
    case TopAISpeakerActionVCTypeAdd
    case TopAISpeakerActionVCTypeEdit
}
class TopAISpeakerActionVC: TopSuperVC , UITextViewDelegate{
    var type = TopAISpeakerActionVCType.TopAISpeakerActionVCTypeAdd
    @IBOutlet weak var topTipLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomTipLabel: UILabel!
    var task: TopTask!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.task = TopDataManager.shared.task!
        self.initSubViews()
        
    }
    @objc func doneBtnDidClicked() -> Void {
        if self.textView.text.count == 0 {
            GlobarMethod.notifyError(withStatus: NSLocalizedString("Contents can not be empty.", tableName: "MacroPage"))
            return
        }
        
        let task: TopTask  = TopDataManager.shared.task!
        task.value = "0"
        task.voice = self.textView.text
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopAddTaskVC.classForCoder()) {
                let theVC: TopAddTaskVC = vc as! TopAddTaskVC
                theVC.addTask(task: task)
                
                navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        
    }
    func initSubViews() -> Void {
        let rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneBtnDidClicked))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        topTipLabel.text = NSLocalizedString("Please input the contents of the broadcast.", tableName: "MacroPage")
        
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        self.textView.layer.borderWidth = 1
        self.textView.delegate = self
        self.textView.text = task.voice
        textView.becomeFirstResponder()
        
       
        self.bottomTipLabel.textColor = APP_ThemeColor
        self.bottomTipLabel.isHidden = true
       // self.bottomTipLabel.text = String.init(format: "%d", 48 - self.textView.text.utf8.count)
        
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if  (TopDataManager.shared.stringIsEmoji(text) == true) {
            GlobarMethod.notifyError(withStatus: NSLocalizedString("Inputting illicit", comment: ""))
            return false
        }
        
        let count = text.utf8.count + textView.text.utf8.count
        if count > 48 {
            GlobarMethod.notifyError(withStatus: NSLocalizedString("Text is too long", tableName: "MacroPage"))
            return false
        }
      // self.bottomTipLabel.text = String.init(format: "%d", textTotalCount - count)
       return true
    }
    
    
    


}
