//
//  TopFeedbackVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/5/28.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
import WebKit

class TopFeedbackVC: TopSuperVC, WKNavigationDelegate {

    var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置标题
        title = NSLocalizedString("Feedback", tableName: "MorePage")
        
        //设置WebView
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        //设置约束
        webView.translatesAutoresizingMaskIntoConstraints = false;
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[web]|", options: .alignmentMask, metrics: nil, views: ["web": webView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[web]|", options: .alignmentMask, metrics: nil, views: ["web": webView]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //请求网页
        onClickRefresh(UIBarButtonItem())
    }
    
    @IBAction func onClickRefresh(_ sender: Any) {
        //请求网页
        webView.load(URLRequest(url: URL(string: App_Feedback_Url)!))
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //开始倒计时
        processTimerStart(30.0)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //停止倒计时
        processTimerStop()
        GlobarMethod.notifyDismiss()
    }
}
