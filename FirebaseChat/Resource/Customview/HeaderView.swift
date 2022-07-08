//
//  HeaderView.swift
//  FirebaseChat
//
//  Created by MQI-1 on 29/04/22.
//

import UIKit

class HeaderView: UIView {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblOnlineStatus: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var lblTyping: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib()
    }
        
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "HeaderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
    }
    
}
