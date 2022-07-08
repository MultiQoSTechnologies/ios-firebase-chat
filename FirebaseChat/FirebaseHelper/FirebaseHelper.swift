//
//  FirebaseHelper.swift
//  FirebaseChat
//
//  Created by MQI-1 on 25/04/22.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import AVFoundation

final class FirebaseHelper: NSObject {
    
    let firebaseRoot = "Chat"
    let firebaseUser = "User_record"
    let firebaseConver = "conversion"
    let firebaseImage = "Images"
    let firebaseVideo = "Video"
    let firebaseDocument = "Document"
    
    static let id = UIDevice.current.identifierForVendor!.uuidString
    static let share = FirebaseHelper()
    
    let database = Firestore.firestore()
    var lastDocument: DocumentSnapshot? = nil
    var loadMore = false
    let limit = 60
    let storage = Storage.storage()
    
    
    //MARK: - Add record in firebase firestore data
    func addData(data: MDLChatData) {
        
        let roomId = getRoom_id(sender: (data.senderId ?? ""), receiver: (data.receiverId ?? "")) ?? ""
        
        database.collection(firebaseRoot).document(roomId).collection(firebaseConver).addDocument(data: data.dict) { error in
            
            if error == nil {
                self.database.collection(self.firebaseRoot).document(roomId).setData(data.lastMsg, merge: true)
            } else {
                print(error?.localizedDescription.description ?? "","add data")
            }
        }
    }
    
    //MARK: - Add image in storage data
    func addImage(imgData: Data!, compilation: @escaping ((String) -> Void)) {
        
        let timestamp = Date().millisecondsSince1970
        storage.reference().child(self.firebaseImage).child("img\(timestamp).png").putData(imgData, metadata: nil) { data, error in
            guard error == nil else {
                return
            }
            
            self.storage.reference().child(self.firebaseImage).child("img\(timestamp).png").downloadURL { url, erroe in
                guard error == nil else {
                    return
                }
                if let urlText = url?.absoluteString {
                    compilation(urlText)
                }
            }
        }
        
    }
    
    func updateImageLink(dict:[String:Any], time:Int, sender: String, receiver: String) {
        
        let roomId = getRoom_id(sender: sender, receiver: receiver) ?? ""

        self.database.collection(firebaseRoot).document(roomId).collection(firebaseConver).document().parent.whereField("timestamp", isEqualTo: time).getDocuments { document, error in
            print(time)
            guard error == nil else {
                print("updateimagelink error", error)
                return
            }
            self.database.collection(self.firebaseRoot).document(roomId).collection(self.firebaseConver).document(document?.documents.first?.documentID ?? "").setData(dict, merge: true)
        }
        
    }
    
    //MARK: - Add video in storage data
    func addVideo(video: Data!, compilation: @escaping ((String) -> Void)) {
        
        let timestamp = Date().millisecondsSince1970
        storage.reference().child(self.firebaseVideo).child("video\(timestamp).mp4").putData(video, metadata: nil) { data, error in
            guard error == nil else {
                return
            }
            
            self.storage.reference().child(self.firebaseVideo).child("video\(timestamp).mp4").downloadURL { url, erroe in
                guard error == nil else {
                    return
                }
                if let urlText = url?.absoluteString {
                    compilation(urlText)
                }
            }
        }
    }
    
    //MARK: - Add document in storage data
    func addDocument(DocumentUrl: URL!,DocumentName: String, compilation: @escaping ((String) -> Void)) {
        
        storage.reference().child(self.firebaseDocument).child(DocumentName).putFile(from: DocumentUrl, metadata: nil) { data, error in
            guard error == nil else {
                return
            }
            
            self.storage.reference().child(self.firebaseDocument).child(DocumentName).downloadURL { url, erroe in
                guard error == nil else {
                    return
                }   
                
                if let urlText = url?.absoluteString {
                    compilation(urlText)
                }
            }
        }
    }
    
    //MARK: - get user data
    func addUserRecord(dict: [String: Any]) {
        database.collection(self.firebaseUser).document(FirebaseHelper.id).setData(dict, merge: true)
    }
    
