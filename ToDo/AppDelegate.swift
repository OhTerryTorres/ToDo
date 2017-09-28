//
//  AppDelegate.swift
//  ToDo
//
//  Created by TerryTorres on 3/24/17.
//  Copyright © 2017 Terry Torres. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var taskDataSynchronizer: TaskDataSynchronizer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
            { (granted, error) in
                
        }
        application.registerForRemoteNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveAllStores()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        taskDataSynchronizer.refresh()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveAllStores()
    }
    
    func saveAllStores() {
        UserDefaults.standard.synchronize()
        taskDataSynchronizer.saveData()
        saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                let loadErrorAlert = UIAlertController(title: "Load Error", message: "ToDo seems to have run into an error while loading your data. If error persists, reinstall ToDo.", preferredStyle: .alert)
                self.window?.rootViewController?.present(loadErrorAlert, animated: false)
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        print("saving main context")
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let saveErrorAlert = UIAlertController(title: "Save Error", message: "ToDo seems to have run into an error while saving your data. If error persists, reinstall ToDo.", preferredStyle: .alert)
                self.window?.rootViewController?.present(saveErrorAlert, animated: false)
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        UserDefaults.standard.set(deviceTokenString, forKey: UserKeys.deviceToken.rawValue)
        print("device token is \(deviceTokenString)")
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for notifications: \(error)")
    }

    func application(_ application: UIApplication,
                              didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                              fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Notification received")
    }
}

