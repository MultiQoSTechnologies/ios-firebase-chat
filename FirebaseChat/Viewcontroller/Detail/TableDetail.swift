//
//  TableDetail.swift
//  FirebaseChat
//
//  Created by MQI-1 on 22/04/22.
//

import UIKit
import SDWebImage
import AVKit
import AVFoundation

class TableDetail: UITableView {
    
    var arrOfList:[MDLChatHeader] = []
    var format = DateFormatter()
    var receiverId = ""
    var room = ""
    var isViewHide: DataBind<Bool?> = DataBind<Bool?>(nil)
    var displaySection: DataBind<Int?> = DataBind<Int?>(nil)
    var chatReaction: DataBind<(UILongPressGestureRecognizer?,Bool?)?> = DataBind<(UILongPressGestureRecognizer?,Bool?)?>(nil)
    var navigation: UINavigationController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialization()
    }
    
    fileprivate func initialization() {
        self.delegate = self
        self.dataSource = self
        self.reloadData()
    }
    
    @objc func chatReactionClick(gesture: UILongPressGestureRecognizer) {
        self.chatReaction.value = (gesture,true)
    }
}

extension TableDetail: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrOfList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOfList[section].rowData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = self.arrOfList[indexPath.section].rowData[indexPath.row]
        let types = TypeMsg(rawValue: data.type ?? "text")
        
        if data.senderId != FirebaseHelper.id {
            if types == .text {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecevierCell") as? RecevierCell else { return UITableViewCell()}
                cell.initialization(data: data)
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(chatReactionClick))
                cell.addGestureRecognizer(longPress)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecceiverimgCell") as? ImageCell else { return UITableViewCell()}
                cell.initialization(data: data)
                return cell
            }
        } else {
            if types == .text {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell") as? SenderCell else { return UITableViewCell()}
                cell.initialization(data: data)
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(chatReactionClick))
                cell.addGestureRecognizer(longPress)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SenderimgCell") as? ImageCell else { return UITableViewCell()}
                cell.initialization(data: data)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
       
        guard let footerview = Footerview().loadViewFromNib()  else { return UIView() }
        if let date = self.arrOfList[section].title {
            footerview.lblheaderTitle.text = CommonFunction.getStringDate(date: date, toFormat: "dd-MM-yyyy")
        }
        return footerview
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let data = self.arrOfList[section].displayHeader
       
        if data {
            return 60
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = self.arrOfList[indexPath.section].rowData[indexPath.row]
        let story = UIStoryboard(name: "Main", bundle: nil)
        let types = TypeMsg(rawValue: data.type ?? "text")
        
        if types == .video {
            guard let videoURL = URL(string: data.file ?? "") else { return }
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            navigation?.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        } else if types == .document {
            if data.thumb != "" {
                guard let vc = story.instantiateViewController(withIdentifier: "DocumentVC") as? DocumentVC else { return }
                vc.fileUrl = URL(string: data.file ?? "")
                vc.modalPresentationStyle = .overFullScreen
                navigation?.present(vc, animated: true, completion: nil)
            }
        } else if types == . image{
            guard let vc = story.instantiateViewController(withIdentifier: "PhotoVC") as? PhotoVC else { return }
            if data.file == "" {
                if let data = data.img {
                    vc.photoImg = UIImage(data: data)
                }
            } else {
                vc.photourl = data.file ?? ""
            }
            vc.modalPresentationStyle = .overFullScreen
            navigation?.present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let vc = navigation?.topViewController {
            if vc.isKind(of: ChatDetailVC.self) {
                FirebaseHelper.share.readStatusUpdate(senderId: FirebaseHelper.id, receiverId: self.receiverId)
            }
        }
        displaySection.value = self.indexPathsForVisibleRows?.last?.section
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Get history data to scroll chat detail screen
        if self.contentOffset.y >= (self.contentSize.height - self.frame.size.height) && FirebaseHelper.share.loadMore && self.arrOfList.count > 0{
            FirebaseHelper.share.fetchData(isLoadMore: true, sender: FirebaseHelper.id, receiver: self.receiverId) { (id,listData) in
                self.room = id
                for data in listData ?? [] {
                    if self.arrOfList.contains(where: { d in
                        return d.title == data.title
                    }) {
                        let index = self.arrOfList.firstIndex(where: { $0.title == data.title})
                        if let `index` = index {
                            self.arrOfList[index].rowData.append(contentsOf: data.rowData)
                        }
                    } else {
                        self.arrOfList.append(data)
                        if self.arrOfList.count > 1 {
                            self.arrOfList[self.arrOfList.count - 2].displayHeader = true
                        }
                    }
                }
                
                //chat history header display
                FirebaseHelper.share.getDisplayHeader(date: self.arrOfList[self.arrOfList.count - 1].title, roomId: self.room) { isDisplayheader in
                    self.arrOfList[self.arrOfList.count - 1].displayHeader = isDisplayheader
                    if isDisplayheader {
                        self.reloadSections(IndexSet(integer: self.arrOfList.count - 1), with: .none)
                    }
                }
                self.reloadData()
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isViewHide.value = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isViewHide.value = true
    }
}
