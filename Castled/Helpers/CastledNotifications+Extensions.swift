//
//  CastledNotifications+Extensions.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import UserNotifications
import UIKit

//Extension for handling notifications
extension Castled : UNUserNotificationCenterDelegate {
    
    @objc public  func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let oldToken = CastledUserDefaults.getString(CastledConstants.kCastledAPNsTokenKey) ?? ""
        if oldToken != deviceToken{
            CastledUserDefaults.setBoolean(CastledConstants.kCastledIsTokenRegisteredKey, false)
            CastledUserDefaults.setString(CastledConstants.kCastledAPNsTokenKey, deviceToken)
        }
        if (CastledUserDefaults.getBoolean(CastledConstants.kCastledIsTokenRegisteredKey) == false)
        {
            registerDeviceTokenWith(apnsToken: deviceToken)  { (response: CastledResponse<[String : Any]>) in
                
            }
        }
        //Updating on the Appdelegate.
        Castled.sharedInstance?.delegate.castledNotificationsManager(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        
    }
    
    @objc public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
        //Updating on the Appdelegate.
        Castled.sharedInstance?.delegate.castledNotificationsManager(didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    
    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        Castled.sharedInstance?.delegate.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
        processCastledPushEvents(userInfo: notification.request.content.userInfo)
        
    }
    
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        Castled.sharedInstance?.delegate.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
        
        // Returning the same options we've requested
        let userInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier
        {
            processCastledPushEvents(userInfo: userInfo,isOpened: true)
        }
        else if response.actionIdentifier == UNNotificationDismissActionIdentifier
        {
            processCastledPushEvents(userInfo: userInfo,isDismissed: true)
            
        }
    }
    
}


extension Castled{

    func checkAppIsLaunchedViaPush(launchOptions : [UIApplication.LaunchOptionsKey: Any]?){
        let notificationOption = launchOptions?[.remoteNotification]
        if let notification = notificationOption as? [String: AnyObject],
        let _ = notification["aps"] as? [String: AnyObject] {
                
            processCastledPushEvents(userInfo: notification,isOpened: true)

        }
    }
    
   fileprivate func processCastledPushEvents(userInfo : [AnyHashable : Any], isOpened : Bool? = false, isDismissed : Bool? = false){
        Task{
            if let castledId = userInfo[CastledConstants.kCastledPushNotificationIdKey] as? String{
                var event = CastledConstants.kCastledPushStatusAcknowledgedKey
                
                if isOpened == true{
                    event = CastledConstants.kCastledPushStatusOpenedKey
                }
                else if isDismissed == true{
                    event = CastledConstants.kCastledPushStatusCancelledKey
                }
                let notifactionKey = CastledConstants.kCastledNotificationIdsKey + event
                var notificationIds = CastledUserDefaults.getString(notifactionKey) ?? ""
                let curNotiValue = "\(castledId)\(CastledConstants.kCastledIdSeperator)"
            

                if (!notificationIds.contains(curNotiValue))
                {
                    notificationIds += "\(castledId)\(CastledConstants.kCastledIdSeperator)"
                    CastledUserDefaults.setString(notifactionKey, notificationIds)

                }
                if (notificationIds.count > 0){
                    
                    registerEvents(eventType: event, notificationIds: notificationIds) { (_ response: CastledResponse<[String : String]>) in
                        
                    }

                }

            }
        }
    }
  
    func processAllDeliveredNotificatoins(shouldClear : Bool){
        
        Task{
            if #available(iOS 10.0, *) {
                
                let center = UNUserNotificationCenter.current()
                
                center.getDeliveredNotifications { [self] (receivedNotifications) in
                    
                    let notifactionKey = CastledConstants.kCastledNotificationIdsKey + CastledConstants.kCastledPushStatusAcknowledgedKey
                    var notificationIds = CastledUserDefaults.getString(notifactionKey) ?? ""
                    
                    
                    for notification in receivedNotifications {
                        
                        let content = notification.request.content
                        if let castledId = content.userInfo[CastledConstants.kCastledPushNotificationIdKey] as? String{
                            let curNotiValue = "\(castledId)\(CastledConstants.kCastledIdSeperator)"
                            if (!notificationIds.contains(curNotiValue))
                            {
                                notificationIds += "\(castledId)\(CastledConstants.kCastledIdSeperator)"

                            }
                            
                        }
                        
                    }
                    if(notificationIds.count > 0){
                        
                        CastledUserDefaults.setString(notifactionKey, notificationIds)
                        registerEvents(eventType: CastledConstants.kCastledPushStatusAcknowledgedKey, notificationIds: notificationIds) { (_ response: CastledResponse<[String : String]>) in
                            
                        }
                    }
                    
                    if shouldClear == true{
                        center.removeAllDeliveredNotifications()
                    }
                    
                }
            }
        }
    }
}
