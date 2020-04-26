//
//  TopAddNewTaskVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/9.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopDeviceCLVCell : UICollectionViewCell {
  

    var _device: TopDeviceAckInfo?
    var device: TopDeviceAckInfo?{
        get{
            //返回成员变量
            return _device;
        }
        set{
            //使用 _成员变量 记录值
            _device = newValue;
        }
    }
    
    
    
}


class TopDeviceVCCell: UICollectionViewCell {
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
}

class TopDeviceListVC: TopSuperVC, UICollectionViewDelegate, UICollectionViewDataSource,CardScrollViewDelegate{
    
    var roomList = Array<GLRoomInfo>.init()
    var deviceList = Array<GLDeviceInfo>.init()
    var roomImages = Array<UIImage>.init()
    
    var roomInfo = GLRoomInfo.init()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var triangleView: UIView!
    @IBOutlet weak var pleaseSelectLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefresh(collectionView)
        
        self.title = NSLocalizedString("Execution task", comment: "")
     
        //设置宫格图样式
        let scale: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1.25:1
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize.init(width: 75*scale, height: 104*scale)
        layout.minimumInteritemSpacing = 16*scale
        layout.minimumLineSpacing = 4*scale
        layout.sectionInset = UIEdgeInsets.init(top: 4*scale+35, left: 16*scale, bottom: 4*scale, right: 16*scale)
        collectionView.collectionViewLayout = layout
        
