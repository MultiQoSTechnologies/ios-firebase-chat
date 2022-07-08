//
//  MDLChatData.swift
//  FirebaseChat
//
//  Created by MQI-1 on 18/05/22.
//

import UIKit

struct MDLChatData: Codable {
    
    var senderName: String?
    var senderId: String?
    var senderImage: String?
    var receiverName: String?
    var receiverId: String?
    var receiverImage: String?
    var msg: String?
    var readStatus: Int?
    var date: String?
    var thumb: String?
    var isReceiverOnline: Bool?
    var isSenderOnline: Bool?
    var senderCount: Int?
    var receiverCount: Int?
    var timestamp: Int?
    var file: String?
    var type: String?
    var img: Data?
    var typeData: [String: MDLItem]!
    var chatReactionType: [String: MLChatReactionData]!
    
    var dict: [String:Any]  {
        return ["senderName": senderName ?? "",
                "senderId": senderId ?? "",
                "senderImage": senderImage ?? "",
                "receiverName": receiverName ?? "",
                "receiverId": receiverId ?? "",
                "receiverImage": receiverImage ?? "",
                "msg": msg ?? "",
                "readStatus": readStatus ?? 0,
                "timestamp": timestamp ?? 0,
                "date": date ?? "",
                "type": type ?? "",
                "file": file ?? "",
                "thumb": thumb ?? ""]
    }
    
    var lastMsg: [String:Any] {
        
        return ["senderName": senderName ?? "",
                "senderId": senderId ?? "",
                "senderImage": senderImage ?? "",
                "receiverName": receiverName ?? "",
                "receiverId": receiverId ?? "",
                "receiverImage": receiverImage ?? "",
                "msg": msg ?? "",
                "isReceiverOnline": isReceiverOnline ?? false,
                "isSenderOnline": isSenderOnline ?? false,
                "senderCount": senderCount ?? 0,
                "receiverCount": receiverCount ?? 0,
                "timestamp": timestamp ?? 0,
                "type": type ?? "",
        ]
    }
    
    
}

struct MDLItem: Codable {
    var id: String?
    var isTyping: Bool?
}

struct MDLUserData {
    var id: String!
    var online: Bool!
}

struct MDLChatHeader {
    var title: Date!
    var rowData: [MDLChatData]!
    var displayHeader: Bool = true
}

struct MLChatReactionData: Codable {
    var isReaction: Bool = false
    var reactionTxt: String = ""
}
