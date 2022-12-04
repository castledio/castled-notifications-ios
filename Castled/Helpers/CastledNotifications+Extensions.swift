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
            Castled.registerDeviceTokenWith(apnsToken: deviceToken)  { (response: CastledResponse<[String : Any]>) in
                
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
        processCastledPushEvents(userInfo: notification.request.content.userInfo, isForeGround: true)
        
        Castled.sharedInstance?.registerNotificationCategories(userInfo: notification.request.content.userInfo)
        print("\(notification.request.content.userInfo)")
    }
    
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        Castled.sharedInstance?.delegate.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
        
        // Returning the same options we've requested
        let userInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier{
            processCastledPushEvents(userInfo: userInfo,isOpened: true)
        }
        else if response.actionIdentifier == UNNotificationDismissActionIdentifier{
            processCastledPushEvents(userInfo: userInfo,isDismissed: true)
        }else if response.actionIdentifier == CastledConstants.kCastledPushActionTypeDeeplink {
            if let actionTitle = CastledCommonClass.getActionLabelFromDictionary(dict: userInfo, actionType: CastledConstants.kCastledPushActionTypeDeeplink) {
                processCastledPushEvents(userInfo: userInfo,isAcceptRich: true, actionLabel: actionTitle, actionType: CastledConstants.kCastledPushActionTypeDeeplink)
                handleNavigateScreenPayload(type: CastledConstants.kCastledPushActionTypeDeeplink, userInfo: userInfo)
            }
        } else if response.actionIdentifier == CastledConstants.kCastledPushActionTypeDiscardNotifications {
            
            if let actionTitle = CastledCommonClass.getActionLabelFromDictionary(dict: userInfo, actionType: CastledConstants.kCastledPushActionTypeDiscardNotifications) {
                processCastledPushEvents(userInfo: userInfo,isDiscardedRich: true, actionLabel: actionTitle, actionType: CastledConstants.kCastledPushActionTypeDiscardNotifications)
            }
        } else if response.actionIdentifier == CastledConstants.kCastledPushActionTypeNavigate {
            if let actionTitle = CastledCommonClass.getActionLabelFromDictionary(dict: userInfo, actionType: CastledConstants.kCastledPushActionTypeNavigate) {
                processCastledPushEvents(userInfo: userInfo,isAcceptRich: true, actionLabel: actionTitle, actionType: CastledConstants.kCastledPushActionTypeNavigate)
                handleNavigateScreenPayload(type: CastledConstants.kCastledPushActionTypeNavigate, userInfo: userInfo)
            }
        } else if response.actionIdentifier == CastledConstants.kCastledPushActionTypeRichLanding {
            if let actionTitle = CastledCommonClass.getActionLabelFromDictionary(dict: userInfo, actionType: CastledConstants.kCastledPushActionTypeRichLanding) {
                processCastledPushEvents(userInfo: userInfo,isAcceptRich: true, actionLabel: actionTitle, actionType: CastledConstants.kCastledPushActionTypeRichLanding)
            }
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
    
    fileprivate func processCastledPushEvents(userInfo : [AnyHashable : Any],isForeGround: Bool? = false , isOpened : Bool? = false, isDismissed : Bool? = false, isDiscardedRich: Bool? = false, isAcceptRich: Bool? = false, actionLabel: String? = "", actionType: String? = "", completion: ((_ success: Bool) -> Void)? = nil ){
        Task{
            if let customCasledDict = userInfo[CastledConstants.kCastledPushMainCustomKey] as? NSDictionary{
                    if let castledId = customCasledDict[CastledConstants.kCastledPushNotificationIdKey] as? String{
                            var event = CastledConstants.kCastledPushStatusReceivedKey
                            
                            if isOpened == true{
                                event = CastledConstants.kCastledPushStatusClickedKey
                            }
                            else if isDismissed == true{
                                event = CastledConstants.kCastledPushStatusDiscardedKey
                            }
                            
                            if isDiscardedRich == true{
                                event = CastledConstants.kCastledPushStatusDiscardedKey
                            }
                            else if isAcceptRich == true{
                                event = CastledConstants.kCastledPushStatusClickedKey
                            }
                            
                            if isForeGround == true {
                                event = CastledConstants.kCastledPushStatusForegroundKey
                            }
                            
                            let notifactionKey = CastledConstants.kCastledNotificationIdsKey + event
                            var notificationIds = CastledUserDefaults.getString(notifactionKey) ?? ""
                            let curNotiValue = "\(CastledConstants.kCastledIdSeperator)\(castledId)\(CastledConstants.kCastledIdSeperator)"
                            

                            if (!notificationIds.contains(curNotiValue))
                            {
                                notificationIds += curNotiValue
                                CastledUserDefaults.setString(notifactionKey, notificationIds)

                            }
                            if (notificationIds.count > 0){
                                var notiAr =  notificationIds.components(separatedBy: CastledConstants.kCastledIdSeperator)
                                notiAr = notiAr.filter({ $0 != ""})

                                Castled.registerEvents(eventType: event, actionLabel: actionLabel ?? "", actionType: actionType ?? "",notificationIds: notiAr) { (_ response: CastledResponse<[String : String]>) in
                                    if let completionT = completion {
                                        completionT(true)
                                    }
                                }

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
                    
                    let notifactionKey = CastledConstants.kCastledNotificationIdsKey + CastledConstants.kCastledPushStatusReceivedKey
                    var notificationIds = CastledUserDefaults.getString(notifactionKey) ?? ""
                    
                    
                    for notification in receivedNotifications {
                        
                        let content = notification.request.content
                        
                        if let customCasledKey = content.userInfo[CastledConstants.kCastledPushMainCustomKey] as? String{
                            if let customDict = content.userInfo[customCasledKey] as? NSDictionary {
                                if let castledId = customDict[CastledConstants.kCastledPushNotificationIdKey] as? String{
                                    let curNotiValue = "\(CastledConstants.kCastledIdSeperator)\(castledId)\(CastledConstants.kCastledIdSeperator)"
                                    if (!notificationIds.contains(curNotiValue))
                                    {
                                        notificationIds += curNotiValue
                                    }
                                }
                            }
                        }
                        
                        
                    }
                    if(notificationIds.count > 0){
                        
                        CastledUserDefaults.setString(notifactionKey, notificationIds)
                        var notiAr =  notificationIds.components(separatedBy: CastledConstants.kCastledIdSeperator)
                        notiAr = notiAr.filter({ $0 != ""})

                        Castled.registerEvents(eventType: CastledConstants.kCastledPushStatusReceivedKey, notificationIds: notiAr) { (_ response: CastledResponse<[String : String]>) in
                            
                        }
                    }
                    
                    if shouldClear == true{
                        center.removeAllDeliveredNotifications()
                    }
                    
                }
            }
        }
    }
    
    
    func handleNavigateScreenPayload(type:String, userInfo: [AnyHashable : Any]) {
        if type == CastledConstants.kCastledPushActionTypeDeeplink {
            if let customDict = userInfo[CastledConstants.kCastledPushMainCustomKey] as? NSDictionary {
                if let categoryJsonString = customDict[CastledConstants.kCastledPushNotificationCategoryActionsKey] as? String {
                    
                    if let deserializedDict = CastledCommonClass.convertToDictionary(text: categoryJsonString) {
                        if let urlForNavigation = deserializedDict[CastledConstants.kCastledPushNotificationURLForNavigation] as? String {
                            Castled.sharedInstance?.delegate.navigateToScreen(scheme: urlForNavigation, viewControllerName: nil)
                        }
                    }
                    
                }
            }
        } else {
            if let customDict = userInfo[CastledConstants.kCastledPushMainCustomKey] as? NSDictionary {
                if let categoryJsonString = customDict[CastledConstants.kCastledPushNotificationCategoryActionsKey] as? String {
                    
                    if let deserializedDict = CastledCommonClass.convertToDictionary(text: categoryJsonString) {
                        if let viewControllerName = deserializedDict[CastledConstants.kCastledPushNotificationURLForNavigation] as? String {
                            Castled.sharedInstance?.delegate.navigateToScreen(scheme: nil, viewControllerName: viewControllerName)
                        }
                    }
                    
                }
            }
        }

    }
}
