//
//  CastledNetworkRouter.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

enum CastledNetworkRouter {
    
    case registerDeviceToken(apnsToken : String, instanceId : String)
    
    case registerUser(userId : String, apnsToken : String, instanceId : String)

    case registerEvents(userId : String, notificationIds : [String],eventType : String, appInBg : Bool,createdTs : String, instanceId : String, actionLabel: String, actionType: String)
    case triggerCampaign

    case removeDeviceToken
    
    public static let post = "POST"
    public static let put = "PUT"

    var baseURL: String {
        return "https://test.castled.io/"
    }
    
    //TODO: Update the instance id
    var path: String {
        switch self {
        case .registerDeviceToken(_, let instanceId):
            return "backend/v1/push/\(instanceId)/apns/register"
        case .registerUser(_,_, let instanceId):
            return "backend/v1/push/\(instanceId)/apns/user"
        case .registerEvents(_,_,_,_,_, let instanceId,_,_):
            return "backend/v1/push/\(instanceId)/event"
        case .triggerCampaign:
            return "backend/v1/campaigns/119/trigger-run"
        default:
            return ""
        }
    }
    
    var method: String {
        switch self {
        case .registerDeviceToken(_,_):
            return CastledNetworkRouter.post
        case .registerUser(_,_,_):
            return CastledNetworkRouter.post
        case .registerEvents(_,_,_,_,_,_,_,_):
            return CastledNetworkRouter.post
        case .triggerCampaign:
            return CastledNetworkRouter.put
        default:
            return ""
        }
        
    }
    
    var parameters: [String: Any] {
        switch self {
        case .registerDeviceToken(let apnsToken, _):
            return ["apnsToken" : apnsToken]
            
        case .registerUser(let userID,let apnsToken, _):
            return ["userId" : userID,"apnsToken" : apnsToken]
      
        case .registerEvents(let userID,let notificationIds,let eventType, let appInBg,let createdTs,_,let actionLbl, let actionType):
            if(actionLbl == "" || actionType == "") {
                return ["userId" : userID,"notificationIds" : notificationIds,"eventType" : eventType,"appInBg" : appInBg,"createdTs":createdTs]
            } else {
                return ["userId" : userID,"notificationIds" : notificationIds,"eventType" : eventType,"appInBg" : appInBg,"createdTs":createdTs,"actionLabel":actionLbl,"actionType":actionType]
            }
        case .triggerCampaign:
            return [:]
        default:
            return [:]
        }
    }
    
    
}

