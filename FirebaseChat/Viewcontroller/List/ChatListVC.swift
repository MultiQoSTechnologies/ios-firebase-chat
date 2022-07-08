//
//  ChatListVC.swift
//  FirebaseChat
//
//  Created by MQI-1 on 22/04/22.
//

import UIKit

class ChatListVC: UIViewController {
    
    @IBOutlet weak private var viewMain: UIView!
    @IBOutlet weak private var viewData: HeaderView!
    @IBOutlet weak private var tblList: TableList! {
        didSet {
            tblList.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        }
    }
    
    var vc: ChatDetailVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationSetUp()
        
        // get last send MSG
        self.getLastMsgData()
    }
    
    private func initialization() {
        
        viewMain.layer.cornerRadius = 32
        viewMain.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
        tblList.didSelect.subscribe { row in
            
            guard let `row` = row else { return }
            self.vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatDetailVC") as? ChatDetailVC
            let data = self.tblList.arrOfList[row]
            
            // update read status
            if data.receiverId != FirebaseHelper.id {
                self.vc.userData = MDLLoginData(id: data.receiverId, online: data.isReceiverOnline, profileImg: data.receiverImage, userName: data.receiverName)
                FirebaseHelper.share.readStatusUpdate(senderId: FirebaseHelper.id, receiverId: data.receiverId ?? "")
            } else {
                self.vc.userData = MDLLoginData(id: data.senderId, online: data.isSenderOnline, profileImg: data.senderImage, userName: data.senderName)
                FirebaseHelper.share.readStatusUpdate(senderId: FirebaseHelper.id, receiverId: data.senderId ?? "")
            }
            
            self.vc.chatsData.value  = self.tblList.arrOfList[row]
            self.navigationController?.pushViewController(self.vc, animated: true)
        }
    }
    
    private func navigationSetUp() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        viewData?.lblTitle.text = "Messages"
        viewData?.lblTitle.textColor = .white
        viewData?.btnSearch.addTarget(self, action: #selector(btnSearch(sender:)), for: .touchUpInside)
    }
    
    private func getLastMsgData() {
        FirebaseHelper.share.fetchLastMSGData { data in
            guard let `data` = data else { return}
            
            if data.count == 0 {
                self.tblList.setEmptyMessage("No data")
            } else {
                self.tblList.restore()
                self.tblList.arrOfList = data
            }
            
            if self.tblList.didSelect.value != nil {
                self.vc.chatsData.value  = self.tblList.arrOfList[self.tblList.didSelect.value ?? 0]
            }
            self.tblList.reloadData()
        }
    }
    
    @objc private func btnSearch(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
    
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
