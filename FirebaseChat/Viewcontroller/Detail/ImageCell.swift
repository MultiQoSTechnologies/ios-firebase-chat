//
//  imgCell.swift
//  FirebaseChat
//
//  Created by MQI-1 on 09/05/22.
//

import UIKit
import WebKit
import SDWebImage

class ImageCell: UITableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var imgSeen: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.transform = self.transform.rotated(by: .pi)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initialization(data: MDLChatData) {
        
        let strTime = CommonFunction.getStringTimestampDate(timestamp: data.timestamp ?? 0, withFormat: "dd-MM-yyyy hh:mm:ss", toFormat: "hh:mm")
        self.activityView.style = UIActivityIndicatorView.Style.medium
        self.activityView.isHidden = false
        self.activityView.startAnimating()

        lblTime.text = strTime
        imgPlay.isHidden = true
        
        if imgSeen != nil {
            activityView.color = .white
            if data.readStatus == 0 {
                imgSeen.isHighlighted = true
            } else {
                imgSeen.isHighlighted = false
            }
        } else {
            activityView.color = .gray
        }
        
        let types = TypeMsg(rawValue: data.type ?? "text")
        
        if types == .image {
            if data.file != "" {
                self.img.isHidden = false
                self.setImageUrl(urlStr: data.file ?? "")
            } else if data.img != nil {
                self.setImg(img: data.img)
            } else {
                self.img.isHidden = true
            }
        } else {
            if types == .video {
                imgPlay.isHidden = false
            }
            
            if data.img != nil {
                self.setImg(img: data.img)
            } else if data.thumb != "" {
                self.img.isHidden = false
                self.setImageUrl(urlStr: data.thumb ?? "")
            } else if data.file != "" && types == .document {
                self.setImageUrl(urlStr: data.file ?? "")
            } else {
                self.img.isHidden = true
            }
        }
    }
    
   private func setImg(img:Data?) {
        self.activityView.stopAnimating()
        self.activityView.isHidden = true
       if let data = img {
           self.img.image = UIImage(data: data)
       }
    }
    
    private func setImageUrl(urlStr: String) {
        img.sd_setImage(with: URL(string: urlStr)) { img, err, types, url in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.activityView.stopAnimating()
                self.activityView.isHidden = true
            }
        }
    }
}
