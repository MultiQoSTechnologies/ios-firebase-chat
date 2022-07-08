//
//  MediaHelper.swift
//  FirebaseChat
//
//  Created by MQI-1 on 24/05/22.
//

import UIKit

class MediaHelper: NSObject {
    
    static let share = MediaHelper()
    fileprivate let imagePickerController = UIImagePickerController()
    fileprivate var selectedImg : ((UIImage?, URL?) -> Void)?
    
    func cameraMedia(vc: UIViewController, completion: @escaping ((UIImage?, URL?) -> Void)) {
        self.imagePickerController.sourceType = .camera
        self.imagePickerController.delegate = self
        vc.present(self.imagePickerController, animated: true, completion: nil)
        self.selectedImg = completion
    }
    
    func photoLibraryMedia(vc: UIViewController, completion: @escaping ((UIImage?, URL?) -> Void)) {
        self.imagePickerController.sourceType = .photoLibrary
        self.imagePickerController.delegate = self
        self.imagePickerController.mediaTypes = ["public.image","public.movie"]
        vc.present(self.imagePickerController, animated: true, completion: nil)
        self.selectedImg = completion
    }
    
}

extension MediaHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            if let img = info[.originalImage] as? UIImage {
                self.selectedImg?(img, nil)
            } else {
                if let videoURL = info[.mediaURL] as? URL {
                    self.selectedImg?(nil, videoURL)
                }
            }
        }       
    }
}
