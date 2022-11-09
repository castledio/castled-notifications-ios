//
//  CastledNetworkRouter.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

enum CastledNetworkRouter {
    
    case registerDeviceToken(apnsToken : String, instanceId : String)
    case registerUser(userId : String, apnsToken : String,anonimousId : String? = CastledUserDefaults.getString(CastledConstants.kCastledAnonymousIdKey) ?? "", instanceId : String)
    case registerEvents(userId : String, notificationIds : [String],eventType : String, appInBg : Bool,createdTs : String, instanceId : String)
    case removeDeviceToken
    
    public static let post = "POST"
    
    var baseURL: String {
        return "https://test.castled.io/"
    }
    
    
    var path: String {
        switch self {
        case .registerDeviceToken(_, let instanceId):
            return "backend/v1/push/\(instanceId)/apns/register"
        case .registerUser(_,_,_, let instanceId):
            return "backend/v1/push/\(instanceId)/apns/user"
        case .registerEvents(_,_,_,_,_, let instanceId):
            return "backend/v1/push/\(instanceId)/event"
        
        default:
            return ""
        }
        
    }
    
    var method: String {
        
        return CastledNetworkRouter.post
        
    }
    
    var parameters: [String: Any] {
        switch self {
        case .registerDeviceToken(let apnsToken, _):
            return ["apnsToken" : apnsToken]
        case .registerUser(let userID,let apnsToken,let anonimousId, _):
            return ["userId" : userID,"anonId" : anonimousId ?? "","apnsToken" : apnsToken]
      
        case .registerEvents(let userID,let notificationIds,let eventType, let appInBg,let createdTs,_):
            return ["userId" : userID,"notificationIds" : notificationIds,"eventType" : eventType,"appInBg" : appInBg,"createdTs":createdTs]
       
        default:
            return [:]
        }
    }
    
    
}

