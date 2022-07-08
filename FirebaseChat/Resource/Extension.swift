//
//  Extension.swift
//  FirebaseChat
//
//  Created by MQI-1 on 22/04/22.
//

import Foundation
import UIKit
import AVFoundation

extension UIView {
    
    @IBInspectable fileprivate var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        } set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable fileprivate var round: Bool {
        get {
            return false
        } set {
            self.layer.cornerRadius = (self.frame.height + self.frame.width) / 4
        }
    }
    
    @IBInspectable fileprivate var borderColor: UIColor {
        get {
            return .clear
        } set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable fileprivate var borderWidth: CGFloat {
        get {
            return 0
        } set {
            self.layer.borderWidth = newValue
        }
    }
}

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}

extension String {
    
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
}

extension Date {
    var millisecondsSince1970: Int {
        Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension URL {
    func generateThumbnail() -> UIImage? {
        do {
            let asset = AVURLAsset(url: self)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)
            return UIImage(cgImage: cgImage)
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
