//
//  PhotoVC.swift
//  FirebaseChat
//
//  Created by MQI-1 on 24/05/22.
//

import UIKit
import SDWebImage

class PhotoVC: UIViewController {
    
    @IBOutlet weak private var imgPhoto: UIImageView!
    
    var photourl: String = ""
    var photoImg: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if photoImg != nil {
            imgPhoto.image = photoImg
        } else {
            imgPhoto.sd_setImage(with: URL(string: photourl))
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction private func btnDone(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
