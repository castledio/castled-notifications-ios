//
//  CastledConstants.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

public class CastledConstants {
   
    //Plist Key for enable/ Disable swizzling
    static let kCastledSwzzlingDisableKey          = "CastledSwizzlingDisabled"
   
    //Userdefault keys
    static var kCastledIsTokenRegisteredKey        = "_castledIsTokenRegistered_"
    static var kCastledAnonymousIdKey              = "_castledAnonymousId_"
    static var kCastledUserIdKey                   = "_castledUserId_"
    static var kCastledNotificationIdsKey          = "_castledNotificationIds_"
    public static let kCastledIdSeperator                 = "||"
    public static let kCastledAPNsTokenKey                = "_castledApnsToken_"

    
    //Constants used in the api
    static let kCastledAnonymousIdResponseKey      = "anonId"
    static let kCastledPushNotificationIdKey       = "castled_notification_id"
    static let kCastledPushMainCustomKey       = "castled"
    static let kCastledPushMediaUrl = "media_url"

    static let kCastledPushNotificationCategoryKey = "category"
    static let kCastledPushNotificationCategoryActionsKey = "category_actions"
    static let kCastledPushNotificationActionComponents = "actionComponents"
    static let kCastledPushNotificationURLForNavigation = "url"
    
    
    /* old event types
    public static let kCastledPushStatusAcknowledgedKey   = "ACKNOWLEDGED"
    public static let kCastledPushStatusCancelledKey      = "CANCELLED"
    public static let kCastledPushStatusOpenedKey         = "OPENED"
    */
    
    public static let kCastledPushStatusSendKey         = "SEND"
    public static let kCastledPushStatusClickedKey         = "CLICKED"
    public static let kCastledPushStatusDiscardedKey         = "DISCARDED"
    public static let kCastledPushStatusReceivedKey         = "RECEIVED"
    public static let kCastledPushStatusForegroundKey         = "FOREGROUND"

    public static let kCastledPushButtonAcceptIdentifier        = "Accept"
    public static let kCastledPushButtonDiscardIdentifier        = "Discard"

    public static let kCastledPushActionlabelKey        = "actionLabel"
    public static let kCastledPushActionType       = "actionType"
    
    public static let kCastledPushActionTypeNavigate       = "NAVIGATE_TO_SCREEN"
    public static let kCastledPushActionTypeDeeplink       = "DEEP_LINKING"
    public static let kCastledPushActionTypeDiscardNotifications      = "DISMISS_NOTIFICATION"
    public static let kCastledPushActionTypeRichLanding      = "RICH_LANDING"
    
    //NAVIGATE_TO_SCREEN, DEEPLINKING, RICH_LANDING
   // DISMISS_NOTIFICATION
    
    /* Event Types:
        SEND
        CLICKED
        DISCARDED
        RECEIVED
        FOREGROUND
    */

}
