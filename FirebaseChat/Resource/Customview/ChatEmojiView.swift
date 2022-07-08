//
//  ChatEmojiView.swift
//  realtimeCharts
//
//  Created by MQI-1 on 14/06/22.
//

import UIKit

class ChatEmojiView: UIView {

    @IBOutlet weak var collectionEmoji: UICollectionView!
    @IBOutlet weak var topConstrin: NSLayoutConstraint!
    
    var action: ((String, Bool) -> Void)!
    var backAction: ((String, Bool) -> Void)!
    var topCons: ((CGFloat) -> Void)!
    var reactionStr = ""
    var arrReaction: [MLChatReactionData] = [MLChatReactionData(isReaction: false, reactionTxt: "❤️"),
                                             MLChatReactionData(isReaction: false, reactionTxt: "😡"),
                                             MLChatReactionData(isReaction: false, reactionTxt: "🥳"),
                                             MLChatReactionData(isReaction: false, reactionTxt: "😜"),
                                             MLChatReactionData(isReaction: false, reactionTxt: "😄"),
                                             MLChatReactionData(isReaction: false, reactionTxt: "😍"),
                                             MLChatReactionData(isReaction: false, reactionTxt: "😏"),
                                             MLChatReactionData(isReaction: false, reactionTxt: "🤯"),
                                             MLChatReactionData(isReaction: false, reactionTxt: "🤫"),
                                             MLChatReactionData(isReaction: false, reactionTxt: "🤐")]
    
    override func awakeFromNib() {
       super.awakeFromNib()
       //custom logic goes here
        collectionEmoji.register(UINib(nibName: "EmojiCell", bundle: nil), forCellWithReuseIdentifier: "EmojiCell")
        topCons = { constrain in
            self.topConstrin.constant = constrain
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if reactionStr != "" {
            let index = self.arrReaction.firstIndex(where: { $0.reactionTxt == reactionStr})
            
            if index != nil {
                self.arrReaction[index!].isReaction = true
            }
        }
    }
    
    @IBAction func btnClose(sender: UIButton) {
        backAction("",false)
    }
    
}


extension ChatEmojiView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrReaction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        let data = self.arrReaction[indexPath.row]
        cell.lblReaction.text = data.reactionTxt
        cell.viewDot.isHidden = !data.isReaction
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select")
        let data = self.arrReaction[indexPath.row]
        print(!data.isReaction,"dgdfgdfgd")
        self.arrReaction[indexPath.row].isReaction = !data.isReaction
        if !self.arrReaction[indexPath.row].isReaction {
            action("", !data.isReaction)
        } else{
            action(data.reactionTxt, !data.isReaction)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((collectionEmoji.frame.width - 10) / 7), height: ((collectionEmoji.frame.width - 10) / 7))
    }

}
