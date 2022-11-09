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
    static var kCastledAPNsTokenKey                = "_castledApnsToken_"
    static var kCastledIsTokenRegisteredKey        = "_castledIsTokenRegistered_"
    static var kCastledAnonymousIdKey              = "_castledAnonymousId_"
    static var kCastledUserIdKey                   = "_castledUserId_"
    static var kCastledNotificationIdsKey          = "_castledNotificationIds_"
    static let kCastledIdSeperator                 = "||"

    
    //Constants used in the api
    static var kCastledAnonymousIdResponseKey      = "anonId"
    static let kCastledPushNotificationIdKey       = "castled_notification_id"
    static let kCastledPushStatusAcknowledgedKey   = "ACKNOWLEDGED"
    static let kCastledPushStatusCancelledKey      = "CANCELLED"
    static let kCastledPushStatusOpenedKey         = "OPENED"


}
