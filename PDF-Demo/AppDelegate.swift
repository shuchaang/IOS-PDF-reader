
//  AppDelegate.swift
//  PDF-Demo
//
//  Created by lan on 2017/6/27.
//  Copyright © 2017年 com.tzshlyt.demo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var db = UserDefaults.standard
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        if url.isFileURL && url.pathExtension.lowercased() == "pdf" {
                    // 处理 PDF 文件
                    print("接收到 PDF 文件，文件路径：\(url.path)")
                    // 将 PDF 文件复制到应用内的目标路径
                    let fileManager = FileManager.default
                    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
                    do {
                        try fileManager.copyItem(at: url, to: destinationURL)
                        db.set(1, forKey: destinationURL.absoluteString)
                        if let v = self.window?.rootViewController as? ViewController {
                            v.refreshData()
                        }
                        let alertController = UIAlertController(title: "Success", message: "File copied successfully.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        window?.rootViewController?.present(alertController, animated: true, completion: nil)
                    } catch {
                        let alertController = UIAlertController(title: "failed", message: "复制 PDF 文件到应用内失败：\(error.localizedDescription)", preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alertController.addAction(okAction)
                                    window?.rootViewController?.present(alertController, animated: true, completion: nil)
                        print("复制 PDF 文件到应用内失败：\(error.localizedDescription)")
                        return false
                    }
                }
                return false
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

