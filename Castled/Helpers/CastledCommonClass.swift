//
//  CastledCommonClass.swift
//  Castled
//
//  Created by Faisal Azeez on 01/12/2022.
//
import UIKit

import Foundation

class CastledCommonClass{
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    static func getActionLabelFromDictionary(dict: [AnyHashable : Any], actionType: String) -> String? {
        guard let customDict = dict[CastledConstants.kCastledPushMainCustomKey] as? NSDictionary else {
            return nil
        }
        
        guard let _ = customDict[CastledConstants.kCastledPushNotificationIdKey] as? String else {
            return nil
        }

        guard let notification = dict["aps"] as? NSDictionary else{
            return nil
        }
        
        guard let _ = notification[CastledConstants.kCastledPushNotificationCategoryKey] as? String else {
            return nil
        }
        
        guard let categoryJsonString = customDict[CastledConstants.kCastledPushNotificationCategoryActionsKey] as? String else {
            return nil
        }
        
        if let deserializedDict = CastledCommonClass.convertToDictionary(text: categoryJsonString) {
            if let actionsArray = deserializedDict[CastledConstants.kCastledPushNotificationActionComponents] as? NSArray {
                for actionDic in actionsArray {
                    if let dict = actionDic as? NSDictionary, let identifier = dict["clickAction"] as? String, let title = dict["actionId"] as? String{
                        if(identifier == actionType) {
                            return title
                        }
                    }
                }
                
            }
        }
        return nil
    }
}

