//
//  TopAutoMacroVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/5/2.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopAutoMacroVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource {
    var macro: TopMacro?
    @IBOutlet weak var tableView: UITableView!
    var titleList = [String]()
    var inductionDevice = [TopDeviceAckInfo]()
    var taskDevice = [TopDeviceAckInfo]()
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()

       
    }
    func initData() -> Void {
        macro = TopDataManager.shared.macro
        inductionDevice.removeAll()
        titleList.removeAll()
        tableView.register(UINib(nibName: "TopDeviceSelectedCell", bundle: nil), forCellReuseIdentifier: "TopDeviceSelectedCell")
        taskDevice.removeAll()
        switch macro?.type {
        case .openDoorLightOn?:
            titleList.append(NSLocalizedString("Please select the door magnetic induction", tableName: "MacroPage"))
            titleList.append(NSLocalizedString("Please select the switch that you want to control", tableName: "MacroPage"))
            let deviceList = TopDataManager.shared.resetDeviceInfo()
            for deviceInfo in deviceList{
                if deviceInfo.mainType == .slave{
                    if deviceInfo.slaveType == .doorSensor{
                       inductionDevice.append(deviceInfo)
                        if inductionDevice.count == 1{
                            deviceInfo.isSelected = true
                        }
                        continue
                    }
                    if (deviceInfo.slaveType == .fb11) ||
                        (deviceInfo.slaveType == .fb12) ||
                        (deviceInfo.slaveType == .fb13) ||
                        (deviceInfo.slaveType == .fb1Neutral1) ||
                        (deviceInfo.slaveType == .fb1Neutral2) ||
                        (deviceInfo.slaveType == .fb1Neutral3) ||
                        (deviceInfo.slaveType == .ioModula) ||
                        (deviceInfo.slaveType == .ioModulaNeutral) {
                        taskDevice.append(deviceInfo)
                    }
                    
                }
            }
            
        default:
            break
        }
    }
    
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return inductionDevice.count
        case 1:
            return 0
        default:
            break
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TopDeviceSelectedCell = tableView.dequeueReusableCell(withIdentifier: "TopDeviceSelectedCell") as! TopDeviceSelectedCell
        let device:TopDeviceAckInfo = inductionDevice[indexPath.row]
        cell.selectionStyle = .none
        cell.deviceAckInfo = device
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: TopDeivceSecurityCell = (tableView.cellForRow(at: indexPath) as! TopDeivceSecurityCell?)!
        cell._security?.isSelected = !(cell._security?.isSelected)!
        self.tableView.reloadData()
        
    }
    
    
}



