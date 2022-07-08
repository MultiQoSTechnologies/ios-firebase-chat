//
//  ChatListCell.swift
//  FirebaseChat
//
//  Created by MQI-1 on 22/04/22.
//

import UIKit
import SDWebImage

class ChatListCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLastMSG: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblNumberOfCount: UILabel!
    @IBOutlet weak var viewNumberOfCount: UIView!
    @IBOutlet weak var lblOnline: UILabel!
    
    var chatData: MDLChatData!
    var format = DateFormatter()
    var userTypeData: MDLItem?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initialization(data: MDLChatData) {
        
        if data.receiverId != FirebaseHelper.id {
            lblName.text = data.receiverName
            imgProfile.sd_setImage(with: URL(string: data.receiverImage ?? ""), completed: nil)
        } else {
            lblName.text = data.senderName
            imgProfile.sd_setImage(with: URL(string: data.senderImage ?? ""), completed: nil)
        }
        
        for typedata in data.typeData ?? [:] {
            if typedata.key != FirebaseHelper.id {
                userTypeData = typedata.value
            }
        }
        
        lblTime.text = CommonFunction.getStringTimestampDate(timestamp: data.timestamp ?? 0, withFormat: "dd-MM-yyyy hh:mm:ss", toFormat: "hh:mm")
        
        let types = TypeMsg(rawValue: data.type ?? "text")
        
        if let userType  = userTypeData {
            if userType.isTyping ?? false {
                lblLastMSG.text = "Typing..."
            } else {
                self.msgType(type: types ?? .text, msg: data.msg ?? "")
            }
        } else {
            self.msgType(type: types ?? .text,  msg: data.msg ?? "")
        }
        
        if data.senderId != FirebaseHelper.id {
            lblNumberOfCount.text = String(data.receiverCount ?? 0)
            self.onlineStatus(isOnline: data.isSenderOnline ?? false)
            self.countData(count: data.receiverCount ?? 0)
        } else {
            lblNumberOfCount.text = String(data.senderCount ?? 0)
            self.onlineStatus(isOnline: data.isReceiverOnline ?? false)
            self.countData(count: data.senderCount ?? 0)
        }
    }
    
    private func msgType(type: TypeMsg, msg: String) {
        if  type == .image {
            lblLastMSG.text = "Photo"
        } else if type == .video {
            lblLastMSG.text = "Video"
        } else if type == .document {
            lblLastMSG.text = "Document"
        } else {
            lblLastMSG.text = msg
        }
    }
    
    private func onlineStatus(isOnline: Bool) {
        if isOnline {
            lblOnline.backgroundColor = .green
        } else {
            lblOnline.backgroundColor = .red
        }
    }
    
    private func countData(count: Int) {
        if count == 0 {
            viewNumberOfCount.isHidden = true
        } else {
            viewNumberOfCount.isHidden = false
        }
    }
}
