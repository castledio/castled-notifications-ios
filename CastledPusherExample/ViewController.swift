//
//  ViewController.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import UIKit
import Castled

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerUserAPI()
        // Do any additional setup after loading the view.
    }
    
    //Function for registering the user with Castled
    func registerUserAPI() {
//        let token = CastledUserDefaults.getString(CastledConstants.kCastledAPNsTokenKey) ?? ""
        let userId    = "faisal-ios@castled.io"//user-101
        
        Castled.registerUser(userId: userId, completion: { (_ response: CastledResponse<[String : String]>) in
            
            if response.success {
                print(response.result as Any)
                
            }
            else
            {
                print("Error is \(response.errorMessage)")
            }
            
        })
        
    }
    
   func registerEvents(){
        
    }
    
    func triggerCampaign() {
        Castled.triggerCampaign(completion: { (_ response: CastledResponse<[String : String]>) in
            if response.success {
                print(response.result as Any)
            }
            else
            {
                print("Error is \(response.errorMessage)")
            }
        })
    }
    
}

