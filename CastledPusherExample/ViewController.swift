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

        // Do any additional setup after loading the view.
    }
    
    //Function for registering the user with Castled
    func registerUserAPI() {
            let apnsToken = "your apns token"
            let userId    = "UserId"//user-101
            Castled.sharedInstance?.registerUser(userId: userId,apnsToken: apnsToken, completion: { (_ response: CastledResponse<[String : String]>) in
                
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
    
}

