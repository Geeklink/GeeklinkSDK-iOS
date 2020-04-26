//
//  TopSafeVC.swift
//  Geeklink
//
//  Created by 列树童 on 2018/3/7.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit


class TopSafeVC: TopSuperVC, TopSafeHeaderViewDelegate, UITableViewDelegate, UITableViewDataSource, TopPageViewDelegate {
   
    @IBOutlet weak var headerContentView: UIView!
    @IBOutlet weak var bottomContentView: UIView!
    weak var pageView: TopPageView?
    weak var leftTableView: UITableView!
    weak var rightTableView: UITableView!
    var homeInfo = GLHomeInfo()
    private var safeList = Array<TopSafe>()
    private var currentSafe = TopSafe()
    private var deviceSecuritylist = Array<TopSecurity>()
    private weak var safeHeaderView: TopSafeHeaderView?
    private var isGetRefreshData = false
  
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TopDataManager.shared.homeId = homeInfo.homeId
       
        title = NSLocalizedString("Security Setting", comment: "")
        
        navigationItem.rightBarButtonItem?.title = NSLocalizedString("Timer Rule", comment: "")
        navigationItem.rightBarButtonItem?.tintColor = APP_ThemeColor
        
        setupRefresh(self.leftTableView)
        setupRefresh(self.rightTableView)
        let _ = TopDataManager.shared.resetDeviceInfo()
       
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(securityModeInfoResp), name: NSNotification.Name("securityModeInfoResp"), object: nil)
        getRefreshData()
        initData()
        initPageView()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: -
    
    @objc func securityModeInfoResp(notificatin: Notification) {//获取返回
        processTimerStop()
        
        GlobarMethod.notifyDismiss()
        let info: TopSecurityAckInfo = notificatin.object as! TopSecurityAckInfo
        if info.state == .ok {
            resetCurrentSafe(info)
            if isGetRefreshData == false{
                 GlobarMethod.notifySuccess()
            }
           
            
        } else {
            GlobarMethod.notifyFailed()
            
        }
        isGetRefreshData = false
    }
    
    //MARK: -
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.safeHeaderView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.headerContentView.height)
     
        pageView?.frame =  CGRect(x:16 , y: 0, width: view.bounds.width - 32, height: bottomContentView.height)
        pageView?.setupUI()
        self.leftTableView.frame = CGRect(x:0 , y: 0, width: view.bounds.width - 32, height: bottomContentView.height - 44)
        self.rightTableView.frame = CGRect(x:0 , y: 0, width: view.bounds.width - 32, height: bottomContentView.height - 44)
        self.leftTableView.reloadData()
        self.rightTableView.reloadData()
     
    }
   func initPageView() -> Void{
    
       let pageViewY: CGFloat = (self.safeHeaderView?.frame.maxY)!
    
        automaticallyAdjustsScrollViewInsets = false//不要调整SV内边距
    

        let titles = [NSLocalizedString("Alarm Device", comment: ""), NSLocalizedString("Perform Action", comment: "")]
        let style = TopPageStyle()
        style.isNeedTitleScale = true//缩放支持
        style.bottomLineColor = APP_ThemeColor
        style.titleFont = UIFont.systemFont(ofSize: 15)
        style.coverBgColor = UIColor.groupTableViewBackground
        style.selectColor = APP_ThemeColor

        var childVCs = [UIViewController]()
        for index in 0..<titles.count {
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.groupTableViewBackground
            let tableView = UITableView(frame:  CGRect(x:0 , y: 0, width: view.bounds.width - 32, height: view.bounds.height - pageViewY - 88 - UIApplication.shared.statusBarFrame.height), style: .grouped)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 32, height: 0.01))
            self.pageView?.titleView?.layer.cornerRadius = 8
            if index == 0{
                leftTableView = tableView
                setupRefresh(leftTableView)
                leftTableView.register(UINib(nibName: "TopDeivceSecurityCell", bundle: nil), forCellReuseIdentifier: "TopDeivceSecurityCell")
            } else {
                rightTableView = tableView
                setupRefresh(leftTableView)
                rightTableView.register(UINib(nibName: "TopTaskCell", bundle: nil), forCellReuseIdentifier: "TopTaskCell")
               
            }
            vc.view.backgroundColor = UIColor.white
            vc.view.addSubview(tableView)
            childVCs.append(vc)
        }
    
        setupRefresh(leftTableView)
        setupRefresh(rightTableView)
    
      let pageView = TopPageView(frame: CGRect(x:16 , y: 0, width: view.bounds.width - 32, height: bottomContentView.height), titles: titles, titleStyle: style, childVCs: childVCs, parentVC: self)
      pageView.backgroundColor = UIColor.clear
      pageView.layer.cornerRadius = 8
      self.pageView = pageView
      pageView.delegate = self
      bottomContentView.addSubview(pageView)
    
    }
  
    func resetCurrentSafe(_ securityAckInfo: TopSecurityAckInfo) -> Void {
        
        for safe in safeList{
            if safe.mode == securityAckInfo.mode{
                safe.securityAckInfo = securityAckInfo
                safe.isGetData = true
            }
        }
        pageView(self.pageView!, targetIndex: (pageView?.currentSlectedIndex)!)
        self.rightTableView.reloadData()
        self.leftTableView.reloadData()
    }
  
    override func getRefreshData() {
        isGetRefreshData = true
        if SGlobalVars.securityHandle.securityModeInfoGetReq(TopDataManager.shared.homeId, mode: currentSafe.mode!) == 0{
            processTimerStart(3.0)
        } else {
            GlobarMethod.notifyNetworkError()
        }
    }
    
    func initData() -> Void {
        safeList.removeAll()
      
        let atHomeSafe: TopSafe = TopSafe()
        atHomeSafe.mode = .home
        safeList.append(atHomeSafe)
        
        let goOutSafe: TopSafe = TopSafe()
        goOutSafe.mode = .leave
        safeList.append(goOutSafe)
       
        
        let nightSafe: TopSafe = TopSafe()
        nightSafe.mode = .night
        safeList.append(nightSafe)
        
        let disarm: TopSafe = TopSafe()
        disarm.mode = .disarm
        safeList.append(disarm)
        
      
        
        let safeHeaderView :TopSafeHeaderView = TopSafeHeaderView()
        
        safeHeaderView.safeList = safeList
        safeHeaderView.delegate = self
        self.safeHeaderView = safeHeaderView
        self.safeHeaderView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.headerContentView.height)
        self.headerContentView.addSubview(safeHeaderView)
        
    
        let curSafeMode = SGlobalVars.securityHandle.getSecurityMode(homeInfo.homeId)
        switch curSafeMode {
        case .home:
            TopDataManager.shared.safe = atHomeSafe
            currentSafe = atHomeSafe
            safeHeaderView.setSelectedIndex(0)
        case .leave:
            TopDataManager.shared.safe = goOutSafe
            currentSafe = goOutSafe
            safeHeaderView.setSelectedIndex(1)
        case .night:
            TopDataManager.shared.safe = nightSafe
            currentSafe = nightSafe
            safeHeaderView.setSelectedIndex(2)
        case .disarm:
            TopDataManager.shared.safe = disarm
            currentSafe = disarm
            safeHeaderView.setSelectedIndex(3)
        default:
            break
        }
        
    }
    
    //MARK: -
    
    @objc func addTaskCellDidClicked() -> Void {
        let sb = UIStoryboard(name: "Macro", bundle: nil)
        let addTaskVC: TopAddTaskVC = sb.instantiateViewController(withIdentifier: "TopAddTaskVC") as! TopAddTaskVC
        addTaskVC.type = .TopAddTaskVCTypeSecuritySave
        show(addTaskVC, sender: nil)
    }
    
    @objc func addDeviceCellDidClicked() -> Void {
        
        let sb = UIStoryboard(name: "Security", bundle: nil)
        let securityDevListVC: TopDeviceSecuritySelectedVC = sb.instantiateViewController(withIdentifier: "TopDeviceSecuritySelectedVC") as! TopDeviceSecuritySelectedVC
        show(securityDevListVC, sender: nil)
    }
    
    //MARK: - TopSafeHeaderViewDelegate
    
    func safeHeaderViewDidSlectBtn(_ safe: TopSafe) {
        currentSafe = safe
        TopDataManager.shared.safe = currentSafe
        self.leftTableView.reloadData()
        self.rightTableView.reloadData()
        
        if (currentSafe.isGetData == false) {
            self.getRefreshData()
        } else {
            pageView(self.pageView!, targetIndex: (pageView?.currentSlectedIndex)!)
        }
    }
    
    func pageView(_ pageView: TopPageView, targetIndex: Int) {
        
        if targetIndex == 0 {
            if currentSafe.securityList.count == 0 {
                self.pageView?.titleView?.layer.cornerRadius = 8
            } else {
                self.pageView?.titleView?.layer.cornerRadius = 0
            }
        } else {
            if currentSafe.taskList.count == 0 {
                self.pageView?.titleView?.layer.cornerRadius = 8
            } else {
                self.pageView?.titleView?.layer.cornerRadius = 0
            }
            
        }
    }
    
    //MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        
        if tableView == leftTableView {
           
            return currentSafe.securityList.count
            
        } else {
    
            return currentSafe.taskList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView == rightTableView) {
            if (indexPath.section == 0) {
                  return 88
            }  
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.leftTableView {
            if indexPath.section == 0 {
                if indexPath.row < currentSafe.securityList.count{
                    let cell: TopDeivceSecurityCell = tableView.dequeueReusableCell(withIdentifier: "TopDeivceSecurityCell") as! TopDeivceSecurityCell
                    let security:TopSecurity = currentSafe.securityList[indexPath.row]
                    cell.security = security
                    cell.slelectBtn?.isHidden = true
                    if indexPath.row == currentSafe.securityList.count - 1 {
                        let corners: Int =  Int((UIRectCorner.bottomRight).rawValue +  UIRectCorner.bottomLeft.rawValue)
                        GlobarMethod.addRoundedCorners(UIRectCorner(rawValue: UIRectCorner.RawValue(corners)), to: cell, withRadii: CGSize(width: 8, height: 8), viewRect: CGRect(x: 0, y: 0, width: self.view.frame.width - 32, height: 44))
                        cell.isSetRounded = true
                    } else {
                        if cell.isSetRounded {
                            let corners: Int =  Int((UIRectCorner.bottomRight).rawValue +  UIRectCorner.bottomLeft.rawValue)
                            GlobarMethod.addRoundedCorners(UIRectCorner(rawValue: UIRectCorner.RawValue(corners)), to: cell, withRadii: CGSize(width: 0, height: 0), viewRect: CGRect(x: 0, y: 0, width: self.view.frame.width - 32, height: 44))
                           cell.isSetRounded = false
                        }
                    }
                    return cell
                }
            }
            
        } else {
            if indexPath.section == 0{
                if indexPath.row < currentSafe.taskList.count {
                    let task: TopTask = currentSafe.taskList[indexPath.row]
                    let cell:TopTaskCell = tableView.dequeueReusableCell(withIdentifier: "TopTaskCell") as! TopTaskCell
                    cell.task = task
                    cell.hideArrowView(true)
                    cell.deleteBtn.isHidden = true
                    if indexPath.row == currentSafe.taskList.count - 1 {
                        let corners: Int =  Int((UIRectCorner.bottomRight).rawValue +  UIRectCorner.bottomLeft.rawValue)
                        GlobarMethod.addRoundedCorners(UIRectCorner(rawValue: UIRectCorner.RawValue(corners)), to: cell, withRadii: CGSize(width: 8, height: 8), viewRect: CGRect(x: 0, y: 0, width: self.view.frame.width - 32, height: 88))
                        cell.isSetRounded = true
                    } else {
                        if cell.isSetRounded {
                            let corners: Int =  Int((UIRectCorner.bottomRight).rawValue +  UIRectCorner.bottomLeft.rawValue)
                            GlobarMethod.addRoundedCorners(UIRectCorner(rawValue: UIRectCorner.RawValue(corners)), to: cell, withRadii: CGSize(width: 0, height: 0), viewRect: CGRect(x: 0, y: 0, width: self.view.frame.width - 32, height: 88))
                            cell.isSetRounded = false
                        }
                    }
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 32, height: 100))
        view.backgroundColor = .clear
        
        let btn = UIButton()
        btn.setTitle(NSLocalizedString("Edit", comment: ""), for: .normal)
        btn.frame = CGRect(x: 0, y: 16, width: self.view.frame.width - 32, height: 44)
        btn.setTitleColor(.darkGray, for: .normal)
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        if tableView == self.leftTableView{
            btn.addTarget(self, action: #selector(addDeviceCellDidClicked), for: .touchUpInside)
        } else {
            btn.addTarget(self, action: #selector(addTaskCellDidClicked), for: .touchUpInside)
        }
        
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = 8
        btn.clipsToBounds = true
        
        let text = tableView == self.leftTableView ? NSLocalizedString("Alarm Devices: Security devices that triggers an alarm in current select home security mode.", tableName: "HomePage") :  NSLocalizedString("Perform Actions: Actions that will be performed, when home control center switches to current select security mode.", tableName: "HomePage")
        let labelSize = TopDataManager.shared.textSize(text: text, font: UIFont.systemFont(ofSize: 12), maxSize: CGSize(width: self.view.frame.width - 32, height: 100))
        let label = UILabel(frame: CGRect.init())
        label.textColor = .darkGray
        label.text = text
        label.numberOfLines = 0
        label.frame = CGRect(x: 0, y: btn.frame.maxY+4, width: self.view.frame.width - 32, height: labelSize.height)
        label.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(label)
        view.addSubview(btn)
        return view
    }
  
}
