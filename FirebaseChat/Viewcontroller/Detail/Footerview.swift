//
//  FooterviewCell.swift
//  FirebaseChat
//
//  Created by MQI-1 on 18/05/22.
//

import UIKit

class Footerview: UIView {

    @IBOutlet weak var lblheaderTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.transform = self.transform.rotated(by: .pi)
    }
    
    func loadViewFromNib() -> Footerview? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "Footerview", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? Footerview
    }
}
