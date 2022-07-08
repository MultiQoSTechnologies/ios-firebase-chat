//
//  ChatDetailVC.swift
//  FirebaseChat
//
//  Created by MQI-1 on 22/04/22.
//

import UIKit
import ContactsUI
import MobileCoreServices
import SDWebImage
import SwiftUI

class ChatDetailVC: UIViewController {
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewHeader: NSLayoutConstraint!
    @IBOutlet weak var cnTxtviewButtom: NSLayoutConstraint!
    @IBOutlet weak var viewData: HeaderView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var txtMsg: UITextView! {
        didSet {
            var topCorrection = (txtMsg.bounds.size.height - txtMsg.contentSize.height * txtMsg.zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            txtMsg.contentInset = UIEdgeInsets(top: topCorrection + 4, left: 0, bottom: 0, right: 0)
        }
        
    }
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtViewHegiht: NSLayoutConstraint!
    @IBOutlet weak var tblDetail: TableDetail! {
        didSet {
            tblDetail.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
            tblDetail.transform = tblDetail.transform.rotated(by: .pi)
            tblDetail.navigation = self.navigationController
        }
    }
    
    var format = DateFormatter()
    var userData: MDLLoginData?
    var chatsData: DataBind<MDLChatData?> = DataBind<MDLChatData?>(nil)
    var countData: MDLChatData?
    var timer: Timer!
    var fileName = ""
    var type: TypeMsg = .text
    var senderImag: UIImage?
    var thumb = ""
    var receiverOnline: Bool = false
    var senderOnline: Bool = false
    var senderTyping = false
    var timestamp:Int =  Date().millisecondsSince1970
    var userTypeData: MDLItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialization()
        self.addDoneButtonOnKeyboard()
        
        chatsData.subscribe { data in
            self.countData = data
            self.setUpData()
        }
        // get history data
        self.getChatHistoryData()
        
        tblDetail.chatReaction.subscribe { data in
            
            if let `data` = data?.0 {
                self.emojisViewClick(gesture: data)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewData.imgUser.layer.cornerRadius = (viewData.imgUser.frame.width) / 2
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initialization() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        viewMain.layer.cornerRadius = 32
        viewMain.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        format.dateFormat = "dd-MM-yyyy hh:mm:ss"
        
        viewData?.lblTitle.text = self.userData?.userName ?? ""
        viewData?.lblTitle.textColor = UIColor(named: "TheamColor")
        viewData?.backgroundColor = .white
        viewData.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        viewData?.imgUser.sd_setImage(with: URL(string: self.userData?.profileImg ?? ""), completed: nil)
        viewData?.viewImage.isHidden = false
        viewData?.viewSearch.isHidden = true
        viewData?.btnBack.isHidden = false
        viewData?.btnBack.addTarget(self, action: #selector(btnBack(sender:)), for: .touchUpInside)
        
        FirebaseHelper.share.userOnlineStatus(id: self.userData?.id ?? "") { isSuccess in
            self.receiverOnline = isSuccess ?? false
            self.onlineUser(isOnline: self.receiverOnline)
        }
        
        FirebaseHelper.share.userOnlineStatus(id: FirebaseHelper.id) { isSuccess in
            self.senderOnline = isSuccess ?? false
        }
    }
    
    private func getChatHistoryData() {
        
        // fetch updated data and insert only new data
        FirebaseHelper.share.fetchData(isLoadMore: false, sender: FirebaseHelper.id, receiver: self.userData?.id ?? "", compilation: { (id,listData)  in
            
            guard let `listData` = listData else {
                return
            }
            
            if listData.count == 0 && self.tblDetail.arrOfList.count == 0 {
                self.tblDetail.setEmptyMessage("No data")
                self.tblDetail.backgroundView?.transform = self.tblDetail.backgroundView?.transform.rotated(by: .pi) ?? self.tblDetail.transform
            } else {
                self.tblDetail.restore()
            }
            
            if self.tblDetail.arrOfList.count == 0 {
                self.tblDetail.arrOfList = listData
                self.lblHeader.text = listData.last?.rowData.first?.date
                self.tblDetail.reloadData()
            } else {
                
                let tblList = self.tblDetail.arrOfList
                
                if tblList.first?.title == listData.first?.title {
                    
                    for data in listData.first?.rowData ?? [] {
                        if let tblData = tblList.first?.rowData {
                            let filterData = tblData.filter({ $0.timestamp == data.timestamp})
                            if filterData.count == 0 {
                                self.tblDetail.arrOfList[0].rowData.insert(data, at: 0)
                                self.tblDetail.reloadData()
                            } else {
                                
                                if let listTblData = tblList.first?.rowData {
                                    let index = listTblData.firstIndex(where: { $0.timestamp == data.timestamp})
                                    if let inx = index {
                                        let msgType = tblList.first?.rowData[inx].type
                                        let types = TypeMsg(rawValue: msgType ?? "text")
                                        if types == .image && tblList.first?.rowData[inx].img == nil {
                                            self.tblDetail.arrOfList[0].rowData[inx].file = data.file
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                                self.tblDetail.reloadRows(at: [IndexPath(row: inx, section: 0)], with: .none)
                                            }
                                        } else if (types == .video || types == .document) && (tblList.first?.rowData[inx].thumb == "" || tblList.first?.rowData[inx].file == "") && tblList.first?.rowData[inx].img == nil && (types == .document && tblList.first?.rowData[inx].file == ""){
                                            
                                            self.tblDetail.arrOfList[0].rowData[inx].file = data.file
                                            self.tblDetail.arrOfList[0].rowData[inx].thumb = data.thumb
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                                self.tblDetail.reloadRows(at: [IndexPath(row: inx, section: 0)], with: .none)
                                            }
                                        }
                                        
                                        if tblList.first?.rowData[inx].readStatus != data.readStatus {
                                            self.tblDetail.arrOfList[0].rowData[inx].readStatus = data.readStatus
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                                self.tblDetail.reloadRows(at: [IndexPath(row: inx, section: 0)], with: .none)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    
                    if let data = listData.first {
                        self.tblDetail.arrOfList.insert(data, at: 0)
                        self.tblDetail.reloadData()
                    }
                }
            }
            
        })
        
        // chat history scroll display date header
        tblDetail.isViewHide.subscribe { Hidden in
            guard let ishidden = Hidden else { return }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                if ishidden {
                    self.viewHeader.constant = -45
                } else {
                    self.viewHeader.constant = 40
                }
                self.view.layoutIfNeeded()
            } completion: { success in
            }
            
        }
        
        tblDetail.displaySection.subscribe { section in
            guard let section = section else { return }
            if self.tblDetail.arrOfList.count > 0 {
                self.lblHeader.text = self.tblDetail.arrOfList[section].rowData.first?.date
            }
        }
        tblDetail.receiverId = self.userData?.id ?? ""
    }
    
    private func setUpData() {
        
        // get user online status
        if countData?.senderId != FirebaseHelper.id {
            self.onlineUser(isOnline: countData?.isSenderOnline ?? false)
        } else {
            self.onlineUser(isOnline: countData?.isReceiverOnline ?? false)
        }
        
        for typedata in countData?.typeData ?? [:] {
            if typedata.key != FirebaseHelper.id {
                userTypeData = typedata.value
            } else {
                senderTyping = typedata.value.isTyping ?? false
            }
        }
        
        if let userType  = userTypeData {
            if userType.isTyping ?? false {
                self.viewData?.lblTyping.isHidden = false
            } else {
                self.viewData?.lblTyping.isHidden = true
            }
        }
    }
    
    private func onlineUser(isOnline: Bool) {
        if isOnline {
            self.viewData?.lblOnlineStatus.backgroundColor = .green
        } else {
            self.viewData?.lblOnlineStatus.backgroundColor = .red
        }
    }
    
    // send document like pdf,img,word file etc
    private func documentData(documentURL: URL, name: String, thumbImg: UIImage?) {
        
        self.fileName = documentURL.absoluteString
        self.senderImag = thumbImg
        timestamp = Date().millisecondsSince1970
        let updateTime: Int = timestamp
        
        if type == .document {
            self.btnSend(sender: UIButton())
            
            FirebaseHelper.share.addDocument(DocumentUrl: documentURL, DocumentName: name) { documenturl in
                self.fileName = ""
                FirebaseHelper.share.updateImageLink(dict: ["file": documenturl],time: updateTime, sender: FirebaseHelper.id, receiver: self.userData?.id ?? "")
            }
            
            if thumbImg != nil {
                let data = thumbImg?.pngData()
                FirebaseHelper.share.addImage(imgData: data) { url in
                    self.thumb = ""
                    self.senderImag = nil
                    FirebaseHelper.share.updateImageLink(dict: ["thumb": url],time: updateTime, sender: FirebaseHelper.id, receiver: self.userData?.id ?? "")
                }
            }
        }
        
    }
    
    private func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        txtMsg.inputAccessoryView = doneToolbar
    }
    
    // upload image and video thumbnail in firebase storage
    private func uploadImageToFirebase(img: UIImage?, url: URL?) {
        
        timestamp = Date().millisecondsSince1970
        let updateTime: Int = timestamp
        
        if let `img` = img {
            self.type = .image
            self.senderImag = img
            self.btnSend(sender: UIButton())
            
        } else {
            
            if let `url` = url {
                self.type = .video
                self.fileName = url.absoluteString
                self.senderImag = url.generateThumbnail()
                self.btnSend(sender: UIButton())
                
                if let videoData = try? Data(contentsOf: url) {
                    FirebaseHelper.share.addVideo(video: videoData) { videoUrl in
                        self.fileName = ""
                        FirebaseHelper.share.updateImageLink(dict: ["file": videoUrl],time: updateTime, sender: FirebaseHelper.id, receiver: self.userData?.id ?? "")
                    }
                }
            }
        }
        
        FirebaseHelper.share.addImage(imgData: senderImag?.jpegData(compressionQuality: 0.6)) { imgName in
            print(updateTime)
            self.fileName = ""
            self.senderImag = nil
            
            if img == nil {
                FirebaseHelper.share.updateImageLink(dict: ["thumb": imgName],time: updateTime, sender: FirebaseHelper.id, receiver: self.userData?.id ?? "")
            } else {
                FirebaseHelper.share.updateImageLink(dict: ["file": imgName],time: updateTime, sender: FirebaseHelper.id, receiver: self.userData?.id ?? "")
            }
        }
    }
    
    @objc func doneButtonAction(){
        txtMsg.resignFirstResponder()
    }
    
    @objc func timerStop() {
        timer?.invalidate()
        timer = nil
        FirebaseHelper.share.typingStatusUpdate(senderId: FirebaseHelper.id, receiverId: self.userData?.id ?? "", isSenderTyping: false)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.6) {
                self.cnTxtviewButtom.constant = keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.6) {
            self.cnTxtviewButtom.constant = 8
        }
    }
    
    @objc func btnBack(sender: UIButton) {
        FirebaseHelper.share.lastDocument = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSend(sender: UIButton) {
        
        if  (self.type == .text && txtMsg.text.count > 1) || (fileName == "" && senderImag != nil) || fileName != "" {
            self.btnSend.isUserInteractionEnabled = false
            
            if type == .text {
                timestamp = Date().millisecondsSince1970
            }
            
            self.format.dateFormat = "dd-MM-yyyy"
            let date = self.format.string(from: Date())
            var imgData: Data!
            
            if type == .document {
                imgData = self.senderImag?.pngData()
            } else {
                imgData = self.senderImag?.jpegData(compressionQuality: 1)
            }
            
            let chat = MDLChatData(senderName: CommonFunction.getUserData().userName, senderId: FirebaseHelper.id, senderImage: CommonFunction.getUserData().profileImg, receiverName: self.userData?.userName ?? "", receiverId: self.userData?.id ?? "", receiverImage: self.userData?.profileImg ?? "", msg: self.txtMsg.text.trim(), readStatus: 1, date: date, thumb: self.thumb, isReceiverOnline: receiverOnline, isSenderOnline: senderOnline, senderCount: self.countData?.senderCount ?? 0, receiverCount: self.countData?.receiverCount ?? 0, timestamp: timestamp, file: self.fileName, type: self.type.rawValue , img: imgData, typeData: self.countData?.typeData)
            
            self.format.dateFormat = "dd-MM-yyyy"
            let datestr = self.format.string(from: Date())
            let dates = self.format.date(from: datestr)
            
            if self.tblDetail.arrOfList.contains(where: { date in
                return date.title == dates
            }) {
                self.tblDetail.arrOfList[0].rowData.insert(chat, at: 0)
                self.tblDetail.beginUpdates()
                self.tblDetail.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.tblDetail.endUpdates()
            } else {
                let header = MDLChatHeader(title: dates, rowData: [chat], displayHeader: true)
                self.tblDetail.arrOfList.insert(header, at: 0)
                self.tblDetail.beginUpdates()
                self.tblDetail.insertSections(IndexSet(integer: 0), with: .automatic)
                self.tblDetail.endUpdates()
            }
            self.timerStop()
            FirebaseHelper.share.addData(data: chat)
            
            self.txtMsg.text = ""
            self.type = .text
            self.txtViewHegiht.constant = 50
            self.btnSend.isUserInteractionEnabled = true
        }
    }
    
    // Media type
    @IBAction func btnPlus(sender: UIButton) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "Option", message: "Please Select an Option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
            MediaHelper.share.cameraMedia(vc: self) { cameraImg, url in
                self.uploadImageToFirebase(img: cameraImg, url: url)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Photo & Video Library", style: .default , handler:{ (UIAlertAction)in
            MediaHelper.share.photoLibraryMedia(vc: self) { photo, videoUrl in
                self.uploadImageToFirebase(img: photo, url: videoUrl)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Document", style: .default , handler:{ (UIAlertAction)in
            let importMenu = UIDocumentPickerViewController(documentTypes: ["public.text", "com.apple.iwork.pages.pages",  "com.apple.iwork.numbers.numbers","com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text", "public.data", "com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document", kUTTypePDF as String], in: UIDocumentPickerMode.import)
            importMenu.delegate = self
            self.present(importMenu, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    func emojisViewClick(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.tblDetail)
        var points: CGFloat!
        var index: IndexPath!
        
        if let indexPath = self.tblDetail.indexPathForRow(at: p) {
            // get the cell at indexPath (the one you long pressed)
            print(indexPath)
            index = indexPath
            if let cell = self.tblDetail.cellForRow(at: indexPath) {
                let  point =  cell.contentView.superview!.convert((cell.contentView.frame.origin), to: self.view)
                
                if (self.view.frame.height - (150 + cell.frame.height)) <= point.y {
                    points = point.y - (cell.frame.height + 32)
                } else {
                    points = point.y + 32
                }
                print(p,"points.....")
            }
            // do stuff with the cell
        } else {
            print("couldn't find index path")
        }
        
        let viewEmo: ChatEmojiView = .fromNib()
        
        viewEmo.frame = self.view.frame
        let data = self.tblDetail.arrOfList[index.section].rowData[index.row]
        
        for typeData in data.chatReactionType ?? [:] {
            if typeData.key == FirebaseHelper.id {
                viewEmo.reactionStr = typeData.value.reactionTxt
            }
        }
        
        viewEmo.action = { (success, reaction) in
            
            if index != nil {
                print(success)
                FirebaseHelper.share.chatReactionUpdate(senderId: FirebaseHelper.id, receiverId: self.userData?.id ?? "", strChatReaction: success, isReaction: reaction, msg:  self.tblDetail.arrOfList[index.section].rowData[index.row].msg!, timetamp:   self.tblDetail.arrOfList[index.section].rowData[index.row].timestamp!)
                
                //                if !reaction {
                //                    self.tblDetail.arrOfList[index.section].rowData[index.row].chatReactionType[FirebaseHelper.id] = MLChatReactionData(isReaction: reaction, reactionTxt: "")
                //
                //                } else {
                //                    self.tblDetail.arrOfList[index.section].rowData[index.row].chatReactionType[FirebaseHelper.id] = MLChatReactionData(isReaction: reaction, reactionTxt: success)
                //                }
                //
                //                self.tblDetail.beginUpdates()
                //                self.tblDetail.reloadRows(at: [index], with: .fade)
                //                self.tblDetail.endUpdates()
            }
            viewEmo.removeFromSuperview()
        }
        
        viewEmo.backAction = { (success, reaction) in
            viewEmo.removeFromSuperview()
        }
        viewEmo.topCons(points)
        self.view.addSubview(viewEmo)
    }
}


extension ChatDetailVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerStop), userInfo: nil, repeats: false)
        
        // set user typing status
        if !senderTyping {
            print("call")
            FirebaseHelper.share.typingStatusUpdate(senderId: FirebaseHelper.id, receiverId: self.userData?.id ?? "", isSenderTyping: true)
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.timerStop()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.contentSize.height <= 90 && textView.contentSize.height >= 50 {
            self.txtViewHegiht.constant = textView.contentSize.height
        } else {
            if textView.contentSize.height <= 50 {
                self.txtViewHegiht.constant = 50
            } else {
                self.txtViewHegiht.constant = 90
            }
        }
    }
}

extension ChatDetailVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let documentURL = url as URL
        print(url.lastPathComponent)
        print(url.pathExtension)
        self.type = .document
        let exten = url.pathExtension.lowercased()
        if  exten == "png" || exten == "jpg" || exten == "jpeg" {
            self.dismiss(animated: true, completion: nil)
            documentData(documentURL: documentURL, name: url.lastPathComponent, thumbImg: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "DocumentVC") as? DocumentVC else { return }
            vc.fileUrl = documentURL
            vc.action = { thumb in
                self.documentData(documentURL: documentURL, name: url.lastPathComponent, thumbImg: thumb)
            }
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
