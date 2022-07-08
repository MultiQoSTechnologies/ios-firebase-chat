//
//  LoginVC.swift
//  FirebaseChat
//
//  Created by MQI-1 on 26/05/22.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnCamera: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnCamera(sender: UIButton) {
        MediaHelper.share.photoLibraryMedia(vc: self) { profile, url in
            self.btnCamera.setImage(nil, for: .normal)
            self.imgProfile.image = profile
        }
    }
    
    @IBAction func btnLogin(sender: UIButton) {
        
        if imgProfile.image == nil {
            CommonFunction.showAlertWithOk(vc: self, msg: "Please select profile image")
        } else if txtName.text?.count ?? 0 < 1 {
            CommonFunction.showAlertWithOk(vc: self, msg: "Please enter name")
        } else {
            
            FirebaseHelper.share.addImage(imgData: imgProfile.image?.jpegData(compressionQuality: 0.6)) { profileName in
                let dict: [String: Any] = ["profileImg": profileName,
                                           "userName": self.txtName.text?.trim() ?? "",
                                           "id": FirebaseHelper.id,
                                           "online": true]
                UserDefaults.standard.set(dict, forKey: "LoginUser")
                UserDefaults.standard.synchronize()
                FirebaseHelper.share.addUserRecord(dict: dict)
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
