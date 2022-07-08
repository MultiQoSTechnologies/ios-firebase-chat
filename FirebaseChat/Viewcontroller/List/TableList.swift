//
//  TableListTableViewController.swift
//  FirebaseChat
//
//  Created by MQI-1 on 22/04/22.
//

import UIKit

class TableList: UITableView {

    var arrOfList:[MDLChatData] = []
    var didSelect: DataBind<Int?> = DataBind<Int?>(nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialization()
    }

    fileprivate func initialization() {
        self.delegate = self
        self.dataSource = self
        self.reloadData()
    }
}


extension TableList: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOfList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as? ChatListCell else { return UITableViewCell()}
        let data = self.arrOfList[indexPath.row]
        cell.initialization(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect.value = indexPath.row
    }
}
