//
//  DocumentVC.swift
//  FirebaseChat
//
//  Created by MQI-1 on 12/05/22.
//

import UIKit
import WebKit

class DocumentVC: UIViewController {
    
    @IBOutlet weak private var webView: WKWebView!
    @IBOutlet weak private var viewWeb: UIView!
    
    var fileUrl: URL!
    var action: ((UIImage) -> Void)?
    var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialization()
    }
    
    private func initialization() {
        viewWeb.layer.cornerRadius = 32
        viewWeb.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
        activity = UIActivityIndicatorView()
        activity.center = self.view.center
        activity.hidesWhenStopped = true
        activity.style = UIActivityIndicatorView.Style.medium
        
        webView.load(URLRequest(url: fileUrl))
        webView.navigationDelegate = self
        self.webView.addSubview(self.activity)
        self.activity.startAnimating()
    }
    
    @IBAction private func btnDone(sender: UIButton) {
        
        if action != nil {
            webView.takeSnapshot(with: nil) {image, error in
                if let image = image {
                    self.action!(image)
                } else {
                    print("Failed taking snapshot: \(error?.localizedDescription ?? "--")")
                }
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction private func btnCancel(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension DocumentVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activity.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activity.stopAnimating()
    }
}
