//
//  CommonFunction.swift
//  FirebaseChat
//
//  Created by MQI-1 on 18/05/22.
//

import UIKit

class CommonFunction: NSObject {
    
    static let format = DateFormatter()
    
    class func getStringTimestampDate(timestamp:Int, withFormat:String, toFormat: String) -> String {
        format.dateFormat = withFormat
        let date = Date(milliseconds: Int64(timestamp))
        format.dateFormat = toFormat
        return format.string(from: date )
    }
    
    class func getStringDate(date:Date, toFormat: String) -> String {
        format.dateFormat = toFormat
        return format.string(from: date)
    }
    
    class func showAlertWithOk(vc: UIViewController, msg: String) {
        let alert = UIAlertController(title: "Chat app", message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    class func getUserData() -> MDLLoginData {
        
        guard  let data = UserDefaults.standard.value(forKey: "LoginUser")  else { return MDLLoginData() }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let data = try JSONDecoder().decode(MDLLoginData.self, from: jsonData)
            return data
        } catch {
            print("error")
        }
        
        return MDLLoginData()
    }
    
}