    //MARK: - get unread MSG count
    func getUnreadCount(senderId: String, receiverId: String) {
        
        let roomId = getRoom_id(sender: senderId, receiver: receiverId) ?? ""
        
        database.collection(self.firebaseRoot).document(roomId).collection(self.firebaseConver).document().parent.whereField("receiverId", isEqualTo: FirebaseHelper.id).getDocuments { data, error in
            let arrOfRead = data?.documents.filter({ $0["readStatus"] as! Int == 1 })
            
            var senderCount: Int?
            var receiverCount: Int?
            
            if  FirebaseHelper.id == senderId {
                senderCount = arrOfRead?.count ?? 0
                self.database.collection(self.firebaseRoot).document(roomId).setData(["senderCount": senderCount ?? 0],merge: true)
            }
            
            if  FirebaseHelper.id == receiverId {
                receiverCount = arrOfRead?.count ?? 0
                self.database.collection(self.firebaseRoot).document(roomId).setData(["receiverCount": receiverCount ?? 0],merge: true)
            }
        }
    }
    
    //MARK: - get chat detail header data
    func getDisplayHeader(date:Date?,roomId:String, compilation: @escaping ((Bool) -> Void))   {
        
        if let data = date {
            let format = DateFormatter()
            format.dateFormat = "dd-MM-yyyy"
            let lastDate = format.string(from: data)
            if let lastDocument = lastDocument {
                
                database.collection(firebaseRoot).document(roomId).collection(firebaseConver).whereField("date", isEqualTo: lastDate).order(by: "timestamp", descending: true).start(afterDocument: lastDocument).getDocuments { data, error in
                    
                    if data?.count ?? 0 > 0 {
                        compilation(false)
                    } else {
                        compilation(true)
                    }
                }
            }
        }
    }
    
    //MARK: - get chat history data
    func fetchData(isLoadMore: Bool, sender: String, receiver: String, compilation: @escaping ((String,[MDLChatHeader]?) -> Void)) {
        let roomId = getRoom_id(sender: sender, receiver: receiver) ?? ""
        var query: Query? = nil
        
        if isLoadMore, let lastDocument = lastDocument {
            query = database.collection(firebaseRoot).document(roomId).collection(firebaseConver).order(by: "timestamp", descending: true).start(afterDocument: lastDocument).limit(to: limit)
        } else {
            query = database.collection(firebaseRoot).document(roomId).collection(firebaseConver).order(by: "timestamp", descending: true).limit(to: limit)
        }
        
        query?.addSnapshotListener { [self] data, error in
            
            if error == nil {
                
                if let recored = data {
                    
                    let arrOfData:[MDLChatData] = recored.documents.map { chatdata in
                        
                        let dict = chatdata.data()
                        var chatsData: MDLChatData?
                        
                        do {
                            let jsinData = try JSONSerialization.data(withJSONObject: dict, options: [])
                            let data = try JSONDecoder().decode(MDLChatData.self, from: jsinData)
                            chatsData = data
                        } catch {
                            print("error")
                        }
                        
                        guard let data = chatsData else { return MDLChatData()}
                        return data
                    }
                    
                    self.lastDocument = recored.documents.last
                    if arrOfData.count >= self.limit {
                        self.loadMore = true
                    } else {
                        self.loadMore = false
                    }
                    let cal = Calendar.current
                    let grouped = Dictionary(grouping: arrOfData, by: { cal.startOfDay(for: Date(milliseconds: Int64($0.timestamp ?? 0)))})
                    var arrOfHeaderChat: [MDLChatHeader] = []
                    
                    for dict in grouped {
                        
                        let data = MDLChatHeader(title: dict.key, rowData: dict.value)
                        arrOfHeaderChat.append(data)
                    }
                    arrOfHeaderChat = arrOfHeaderChat.sorted(by: { $0.title > $1.title})
                    
                    DispatchQueue.main.async {
                        compilation(roomId,arrOfHeaderChat)
                    }
                }
            } else {
                print(error?.localizedDescription.description ?? "","fetch data")
            }
        }
    }
    
    //MARK: - get chat last MSG data
    func fetchLastMSGData(compilation: @escaping (([MDLChatData]?) -> Void)) {
        
        database.collection(firebaseRoot).order(by: "timestamp", descending: true).addSnapshotListener {  data, error in
            if error == nil {
                
                if let recored = data {
                    
                    var arrOfDocu:[MDLChatData] = []
                    for document in recored.documents {
                        
                        let dict = document.data()
                        do {
                            let jsinData = try JSONSerialization.data(withJSONObject: dict, options: [])
                            let data = try! JSONDecoder().decode(MDLChatData.self, from: jsinData)
                            
                            if data.senderId == FirebaseHelper.id || data.receiverId == FirebaseHelper.id {
                                arrOfDocu.append(data)
                                
                                if data.senderId != nil && data.receiverId != nil {
                                    FirebaseHelper.share.getUnreadCount(senderId: data.senderId ?? "", receiverId: data.receiverId ?? "")
                                }
                            }
                        } catch {
                            print("error last msg")
                        }
                    }
                    compilation(arrOfDocu)
                }
            } else {
                print(error?.localizedDescription.description ?? "","fetch data")
            }
        }
    }
    
