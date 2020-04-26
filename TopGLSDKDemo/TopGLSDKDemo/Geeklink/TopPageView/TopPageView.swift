//
//  TGPageView.swift
//  TGPageView
//
//  Created by targetcloud on 2017/3/22.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
protocol TopPageViewDelegate:class {//1 NSObjectProtocol 2 class 只能被类遵守
    func pageView(_ pageView :TopPageView,targetIndex:Int)
}
class TopPageView: UIView, TopTitleViewPickerDelegate {
   
    weak var delegate : TopPageViewDelegate?
    fileprivate var titles : [String]
    fileprivate var childVCs : [UIViewController]
    fileprivate var parentVC : UIViewController
    fileprivate var titleStyle : TopPageStyle
    weak var titleView: TopTitleView?
    var currentSlectedIndex: Int = 0
    
    init(frame: CGRect,titles : [String],titleStyle : TopPageStyle,childVCs : [UIViewController],parentVC : UIViewController) {
        self.titles = titles
        self.childVCs = childVCs
        self.parentVC = parentVC
        self.titleStyle = titleStyle
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func titleView(_ titleView: TopTitleView, targetIndex: Int) {
        self.delegate?.pageView(self, targetIndex: targetIndex)
        currentSlectedIndex = targetIndex
    }
    
}

extension TopPageView{
    func setupUI(){
        let titleViewFrame = CGRect(x: 0, y: 0, width: bounds.width, height: titleStyle.titleViewHeight)
        let titleView = TopTitleView(frame:titleViewFrame,titles:titles,style:titleStyle)
        self.titleView = titleView
        titleView.clipsToBounds = true
        titleView.backgroundColor = UIColor.white
        addSubview(titleView)
        
        let contentFrame = CGRect(x: 0, y: titleViewFrame.maxY, width: bounds.width, height: bounds.height - titleStyle.titleViewHeight)
        let contentView = TopContentView(frame: contentFrame, childVCs: childVCs, parentVC: parentVC)
        contentView.backgroundColor = .red
        addSubview(contentView)
        
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        //titleView与contentView进行协作
        //MARK:- 代理 1
        titleView.delegate = contentView
        titleView.pickerDelegate = self
        //MARK:- 代理的使用 1
        contentView.delegate = titleView
    }
}

