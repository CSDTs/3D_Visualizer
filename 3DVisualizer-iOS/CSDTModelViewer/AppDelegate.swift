//
//  AppDelegate.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/1/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit
import ARKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(false, forKey: "ThirdPartyLaunch")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.pathExtension == "stl" else { return true }
        UserDefaults.standard.set(true, forKey: "ThirdPartyLaunch")
        UserDefaults.standard.set(url, forKey: "OpenedModel")
        window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "picker")
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let type = shortcutItem.type.components(separatedBy: ".").last ?? ""
        switch type {
        case "OpenList":
            UserDefaults.standard.set(true, forKey: "OpenList")
        case "OpenLink":
            UserDefaults.standard.set(true, forKey: "OpenLink")
        case "OpenDefault":
            UserDefaults.standard.set(true, forKey: "OpenDefault")
        default:
            break
        }
        window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "picker")
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
    

}

