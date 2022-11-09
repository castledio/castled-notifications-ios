//
//  CastledAPIs.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
extension Castled{
    
    /**
     Funtion which alllows to register the APNs token with Castled.
     */
    func registerDeviceTokenWith<T: Any>(apnsToken token : String, completion: @escaping (_ response: CastledResponse<T>) -> Void){
        api_RegisterDeviceTokenWith(apnsToken: token) {(response: CastledResponse<T>) in
            
            guard let result = response.result as? [String : Any] else{
                return
            }
            if let anonId = result[CastledConstants.kCastledAnonymousIdResponseKey] {
                CastledUserDefaults.setString(CastledConstants.kCastledAnonymousIdKey,(anonId as! String))
                CastledUserDefaults.setBoolean(CastledConstants.kCastledIsTokenRegisteredKey, true)
            }
            
            completion(response)
        }
        
    }
    /**
     Funtion which alllows to register the User with Castled.
     */
    func registerUser<T: Any>(userId uid : String, apnsToken token : String? = CastledUserDefaults.getString(CastledConstants.kCastledAPNsTokenKey) ?? "",  completion: @escaping (_ response: CastledResponse<T>) -> Void){
        api_RegisterUser(userId: uid, apnsToken: token!) { (response: CastledResponse<T>) in
            if ( CastledUserDefaults.getString(CastledConstants.kCastledAPNsTokenKey) == nil){
                CastledUserDefaults.setString(CastledConstants.kCastledAPNsTokenKey, token)
            }
            if response.success{
                CastledUserDefaults.setBoolean(CastledConstants.kCastledIsTokenRegisteredKey, true)
                CastledUserDefaults.setString(CastledConstants.kCastledUserIdKey, uid)
            }
            
            
            completion(response)
        }
        
        
    }
    
    /**
     Funtion which alllows to register Notifification events like OPENED,ACKNOWLEDGED etc.. with Castled.
     */
    func registerEvents<T: Any>(eventType et : String, notificationIds notIds : String,  completion: @escaping (_ response: CastledResponse<T>) -> Void){
        
        api_RegisterEvents(eventType: et, notificationIds: notIds) { (response: CastledResponse<T>) in
            
            
            if response.success{
                let notifactionKey = CastledConstants.kCastledNotificationIdsKey + et
                var notificationIds = CastledUserDefaults.getString(notifactionKey) ?? ""
                if (notificationIds.contains(notIds)){
                    notificationIds =  notificationIds.replacingOccurrences(of: notIds, with: "")
                    CastledUserDefaults.setString(notifactionKey, notificationIds)
                }
                
            }
            completion(response)
        }
        
        
    }
}


extension Castled{
    
    fileprivate func api_RegisterDeviceTokenWith<T: Any>(apnsToken token : String, completion: @escaping (_ response: CastledResponse<T>) -> Void){
        
        
        Task{
            guard let instance_id = Castled.sharedInstance?.instanceId else{
                print("Register APNs token Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
                completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
                return
            }
            
            var request : CastledNetworkRouter
            request = .registerDeviceToken(apnsToken: token, instanceId: instance_id)
            let response = await  CastledNetworkLayer.shared.sendRequest(model: [String : Any].self, requestType: request)
            
            switch response {
            case .success(let responsJSON):
                print("Register APNs token Success:✅✅✅ \(responsJSON)")
                completion(CastledResponse(response: responsJSON as! T))
            case .failure(let error):
                print("Register APNs token Error:❌❌❌\(error.localizedDescription)")
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
                
            }
            
        }
        
        
    }
    
    fileprivate func api_RegisterUser<T: Any>(userId uid : String, apnsToken token : String,  completion: @escaping (_ response: CastledResponse<T>) -> Void){
        
        
        Task{
            
            guard let instance_id = Castled.sharedInstance?.instanceId else{
                print("Register User Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
                completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
                return
            }
            if token.count == 0 {
                print("Register User Error:❌❌❌\(CastledExceptionMessages.emptyToken.rawValue)")

                completion(CastledResponse(error: CastledExceptionMessages.emptyToken.rawValue, statusCode: 999))
                return
                
            }
            var request : CastledNetworkRouter
            request = .registerUser(userId: uid, apnsToken: token, instanceId: instance_id)
            
            let response = await  CastledNetworkLayer.shared.sendRequest(model: String.self, requestType: request)
            
            switch response {
            case .success(let responsJSON):
                print("Register User Success:✅✅✅ \(responsJSON)")
                completion(CastledResponse(response: responsJSON as! T))
            case .failure(let error):
                print("Register User Error:❌❌❌\(error.localizedDescription)")
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
                
            }
            
        }
        
        
    }
    
    fileprivate func api_RegisterEvents<T: Any>(eventType et : String, notificationIds notIds : String,  completion: @escaping (_ response: CastledResponse<T>) -> Void){
        
        
        Task{
            
            guard let instance_id = Castled.sharedInstance?.instanceId else{
                print("Register Events Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
                completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
                return
            }
            guard let userId = CastledUserDefaults.getString(CastledConstants.kCastledUserIdKey) else{
                print("Register Events Error:❌❌❌\(CastledExceptionMessages.userNotRegistered.rawValue)")
                completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
                return
            }
            
            var request : CastledNetworkRouter
            var notiAr =  notIds.components(separatedBy: CastledConstants.kCastledIdSeperator)
            notiAr = notiAr.filter({ $0 != ""})
            request = .registerEvents(userId: userId, notificationIds: notiAr, eventType: et, appInBg: false, createdTs: "\(Int(Date().timeIntervalSince1970))", instanceId: instance_id)
            
            let response = await  CastledNetworkLayer.shared.sendRequest(model: String.self, requestType: request)
            
            switch response {
            case .success(let responsJSON):
                print("Register Events Success:✅✅✅ \(responsJSON)")
                completion(CastledResponse(response: responsJSON as! T))
            case .failure(let error):
                print("Register Events Error:❌❌❌ \(error.localizedDescription)")
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
                
            }
            
        }
        
        
    }
}

