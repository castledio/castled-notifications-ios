//
//  Castled.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import UserNotifications
import UIKit

@objc public protocol CastledNotificationDelegate  {
    
    func castledNotificationsManager(didRegisterForRemoteNotificationsWithDeviceToken token: String)
    func castledNotificationsManager(didFailToRegisterForRemoteNotificationsWithError error: Error)
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    
}

public class Castled : NSObject
{
    public static var sharedInstance: Castled?
    private var appDelegate: UIApplicationDelegate
    private var application: UIApplication
    private var shouldClearDeliveredNotifications = true
    var instanceId: String
    let delegate: CastledNotificationDelegate
   
    /**
     Static method for conguring the Castled framework.
     */
    @objc static public func configure(registerIn application: UIApplication,launchOptions : [UIApplication.LaunchOptionsKey: Any]? ,instanceId: String,delegate: CastledNotificationDelegate,clearNotifications : NSNumber? = 1) {
        
        if Castled.sharedInstance == nil {
            Castled.sharedInstance = Castled.init(registerIn: application, launchOptions: launchOptions, instanceId: instanceId, delegate: delegate)
        }
        
    }
    
    
    private init(registerIn application: UIApplication,launchOptions : [UIApplication.LaunchOptionsKey: Any]? ,instanceId: String,delegate: CastledNotificationDelegate,clearNotifications : NSNumber? = 1) {
        
        self.application = application
        self.appDelegate = application.delegate!
        self.instanceId  = instanceId
        self.delegate    = delegate
        
        super.init()
        
        if Castled.sharedInstance == nil {
            Castled.sharedInstance = self
        }
        shouldClearDeliveredNotifications = ((clearNotifications?.boolValue) != nil)
        registerForPushNotifications()
    }
    
    
    // MARK: - Private
    // Method to register for push notification
    private func registerForPushNotifications() {
        
        CastledSwizzler.enableSwizzlingForNotifications(in: self.appDelegate)
        
        // Setting the UNUserNotificationCenter delegate to self
        let center = UNUserNotificationCenter.current()
        center.delegate = Castled.sharedInstance
        // The notification elements we care about
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        // Register for remote notifications.
        // This shows a permission dialog on first run,
        // to show the dialog at a more appropriate time
        // move this registration accordingly.
        processAllDeliveredNotificatoins(shouldClear: shouldClearDeliveredNotifications)
        center.requestAuthorization(options: options) { (granted, _) in
            print("Push Notification Permission granted: \(granted)")
            guard granted else {
                //Please enable push notifications for this app in the iOS settings."
                return
                
            }
            DispatchQueue.main.async {
                Castled.sharedInstance!.application.registerForRemoteNotifications()
            }
        }
        
        
    }
    /**
     Function that allows users to set the badge on the app icon manually.
     */
    public func setBadge(to count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
  
    
}


