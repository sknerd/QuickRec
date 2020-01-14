//
//  AppDelegate.swift
//  QuickRec
//
//  Created by renks on 14.01.2020.
//  Copyright © 2020 renks. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.rootViewController = createTabbar()
        window?.makeKeyAndVisible()
        
        configureNavigationBar()
        
        return true
    }
    
    func createRecordNC() -> UINavigationController {
        let recordVC = RecordVC()
        recordVC.title = "Record"
        recordVC.tabBarItem = UITabBarItem(title: "Record", image: UIImage(named: "record"), tag: 0)
        return UINavigationController(rootViewController: recordVC)
    }
    
    
    func createRecordingsNC() -> UINavigationController {
        let recordingsVC = RecordingsVC()
        recordingsVC.title = "My Recordings"
        recordingsVC.tabBarItem = UITabBarItem(title: "Listen", image: UIImage(named: "recordings"), tag: 1)
        return UINavigationController(rootViewController: recordingsVC)
    }
    
    
    func createTabbar() -> UITabBarController {
        let tabbar = UITabBarController()
        UITabBar.appearance().tintColor = .systemRed
        
        tabbar.viewControllers = [createRecordNC(), createRecordingsNC()]
        
        return tabbar
    }
    
    func configureNavigationBar() {
        UINavigationBar.appearance().tintColor = .systemRed
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

