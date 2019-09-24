//
//  AppDelegate.swift
//  PowerNapTimer
//
//  Created by Matthew O'Connor on 9/24/19.
//  Copyright © 2019 Matthew O'Connor. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){(granted, error) in
        if let error = error {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
            if !granted {
                print("notifications disabled")
            }
        }
        return true
    }


}

