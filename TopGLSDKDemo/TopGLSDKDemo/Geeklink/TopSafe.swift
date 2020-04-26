//
//  TopSafe.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/27.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopSafe: NSObject {
    
    var isSelected: Bool = false
    var isGetData: Bool = false
    var icon: String = ""
    var selectIcon: String = ""
    var taskList = Array<TopTask>()
    var name: String = ""
    var securityList = Array<TopSecurity>()
    var _securityModeInfo : GLSecurityModeInfo?
    var securityModeInfo : GLSecurityModeInfo? {
        set{
            _securityModeInfo = newValue as GLSecurityModeInfo?
           self.resetSecurityList()
           self.resetTaskList()
        }get{
            var securityDevInfoList = Array<GLSecurityDevInfo>()
            for security in  securityList{
                let securityDevInfo: GLSecurityDevInfo =  GLSecurityDevInfo(md5: security.md5, subId: security.subId)
                securityDevInfoList.append(securityDevInfo)
            }
            
            var actionList = Array<GLActionInfo>()
            for task in  taskList{
                actionList.append(task.action!)
            }
            _securityModeInfo = GLSecurityModeInfo(mode: mode!, devices: securityDevInfoList, actions: actionList)
            return _securityModeInfo
        }
    }
    /**
     *场景ID用于获取action
     */
    var macroInfo: GLMacroInfo = GLMacroInfo()
    
     var _securityAckInfo: TopSecurityAckInfo  = TopSecurityAckInfo()
    var securityAckInfo: TopSecurityAckInfo?{
        set{
            _securityAckInfo = (newValue as TopSecurityAckInfo?)!
        
            securityModeInfo = _securityAckInfo.securityModeInfo
        }
        get{
            return _securityAckInfo
        }
    }
    func resetTaskList() -> Void {
        let deviceList = TopDataManager.shared.resetDeviceInfo()
       
        taskList.removeAll()
        if _securityModeInfo?.actions == nil {
            return
        }
        for action in (_securityModeInfo?.actions)! {
            let task: TopTask = TopTask()
            task.action = action as? GLActionInfo
            for deviceAckInfo in deviceList {
                if task.type == .device {
                    if (deviceAckInfo.md5 ==  task.action?.md5) &&
                        (deviceAckInfo.subId == task.action?.subId) {
                        task.device = deviceAckInfo
                        taskList.append(task)
                    }
                } else if task.type == .jdPlay {
                    if deviceAckInfo.mainType == .BGM {
                        if deviceAckInfo.deviceInfo.camUid == task.jdPlay {
                            task.device = deviceAckInfo
                            taskList.append(task)
                        }
                    }
                }
            }
        }
    }
    
    func resetSecurityList() -> Void {
        securityList.removeAll()
        
        let deviceList = TopDataManager.shared.resetDeviceInfo()
        if _securityModeInfo?.devices == nil {
            return
        }
        
        for securityDevInfo in (_securityModeInfo?.devices)!{
            let security = TopSecurity()
            security.securityDevInfo = securityDevInfo as? GLSecurityDevInfo
            
            for deviceAckInfo: TopDeviceAckInfo in deviceList{
               // NSLog((security.securityDevInfo?.md5)!+"==="+deviceAckInfo.md5, "")
                
                if (security.securityDevInfo?.md5 == deviceAckInfo.md5) && (security.securityDevInfo?.subId == deviceAckInfo.subId){
                    
                    security.deviceAckInfo = deviceAckInfo
                    securityList.append(security)
                    break
                }
            }
        }
    }
    
    
    /**
     *设置类型
     */
    var _mode: GLSecurityModeType = .home
    var mode: GLSecurityModeType?{
        set{
            var mocroID: Int32 = 1
            _mode = (newValue as GLSecurityModeType?)!
            switch _mode {
            case .home:
                icon = "safe_home"
                selectIcon = "safe_home_selected"
                name = NSLocalizedString("At Home", comment: "")
                mocroID = 2
            case .leave:
                icon = "safe_leave"
                selectIcon = "safe_leave_selected"
                name = NSLocalizedString("Leave", comment: "")
                mocroID = 1
            case .night:
                mocroID = 3
                icon = "safe_night"
                selectIcon = "safe_night_selected"
                name =  NSLocalizedString("Night", comment: "")
            case .disarm:
                icon = "safe_disalarm"
                selectIcon = "safe_disalarm_selected"
                name = NSLocalizedString("Disarm", comment: "")
                mocroID = 4
            default:
                break
            }
            macroInfo = GLMacroInfo(macroId: mocroID, name: name, icon: mocroID, autoOn: false, pushOn: false, members: "", triggers: [Any](), order: 0)
        }
        get {
            return _mode
        }
    }
}
