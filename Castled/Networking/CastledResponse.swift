//
//  CastledResponse.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

class CastledResponse<T: Any>: NSObject {
    
    var success   : Bool
    let statusCode  : Int
    var errorMessage     : String
    var result      : T? = nil
    
    init(error: String, statusCode: Int) {
        self.success = false
        self.errorMessage = error
        self.statusCode = statusCode
        self.result = nil
    }
    
    init(response: T) {
        self.success = true
        self.errorMessage = ""
        self.statusCode = 200
        self.result = response
        
        
    }
    
    
}

