//
//  AppDelegate.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import UIKit
import Castled

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Castled.configure(registerIn: application, launchOptions: launchOptions, instanceId: "test-1", delegate: self)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
  
    /*************************************************************IMPPORTANT*************************************************************/
    //If you disabled the swizzling in plist you should register the token with Castled like below example
    public  func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs token \(deviceToken)")
       
        Castled.registerDeviceTokenWith(apnsToken: deviceToken)  { (response: CastledResponse<[String : Any]>) in
            if (response.success){
                print("Register Device token Success \(String(describing: response.result))")
            }
            else
            {
                print("Register Device token Error \(response.errorMessage)")
            }
            
        }
        
    }
    
    func topController() -> UIViewController  {
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), var topController = keyWindow.rootViewController {
            while let presentedViewController = topController.presentedViewController {

                topController = presentedViewController
            }
            return topController
        }
        return (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController)!
    }
}


// MARK: - CastledNotification Delegate Methods
extension AppDelegate: CastledNotificationDelegate {
    func navigateToScreen(scheme: String?, viewControllerName: String?) {
        print("navigate to screens")
        if let urlScheme = scheme {
            print(urlScheme)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "DeeplinkViewController") as? DeeplinkViewController {
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.topController().present(nav, animated: true) {
                    vc.lblEventType.text = "Deeplink Event"
                }
            }
            return
        }
        
        if let viewController = viewControllerName {
            print(viewController)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "DeeplinkViewController") as? DeeplinkViewController {
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.topController().present(nav, animated: true) {
                    vc.lblEventType.text = "Navigation to screen Event"
                }
            }
            return
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //Handle the click events
        completionHandler()
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler( [.alert, .badge, .sound])
    }
    
    public  func castledNotificationsManager(didRegisterForRemoteNotificationsWithDeviceToken token: String) {
        print("CastledNotificationDelegate didRegisterForRemoteNotificationsWithDeviceToken \(token)")
    }
    
    func castledNotificationsManager(didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("CastledNotificationDelegate didFailToRegisterForRemoteNotificationsWithError\(error)")
        
    }
    
}
