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

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
    

}

