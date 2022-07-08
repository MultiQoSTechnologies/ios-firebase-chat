//
//  SceneDelegate.swift
//  FirebaseChat
//
//  Created by MQI-1 on 22/04/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        self.setRootVC()
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        self.updateDataOnline(isOnline: false)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        self.updateDataOnline(isOnline: true)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        self.updateDataOnline(isOnline: false)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        self.updateDataOnline(isOnline: true)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        self.updateDataOnline(isOnline: false)
    }
    
    func updateDataOnline(isOnline: Bool) {
        
        if UserDefaults.standard.value(forKey: "LoginUser") != nil {
            
            let dict: [String:Any] = ["id":  FirebaseHelper.id,
                                      "online": isOnline]
            FirebaseHelper.share.addUserRecord(dict: dict)
            FirebaseHelper.share.chatDataOnlineStatusUpdate(isOnline: isOnline)
        }
    }
    
    func setRootVC() {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        var vc: UIViewController?
        
        if UserDefaults.standard.value(forKey: "LoginUser") != nil {
            vc = story.instantiateViewController(withIdentifier: "ChatListVC") as? ChatListVC
            self.updateDataOnline(isOnline: true)
        } else {
            vc = story.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        }
        
        if let viewcontroller = vc {
            let navigation = UINavigationController.init(rootViewController: viewcontroller)
            navigation.isNavigationBarHidden = true
            self.window?.rootViewController = navigation
            self.window?.makeKeyAndVisible()
        }
    }
}