        reloadRoomList()
        // Do any additional setup after loading the view.
        
        
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        
    }
    
    
    func reloadRoomList(){
        roomList = GlobalVars.share().roomHandle.roomGet(TopDataManager.shared.homeId!) as! Array<GLRoomInfo>
        let defaultRoom = GLRoomInfo.init(roomId: 0, name: NSLocalizedString("Default room", comment: ""), picId: 1, order: 0)
        roomList.append(defaultRoom!)
        
        var index = 0
        while index < roomList.count {
            let theRoomInfo: GLRoomInfo = roomList[index]
            roomImages.append(GlobarMethod.getRoomImage(theRoomInfo.picId))
            index += 1
        }
        initSubviewValues()
        reloadRoomInfoWithroomInfoIndex(0)
       
    }
    
    func reloadRoomInfoWithroomInfoIndex(_ index: Int) {
        //更新房间图片
        if(roomList.count > index){
            roomInfo = roomList[index]
        }
        
        
        //更新设备列表
        self.deviceList.removeAll()
       let deviceList = GlobalVars.share().roomHandle.roomDeviceGetRoom(TopDataManager.shared.homeId!, roomId: roomInfo.roomId) as! [GLDeviceInfo]
        for deviceInfo in deviceList{
            if (deviceInfo.mainType == .database) || (deviceInfo.mainType == .custom){
                self.deviceList.append(deviceInfo)
            }
            else if deviceInfo.mainType == .slave{
                 let slaveType = GlobalVars.share().roomHandle.roomGetSlaveType(deviceInfo.subType)
                
                if (slaveType == .fb11) || (slaveType == .fb12) || (slaveType == .fb13) || (slaveType == .fb1Neutral1) || (slaveType == .fb1Neutral2) || (slaveType == .fb1Neutral3) ||  (slaveType == .ioModula) {
                     self.deviceList.append(deviceInfo)
                }
            }
        }
       
        
     

        collectionView.reloadData()
    }
    
    func initSubviewValues(){
      
        //顶部
        
        let viewWidth: CGFloat = (GlobarMethod.getScreenW())/320 * 100
        let views:NSMutableArray = NSMutableArray.init();
        if roomImages.count <= 0 {
            return
        }
        var index: Int = 0
        
        while index <  roomImages.count {
            let imgView:UIImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: viewWidth, height: viewWidth))
            imgView.layer.cornerRadius = 5
            imgView.clipsToBounds = true
            imgView.image = roomImages[index]
            view.backgroundColor = UIColor.white
            views.add(imgView)
            index += 1
        }
        
    
        let y: Int =  20
        
        let cardScroll: CardScrollView = CardScrollView.init(views: views as! [Any], at: CGPoint.init(x: 0, y: y))
       
        
        cardScroll.delegate = self
        
        cardScroll.delegate = self;
        topContentView.addSubview(cardScroll)
        
       //中间
        
        pleaseSelectLabel.text = NSLocalizedString("Add execution task, pls", comment: "")
        
        triangleView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/4))
        
        //底部
        
   
    
    }
    /**
     *CardScrollViewDelegate
     */
    func pagingScrollView(_ pagingScrollView: CardScrollView!, scrolledToPage currentPage: Int) {
        reloadRoomInfoWithroomInfoIndex(currentPage)
    }
    
    func editMacroButtonDidClicked(){
        
    }
    func addMacroButtonDidClicked(){
        self.performSegue(withIdentifier: "TopAddNewMacroVC", sender: nil)
    }
  
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = UIDevice.current.userInterfaceIdiom == .pad ? "TopDeviceVCCellPad" : "TopDeviceVCCell"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TopDeviceVCCell
        
        if indexPath.row == deviceList.count {
            cell.nameLable.text = NSLocalizedString("Add device", comment: "")
            cell.iconImg.image = UIImage.init(named: "room_add_normal")
            
        } else {
            let device = deviceList[indexPath.row]
            cell.nameLable.text = device.name
            cell.iconImg.image = GlobarMethod.getDeviceImageBig(TopDataManager.shared.homeId!, deviceInfo: device)
           
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let device = deviceList[indexPath.row]
        
        let sb = UIStoryboard(name: "DeviceDetail", bundle: nil)
        
        
        let task: TopTask = TopTask.init()
        let deviceAckInfo: TopDeviceAckInfo = TopDeviceAckInfo.init()
        deviceAckInfo.deviceInfo = device
        deviceAckInfo.roomInfo = roomInfo
        task.device = deviceAckInfo
       
        TopDataManager.shared.task = task
        

        
        switch device.mainType {
        case .custom:
            let acVc: TopActionCustomVC = sb.instantiateViewController(withIdentifier: "TopActionCustomVC") as! TopActionCustomVC
            acVc.deviceInfo = device
           
            acVc.homeInfo = GlobalVars.share().curHomeInfo
            self.show(acVc, sender: nil)
        
        case .database:
            
            let adVc: TopActionDatabaseVC = sb.instantiateViewController(withIdentifier: "TopActionDatabaseVC") as! TopActionDatabaseVC
            adVc.deviceInfo = device
           
            adVc.homeInfo = GlobalVars.share().curHomeInfo
            self.show(adVc, sender: nil)
        case .slave:
            let slaveType: GLSlaveType =  GlobalVars.share().roomHandle.roomGetSlaveType(device.subType)

            if (slaveType == .fb1Neutral1)||(slaveType == .fb1Neutral2)||(slaveType == .fb1Neutral3)||(slaveType == .fb11)||(slaveType == .fb12)||(slaveType == .fb13)||(slaveType == .ioModula){
                let item = collectionView.cellForItem(at: indexPath)
                showFWActionSheet(item!, device: device)
            }

                return

          
         
        default:
            break
        }
       
        
    }
    
    
    func showFWActionSheet(_ view: UIView, device: GLDeviceInfo) -> Void {
        let alertController = UIAlertController.init(title: nil, message:  nil, preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        if (alertController.popoverPresentationController != nil) {
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = view.bounds
        }
        weak var weakSelf = self
        let actionRockBack = UIAlertAction.init(title: NSLocalizedString("Add reversal", comment: ""), style: .default, handler: {
            (action) -> Void in
          
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let task: TopTask = TopTask.init()
            task.switchCtrlInfo = GLSwitchCtrlInfo.init(rockBack: true, aCtrl: true, bCtrl: true, cCtrl: true, dCtrl: true, aOn: false, bOn: false, cOn: false, dOn: false)
            let deviceAckInfo: TopDeviceAckInfo = TopDeviceAckInfo.init()
            deviceAckInfo.deviceInfo = device
            deviceAckInfo.roomInfo = weakSelf?.roomInfo
            task.device = deviceAckInfo
            
            TopDataManager.shared.task = task
            
            let feedbackSwitchSetVC: TopFeedbackSwitchSetVC = sb.instantiateViewController(withIdentifier: "TopFeedbackSwitchSetVC") as! TopFeedbackSwitchSetVC
            feedbackSwitchSetVC.type = .TopFeedbackSwitchSetVCTypeAddTask
            self.navigationController?.pushViewController(feedbackSwitchSetVC, animated: true)
            
        })
        
        let actionAction = UIAlertAction.init(title: NSLocalizedString("Add action", comment: ""), style: .default, handler: {
            (action) -> Void in
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let task: TopTask = TopTask.init()
            task.switchCtrlInfo = GLSwitchCtrlInfo.init(rockBack: false, aCtrl: true, bCtrl: true, cCtrl: true, dCtrl: true, aOn: true, bOn: true, cOn: true, dOn: true)
            let deviceAckInfo: TopDeviceAckInfo = TopDeviceAckInfo.init()
            deviceAckInfo.deviceInfo = device
            deviceAckInfo.roomInfo = weakSelf?.roomInfo
            task.device = deviceAckInfo

            TopDataManager.shared.task = task
            let feedbackSwitchSetVC: TopFeedbackSwitchSetVC = sb.instantiateViewController(withIdentifier: "TopFeedbackSwitchSetVC") as! TopFeedbackSwitchSetVC
            feedbackSwitchSetVC.type = .TopFeedbackSwitchSetVCTypeAddTask
            self.navigationController?.pushViewController(feedbackSwitchSetVC, animated: true)
            
            
        })
      
        alertController.addAction(actionCancel)
        alertController.addAction(actionAction)
        alertController.addAction(actionRockBack)
        present(alertController, animated: true, completion: nil)

        
        

    }
    
    // MARK: - UICollectionView Highlight
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .lightGray
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .clear
    }
    
    
}

    

