//
//  SearchVC.swift
//  FirebaseChat
//
//  Created by MQI-1 on 26/04/22.
//

import UIKit

class SearchVC: UIViewController {
    
    @IBOutlet private var tblsearch: TableSearch!
    @IBOutlet weak private var viewData: HeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserRecord()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewData?.lblTitle.text = "Search"
        viewData?.lblTitle.textColor = UIColor(named: "TheamColor")
        viewData?.backgroundColor = .white
        viewData?.viewSearch.isHidden = true
        viewData?.viewImage.isHidden = true
        viewData?.btnBack.isHidden = false
        viewData?.btnBack.addTarget(self, action: #selector(btnBack(sender:)), for: .touchUpInside)
        
    }
    
    private func getUserRecord() {
        FirebaseHelper.share.fetchUserRecord { userData in
            self.tblsearch.arrOfList = userData
            self.tblsearch.reloadData()
        }
        
        tblsearch.selectedRow.subscribe { row in
            guard let `row` = row else { return }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatDetailVC") as! ChatDetailVC
            let data = self.tblsearch.arrOfList[row]
            vc.userData = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func btnBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
