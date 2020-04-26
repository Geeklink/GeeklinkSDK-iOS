//
//  TopFeedbackSwitchBtnVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2018/12/21.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit
protocol TopFeedbackSwitchBtnVCDelegate : class {
    
    
    func feedbackSwitchBtnVCDidSet(_ switchCtrlInfo: GLSwitchCtrlInfo)
    
}
class TopFeedbackSwitchBtnVC:TopSuperVC, UITableViewDataSource, UITableViewDelegate,TopFeedbackSwichCellDelegate {
    func feedbackSwichCellClickBtn(_ item: TopItem) {
        
        let itemList: Array = list[0] as! Array<TopItem>
        for theItem in itemList {
            if theItem != item{
                theItem.swichIsCol = false
            }
        }
        self.tableView.reloadData()
    }
    var deviceInfo: GLDeviceInfo!
    var switchCtrlInfo: GLSwitchCtrlInfo!
    weak var delegate: TopFeedbackSwitchBtnVCDelegate!
    
    private var totalCount = 0
    private var timeItem: TopItem = TopItem()
    private var delayTime: Int32 = 0
    private var list: NSMutableArray = NSMutableArray()
    private var selectItem: TopItem!
    @IBOutlet weak var tableView: UITableView!
    var selectedRow :Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //设置文本
        
        title = NSLocalizedString("Feedback Switch", tableName: "MacroPage")
        //title = TopDataManager.shared.condition?.device?.deviceName
        //设置
        
        initItemList()
        tableView.register(UINib(nibName: "TopFeedbackSwichCell", bundle: nil), forCellReuseIdentifier: "TopFeedbackSwichCell")
        
        
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        //清除空白横线
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
 
    

    func initItemList(){
        list.removeAllObjects()
        
      
        var iconList = [String]()
      
        iconList.append("room_quick_a_selected")
        iconList.append("room_quick_b_selected")
        iconList.append("room_quick_c_selected")
        iconList.append("room_quick_d_selected")
    
        
        
        
        if deviceInfo.mainType == .slave {
            let slaveType: GLSlaveType = SGlobalVars.roomHandle.getSlaveType(deviceInfo.subType)
               
            switch slaveType {
            case .fb11, .fb1Neutral1, .feedbackSwitchWithScenario1:
                totalCount = 1
            case .fb12, .fb1Neutral2, .feedbackSwitchWithScenario2:
                totalCount = 2
            case .fb13, .fb1Neutral3, .feedbackSwitchWithScenario3:
                totalCount = 3
            default:
                totalCount = 4
            }
        }
    
        if deviceInfo.mainType == .geeklink {
            let devType: GLGlDevType =  (GLGlDevType.init(rawValue:  Int(deviceInfo.subType)))!
            switch devType {
            case .feedbackSwitch1:
                totalCount = 1
            case .feedbackSwitch2:
                totalCount = 2
            case .feedbackSwitch3:
                totalCount = 3
            default:
                totalCount = 4
            }
        }
        var itemList0 = Array<TopItem>.init()
        var isHasCol = false
        for index in 1...totalCount{
            let iconItem = TopItem()
            var icon: String  = ""
            var title: String = ""
            if index <= iconList.count{
                icon = iconList[Int(index) - 1]
                title = SGlobalVars.roomHandle.getSwitchNoteName(TopDataManager.shared.homeId, deviceId: (deviceInfo.deviceId), road: Int32(index))
                if title.count == 0{
                    title = NSLocalizedString("Switch", tableName: "MacroPage")
                }
            }
            iconItem.text = title
            iconItem.icon = icon
            
            if index == 1{
                iconItem.swichIsOn = switchCtrlInfo.aOn
                iconItem.swichIsCol = switchCtrlInfo.aCtrl
                
            }
            else if index == 2{
                iconItem.swichIsOn = switchCtrlInfo.bOn
                iconItem.swichIsCol = switchCtrlInfo.bCtrl
                
            }
            else if index == 3{
                iconItem.swichIsOn = switchCtrlInfo.cOn
                iconItem.swichIsCol = switchCtrlInfo.cCtrl
                
            }
            else if index == 4{
                iconItem.swichIsOn = switchCtrlInfo.dOn
                iconItem.swichIsCol = switchCtrlInfo.dCtrl
                
            }
            if iconItem.swichIsCol == true {
                isHasCol = true
            }
           
          
            iconItem.accessoryType = .disclosureIndicator
            itemList0.append(iconItem)
        }
        if isHasCol == false {
             let iconItem  = itemList0.first!
             iconItem.swichIsCol = true
             iconItem.swichIsOn = true
        }
      
        
        list.add(itemList0)
        
     
    
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
   
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemList: Array = list[section] as! Array<TopItem>
        return  itemList.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
  
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
           
            return NSLocalizedString("Select, please", tableName: "MacroPage")
           
        }
        return  ""
    }
    
    
    
    
    
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemList: Array = list[indexPath.section] as! Array<TopItem>
        let item: TopItem =  itemList[indexPath.row]
        
        let cell: TopFeedbackSwichCell = tableView.dequeueReusableCell(withIdentifier: "TopFeedbackSwichCell") as! TopFeedbackSwichCell
        cell.item = item
        
        if item ==  itemList.last{
            cell.isLast = true
        }
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    
 
        
    
        
        
   
    
  
    
    
    @IBAction func saveBtnDidCilcked(_ sender: Any) {
        let itemList: Array = list[0] as! Array<TopItem>
        var item0: TopItem = TopItem()
        var item1: TopItem = TopItem()
        var item2: TopItem = TopItem()
        var item3: TopItem = TopItem()
    
        for index in 1...totalCount{
            switch index {
            case 1:
                item0 = itemList[0]
            case 2:
                item1 = itemList[1]
            case 3:
                item2 = itemList[2]
            case 4:
                item3 = itemList[3]
            default:
                break
            }
        }
        
        
        
        let switchCtrlInfo:GLSwitchCtrlInfo = GLSwitchCtrlInfo(rockBack: false, aCtrl: item0.swichIsCol, bCtrl: item1.swichIsCol, cCtrl: item2.swichIsCol, dCtrl: item3.swichIsCol, aOn: item0.swichIsOn, bOn: item1.swichIsOn, cOn: item2.swichIsOn, dOn: item3.swichIsOn)
        
       self.delegate.feedbackSwitchBtnVCDidSet(switchCtrlInfo)
        self.navigationController?.popViewController(animated: true)
    }
}





