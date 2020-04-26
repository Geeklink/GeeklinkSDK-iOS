//
//  TopSafeHeaderView.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/27.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopSafeHeaderViewDelegate : class {
    
    
    func safeHeaderViewDidSlectBtn(_ safe: TopSafe)
    
}
class TopSafeHeaderView: UIView {
    weak var delegate : TopSafeHeaderViewDelegate?
    var totalCount = 4
    var selectIndex = 0
    var imageW: CGFloat = 0.0
    var topTipLabel: UILabel!
    weak var triangleView: UIImageView?
    var iconBtnList = [UIButton]()
    var textlabelList =  [UILabel]()
    var backGroundViewList =  [UIButton]()
    var _safeList =  Array<TopSafe>()
    var safeList: Array<TopSafe>?{
        set{
            _safeList = (newValue as Array<TopSafe>?)!
            var index: Int = 0
            for safe in safeList!{
                if index < iconBtnList.count{
                   let label = textlabelList[index]
                    label.text = safe.name
                    
                  
                    let iconBtn = iconBtnList[index]
                    
                    iconBtn.setImage(UIImage(named: safe.icon), for: .normal)
                    iconBtn.setImage(UIImage(named: safe.selectIcon), for: .selected)
                    iconBtn.tag = index
                    if index == 0{
                        
                        imageW = (UIImage(named: safe.icon)?.size.width)!
                        iconBtn.isSelected = true
                    }
                }
                index += 1
            }
        }
        get{
            return _safeList
        }
    }
    
    override init(frame:CGRect){
        
        super.init(frame: frame)
        self.clipsToBounds = true
        self.backgroundColor  = UIColor.groupTableViewBackground
        for index in 1...totalCount{
            let backGroundView: UIButton = UIButton()
            backGroundView.addTarget(self, action: #selector(btnDidClicked), for: .touchUpInside)
            backGroundView.tag = index - 1
            if index == 1{
                backGroundView.backgroundColor = UIColor.white
            } else {
                backGroundView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
            }
            backGroundView.clipsToBounds = true
            self.addSubview(backGroundView)
            self.backGroundViewList.append(backGroundView)
            
            let btn: UIButton = UIButton()
            btn.addTarget(self, action: #selector(btnDidClicked), for: .touchUpInside)
            btn.tag = index - 1
            self.addSubview(btn)
            iconBtnList.append(btn)
            
            let label:UILabel = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 13)
            if index == 1{
                label.textColor = APP_ThemeColor
            } else {
                label.textColor = UIColor.darkGray
            }
            
            label.numberOfLines = 0
            self.addSubview(label)
            textlabelList.append(label)
        }
        
        let triangleView = UIImageView()
        self.addSubview(triangleView)
        self.triangleView = triangleView
        
        let topTipLabel = UILabel.init()
        topTipLabel.text = NSLocalizedString("Press to switch the home security mode to set.", tableName: "HomePage")
        topTipLabel.font = UIFont.systemFont(ofSize: 15)
        topTipLabel.numberOfLines = 2
        self.topTipLabel = topTipLabel
        self.addSubview(topTipLabel)
        
        triangleView.layer.cornerRadius = 3
        triangleView.clipsToBounds = true
        triangleView.image = UIImage(named: "security_triangle_image")
        triangleView.backgroundColor = UIColor.clear
    }
    func setSelectedIndex(_ index: Int) -> Void {
      
        let backGroundView = backGroundViewList[index]
        let currentSelectBtn = iconBtnList[index]
        
        GlobarMethod.addAnimation(to: backGroundView)
        GlobarMethod.addAnimation(to: currentSelectBtn)
        
        if selectIndex == index {
            return
        }
        let preSelectBtn = iconBtnList[selectIndex]
        preSelectBtn.isSelected = false
        let preBackGroundView = backGroundViewList[selectIndex]
        preBackGroundView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        
        currentSelectBtn.isSelected = true
        
        backGroundView.backgroundColor = UIColor.white
        
        let preLabel = textlabelList[selectIndex]
        preLabel.textColor = UIColor.darkGray
        
        let currentLabel = textlabelList[index]
        currentLabel.textColor = APP_ThemeColor
        
        selectIndex = index
        
       
        
        UIView.animate(withDuration: 0.3) {
            let triangleViewX = currentLabel.frame.origin.x + (currentLabel.frame.width - (self.triangleView?.frame.width)!) * 0.5
            self.triangleView?.frame = CGRect(x: triangleViewX, y: (self.triangleView?.frame.origin.y)!, width: (self.triangleView?.frame.width)!, height: (self.triangleView?.frame.height)!)
        }
        
    }
   
    @objc func btnDidClicked(_ btn: UIButton) -> Void {
        setSelectedIndex(btn.tag)
        let safe = safeList![btn.tag]
        self.delegate?.safeHeaderViewDidSlectBtn(safe)
        
    }
    
    func setupSubViews() -> Void {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let topTipLabelSize = TopDataManager.shared.textSize(text: (topTipLabel.text)!, font: topTipLabel.font, maxSize: CGSize.init(width: self.width - 32, height: 120))
        self.topTipLabel.frame = CGRect.init(x: 16, y: 16, width: self.width - 32, height: topTipLabelSize.height)
        
        let LabelH: CGFloat = 20
        let labelMaginY: CGFloat = 14
        let labelMaginX: CGFloat = 4
        
        let imageH: CGFloat = imageW
        let imageY = self.topTipLabel.frame.maxY + 24
      
        let labelW: CGFloat = (self.frame.size.width - labelMaginX * CGFloat(totalCount + 1)) / CGFloat(totalCount)
        let labelY: CGFloat = imageY + imageH + labelMaginY
        var labelX: CGFloat = labelMaginX
       
        let backGroundViewH: CGFloat = 58
    
        let backGroundViewW = backGroundViewH
        let backGroundViewY = imageY - (backGroundViewH - imageH) * 0.5
        var index: Int = 0
        
        let triangleViewH: CGFloat = (triangleView?.image?.size.height)!
        let triangleViewW: CGFloat = (triangleView?.image?.size.width)!
        let triangleViewY: CGFloat = self.frame.height - triangleViewH
       
        
        for label in textlabelList {
            label.frame = CGRect(x: labelX, y: labelY, width: labelW, height: LabelH)
           
            let iconBtn = iconBtnList[index]
           
            let imageX:CGFloat = labelX + (labelW - imageW) * 0.5
            iconBtn.frame = CGRect(x: imageX, y: imageY, width: imageW, height: imageH)
            
            
            let backgroundView = backGroundViewList[index]
            let backGroundViewX = labelX + (labelW - backGroundViewW) * 0.5
            
            backgroundView.frame = CGRect(x:backGroundViewX , y: backGroundViewY, width: backGroundViewW, height: backGroundViewH)
            backgroundView.layer.cornerRadius = backGroundViewW * 0.5
            
            if index == selectIndex {
                let triangleViewX = labelX + (labelW - triangleViewW) * 0.5
                self.triangleView?.frame = CGRect(x: triangleViewX, y: triangleViewY, width: triangleViewW, height: triangleViewH)
             
            }
            
            
            index += 1
            labelX += labelW + labelMaginX
    
        }
        
        
       
        
        
    }

}
