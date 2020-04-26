//
//  TopPlugActionView.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/7/31.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopSpecialActionViewDelegate : class {
    func specialActionViewDidClickedBtn(_ index: Int32) -> Void;
}
class TopSpecialActionView: UIView {
    
    var quickBtnList = [UIButton]()
    var quickLabelList = [UILabel]()
    weak var delegate: TopSpecialActionViewDelegate?
    var _deviceInfo: GLDeviceInfo =  GLDeviceInfo()
    var deviceInfo: GLDeviceInfo! {
        set{
            _deviceInfo = newValue
           
            var roomQuickItemList =  [TopRoomQuickItem]()
          
            let item = TopRoomQuickItem()
            item.name = NSLocalizedString("ON", comment: "")
            item.icon =  GlobarMethod.getKeyIconSelect(.CTLSWITCH)
            item.iconHL =  GlobarMethod.getKeyIconSelect(.CTLSWITCH)
            item.key = 0
            roomQuickItemList.append(item)
            
            
            let itemOff = TopRoomQuickItem()
            itemOff.name = NSLocalizedString("OFF", comment: "")
            itemOff.icon =  GlobarMethod.getKeyIconSelect(.CTLSWITCH)
            itemOff.iconHL =  GlobarMethod.getKeyIconSelect(.CTLSWITCH)
            itemOff.key = 1
            roomQuickItemList.append(itemOff)
            self.homeQuickItemList = roomQuickItemList
        }
        get{
            return _deviceInfo
        }
    }
    
    var everyRowCount: Int = 3
    var _homeQuickItemList =  [TopRoomQuickItem]()
    var homeQuickItemList: Array<TopRoomQuickItem> {
        set{
            _homeQuickItemList = newValue
            
            
            var index: Int = 0
            
            
            for roomQuickItem in _homeQuickItemList {
                if(index >= quickBtnList.count){
                    let btn: UIButton = UIButton()
                    
                    btn.tag = roomQuickItem.key
                    btn.isSelected = false
                    btn.addTarget(self, action: #selector(quickBtiDidClicked) , for: .touchUpInside)
                    btn.setImage(roomQuickItem.icon, for: .highlighted)
                    btn.setImage(roomQuickItem.iconHL, for: .normal)
                    self.addSubview(btn)
                    
                    btn.setImage(roomQuickItem.iconHL, for: .selected)
                    quickBtnList.append(btn)
                } else {
                    let btn = quickBtnList[index]
                    btn.tag = roomQuickItem.key
                    btn.setImage(roomQuickItem.icon, for: .highlighted)
                    btn.setImage(roomQuickItem.iconHL, for: .normal)
                    btn.setImage(roomQuickItem.iconHL, for: .selected)
                    
                }
                
                if quickLabelList.count <= index
                {
                    let label: UILabel = UILabel()
                    label.font = UIFont.systemFont(ofSize: 13)
                    label.text = roomQuickItem.name
                    label.numberOfLines = 0
                    label.textAlignment = .center
                    quickLabelList.append(label)
                    self.addSubview(label)
                }else{
                    let label: UILabel = quickLabelList[index]
                    label.text = roomQuickItem.name
                }
                
                index += 1
            }
            
            
            
        }
        get {
            return _homeQuickItemList
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    @objc func quickBtiDidClicked(_ btn: UIButton) -> Void {
        GlobarMethod.addAnimation(to: btn)
        delegate?.specialActionViewDidClickedBtn(Int32(btn.tag))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let btnCount = self.homeQuickItemList.count
        let btnMaginY: CGFloat = 24
        let totalW = self.frame.width
        let btnH = 72 * totalW / 320
        let labelH: CGFloat = 20
        let marginY: CGFloat = (totalW -  CGFloat((self.homeQuickItemList.count + everyRowCount - 1)/everyRowCount) * (btnH + btnMaginY)) * 0.5
        let btnW: CGFloat = btnH - 20
        var currentRow: Int = 0
        var index: Int = 0
        
        for btn in quickBtnList{
            currentRow = (index) / everyRowCount
            let currentRowBtnCount =  (btnCount - currentRow * everyRowCount) / (everyRowCount) >= 1 ?  everyRowCount : btnCount % everyRowCount
            let btnMaginX: CGFloat = (self.frame.size.width - CGFloat(currentRowBtnCount) * btnW)/CGFloat(currentRowBtnCount + 1)
            let btnX:CGFloat = (btnMaginX + btnW) * CGFloat((index) % everyRowCount) + btnMaginX
            let btnY:CGFloat = (btnMaginY + btnH) * CGFloat(currentRow) + btnMaginY + marginY;
            btn.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnW)
            
            let label = quickLabelList[index]
            label.frame = CGRect(x:  btn.frame.minX - 16 , y: btn.frame.maxY, width: btnW + 32, height: labelH)
            index += 1
            
        }
        
        
        
        
    }
}

