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
    public static let kCastledPushStatusAcknowledgedKey   = "ACKNOWLEDGED"
    public static let kCastledPushStatusCancelledKey      = "CANCELLED"
    public static let kCastledPushStatusOpenedKey         = "OPENED"


}
