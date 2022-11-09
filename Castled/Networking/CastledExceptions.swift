//
//  CastledExceptions.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

enum CastledExceptionMessages: String {
    case common             = "We are not able to perform this request.Please check your internet connection and try again."
    case notInitialised     = "Kindly configure with proper instance_id in the Appdelegate."
    case emptyToken         = "Kindly allow the permission for push notification from the settings Or pass a valid APNs token in the api call."
    case iOS13Less          = "Sorry for the inconvenience. Currently we are supporting iOS 13 and above."
    case paramsMisMatch     = "Unable to create the request. Please check the params or url."
    case userNotRegistered  = "Please register the user with Castled using the api 'registerUser:'."
    
}

enum CastledException: Error {
    case Error(String)
}
extension CastledException: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .Error(let description):
            return description
            
        }
    }
    
}
func getError(from message : String) -> NSError{
    return NSError(domain: "com.castled.error", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    
}

