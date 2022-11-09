//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
public class CastledUserDefaults {
    

    
    
    class func getString(_ key: String, userDefaultsOnly: Bool = false) -> String? {
        
        // Fetch value from UserDefaults
        if let stringValue = UserDefaults.standard.string(forKey: key){
            return stringValue
        }
        return nil
        
    }
    
    class func setString(_ key: String, _ value: String?) {
        // Save the value in UserDefaults
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getBoolean(_ key: String) -> Bool {
        
        // Fetch Bool value from UserDefaults
        return UserDefaults.standard.bool(forKey: key)
    }
    
    class func setBoolean(_ key: String, _ value: Bool?) {
        // Store value in UserDefaults
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        
    }
    class func removeFor(_ key: String){
        
        // Remove value from UserDefaults
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
        
    }
}