    //MARK: - get user data
    func fetchUserRecord(compilation: @escaping (([MDLLoginData]) -> Void)) {
        database.collection(firebaseUser).addSnapshotListener { data, err in
            
            if err == nil {
                
                if let recored = data {
                    
                    var arrOfData:[MDLLoginData] = recored.documents.map { data in
                        
                        var dictData: MDLLoginData?
                        
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data.data(), options: [])
                            dictData = try JSONDecoder().decode(MDLLoginData.self, from: jsonData)
                            
                        } catch {
                            print("error")
                        }
                        
                        return dictData ?? MDLLoginData()
                    }
                    
                    arrOfData = arrOfData.filter({ $0.id != FirebaseHelper.id})
                    compilation(arrOfData)
                }
            } else {
                print(err?.localizedDescription.description ?? "","fetch user data")
            }
        }
    }
    
    
    //MARK: - get room id
    func getRoom_id(sender:String,receiver:String) -> String? {
        
        if receiver < sender {
            return "\(receiver)_\(sender)"
        } else {
            return "\(sender)_\(receiver)"
        }
    }
    
    //MARK: - Online status update
    func chatDataOnlineStatusUpdate(isOnline: Bool = false) {
        
        let dict = ["isSenderOnline": isOnline]
        let dictRec = ["isReceiverOnline": isOnline]
        
        database.collection(self.firebaseRoot).document().parent.whereField("senderId", isEqualTo: FirebaseHelper.id).getDocuments { data , error in
            
            if data?.documents.count ?? 0 > 0 {
                for recored in data?.documents ?? [] {
                    self.database.collection(self.firebaseRoot).document(recored.documentID).setData(dict,merge: true)
                }
            }
        }
        
        database.collection(self.firebaseRoot).document().parent.whereField("receiverId", isEqualTo: FirebaseHelper.id).getDocuments { data , error in
            if data?.documents.count ?? 0 > 0 {
                for recored in data?.documents ?? [] {
                    self.database.collection(self.firebaseRoot).document(recored.documentID).setData(dictRec,merge: true)
                }
            }
        }
    }
    
    //MARK: - get user Online status
    func userOnlineStatus(id:String, compilation: @escaping ((Bool?) -> Void)) {
        database.collection(firebaseUser).whereField("id", isEqualTo: id).addSnapshotListener { status, error in
            
            let dict = status?.documents.map({ $0.data()})
            
            if let status_online = dict?.first {
                compilation(status_online["online"] as? Bool)
            }
        }
    }
    
    //MARK: - read MSG status update
    func readStatusUpdate(senderId: String, receiverId: String) {
        
        let roomId = getRoom_id(sender: senderId, receiver: receiverId) ?? ""
        
        database.collection(self.firebaseRoot).document(roomId).collection(self.firebaseConver).document().parent.whereField("receiverId", isEqualTo: FirebaseHelper.id).whereField("readStatus", isEqualTo: 1).getDocuments { data, error in
            
            for doc in data?.documents ?? [] {
                self.database.collection(self.firebaseRoot).document(roomId).collection(self.firebaseConver).document(doc.documentID).updateData(["readStatus": 0])
            }
        }
    }
    
    //MARK: - get user typing status
    func typingStatusUpdate(senderId: String, receiverId: String, isSenderTyping: Bool = false) {
        
        let roomId = getRoom_id(sender: senderId, receiver: receiverId) ?? ""
            
        self.database.collection(self.firebaseRoot).document(roomId).setData(["typeData": ["\(senderId)":["id": senderId, "isTyping": isSenderTyping]]],merge: true)
    }
    
    func chatReactionUpdate(senderId: String, receiverId: String, strChatReaction: String, isReaction:Bool, msg:String, timetamp: Int) {
        let roomId = getRoom_id(sender: senderId, receiver: receiverId) ?? ""

        database.collection(firebaseRoot).document(roomId).collection(firebaseConver).whereField("msg", isEqualTo: msg).whereField("timestamp", isEqualTo: timetamp).getDocuments { data, error in
            
            for doc in data?.documents ?? [] {
                self.database.collection(self.firebaseRoot).document(roomId).collection(self.firebaseConver).document(doc.documentID).setData(["chatReactionType": ["\(senderId)":["isReaction": isReaction, "reactionTxt": strChatReaction]]], merge: true)
            }
        }
    }
}
