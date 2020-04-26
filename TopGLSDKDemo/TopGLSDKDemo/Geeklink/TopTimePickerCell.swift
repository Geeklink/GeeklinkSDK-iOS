//
//  TopTimePickerCell.swift
//  Geeklink
//
//  Created by YanFeiFei on 2019/1/21.
//  Copyright © 2019 Geeklink. All rights reserved.
//

import UIKit
protocol TopTimePickerCellDelegate : class {
    func timePickerCellPick(_ titalMin: Int32)
    
}
class TopTimePickerCell: UITableViewCell {
    @IBOutlet weak var pickerView: UIDatePicker!
    weak var delegate: TopTimePickerCellDelegate?
    var totalMin: Int32 = 0
    var min: Int32 = 0
    var hour: Int32 = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        pickerView.addTarget(self, action: #selector(onDatePickerChange), for: .valueChanged)
        self.updatePicker(totalMin)
    }
    @objc func onDatePickerChange(_ datePicker: UIDatePicker) {
        //时间选择
       let beginDate = datePicker.date
       let calendar = NSCalendar(identifier: .gregorian)
        let startTime = (calendar?.component(.hour, from: beginDate))!*60 + (calendar?.component(.minute, from: beginDate))!
        self.delegate?.timePickerCellPick(Int32(startTime))
    }
    
    func updatePicker(_ totalMin: Int32) -> Void {
        self.pickerView.date = GlobarMethod.time(toDate: totalMin)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    
    
    

    
 
   
}


