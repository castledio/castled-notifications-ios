//
//  CastledSwizzler.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//
//Reference https://medium.com/rocknnull/ios-to-swizzle-or-not-to-swizzle-f8b0ed4a1ce6

import Foundation
import UIKit


class CastledSwizzler {
   
    class func enableSwizzlingForNotifications(in appDelegate: UIApplicationDelegate) {

        // Checking if swizzling has been disabled in plist by the developer
        let swizzzlingDisabled = Bundle.main.object(forInfoDictionaryKey: CastledConstants.kCastledSwzzlingDisableKey) as? Bool ?? false
        if swizzzlingDisabled == true {
            return
        }
        self.swizzleImplementations(type(of: appDelegate), "application:didRegisterForRemoteNotificationsWithDeviceToken:")
        self.swizzleImplementations(type(of: appDelegate), "application:didFailToRegisterForRemoteNotificationsWithError:")

    }
 
    private class func swizzleImplementations(_ className: AnyObject.Type, _ methodSelector: String) {
     

        
        // Name of the method
        // We are not changing the method name
        let selector = Selector(methodSelector)
        
        // Origninal method
        let defaultMethod = class_getInstanceMethod(className, selector)
        
        // New run time method to swap with
        let swizzleMethod = class_getInstanceMethod(Castled.self, selector)
        
        //Adding a method to the class at runtime and returns a boolean if the “add procedure” was successful
        let isMethodExists = class_addMethod(className, selector, method_getImplementation(swizzleMethod!), method_getTypeEncoding(swizzleMethod!))
        
        
        if !isMethodExists {
            // Swap the implementation of our defaultMethod with the swizzledMethod
            method_exchangeImplementations(defaultMethod!, swizzleMethod!)
        }
        else {
            // Method already defined
         //   class_replaceMethod(className, selector, method_getImplementation(defaultMethod!), method_getTypeEncoding(defaultMethod!));
         }
    }
}
