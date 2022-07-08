//
//  RecevierCell.swift
//  FirebaseChat
//
//  Created by MQI-1 on 22/04/22.
//

import UIKit

class RecevierCell: UITableViewCell {

    @IBOutlet weak var imgSeen: UIImageView!
    @IBOutlet weak var viewReciver: UIView!
    @IBOutlet weak var lblReciver: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewReaction: UIView!
    @IBOutlet weak var lblSenderReaction: UILabel!
    @IBOutlet weak var lblReciverReaction: UILabel!
    @IBOutlet weak var viewSenderReaction: UIView!
    @IBOutlet weak var viewReciverReaction: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewReciver.layer.cornerRadius = 16
        self.viewReciver.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMaxXMaxYCorner,.layerMinXMinYCorner]
        self.transform = self.transform.rotated(by: .pi)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func initialization(data: MDLChatData) {
        let strTime = CommonFunction.getStringTimestampDate(timestamp: data.timestamp ?? 0, withFormat: "dd-MM-yyyy hh:mm:ss", toFormat: "hh:mm")

       lblReciver.text = data.msg
       lblTime.text = strTime
                
        if data.chatReactionType != nil {
            self.viewReaction.isHidden = false
            
            let chatdata = data.chatReactionType.filter({ $0.value.reactionTxt == data.chatReactionType.first?.value.reactionTxt})

            if chatdata.count == 2 {
                print(chatdata.count)
                self.viewReciverReaction.isHidden = false
                self.viewSenderReaction.isHidden = true
                self.lblReciverReaction.text = "\(data.chatReactionType.first?.value.reactionTxt ?? "") \("2")"
            } else {
                
                for typeData in data.chatReactionType ?? [:] {
                    if typeData.key != FirebaseHelper.id {
                        if typeData.value.reactionTxt == "" {
                            self.viewReciverReaction.isHidden = true
                        } else {
                            self.viewReciverReaction.isHidden = false
                        }
                        self.lblReciverReaction.text = typeData.value.reactionTxt
                    } else {
                        if typeData.value.reactionTxt == "" {
                            self.viewSenderReaction.isHidden = true
                        } else {
                            self.viewSenderReaction.isHidden = false
                        }
                        self.lblSenderReaction.text = typeData.value.reactionTxt
                    }
                }
            }
        } else {
            self.viewReaction.isHidden = true
        }
    }

}
