//
//  TableSearch.swift
//  FirebaseChat
//
//  Created by MQI-1 on 26/04/22.
//

import UIKit

final class TableSearch: UITableView {
    
    var arrOfList:[MDLLoginData] = []
    var selectedRow: DataBind<Int?> = DataBind<Int?>(nil)

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

extension TableSearch: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.arrOfList[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as? SearchCell else { return UITableViewCell()}
        cell.lblId.text = data.userName ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow.value = indexPath.row
    }
}

