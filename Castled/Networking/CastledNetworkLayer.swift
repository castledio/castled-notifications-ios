//
//  CastledNetworkLayer.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//
//Reference : https://medium.com/nerd-for-tech/using-url-sessions-with-swift-5-5-aysnc-await-codable-8935fe55fbfc

import Foundation

@objc class CastledNetworkLayer : NSObject {
  
    let retryLimit = 5
    static var shared = CastledNetworkLayer()
    private var request: URLRequest?
    private override init () {}
    
    private func createGetRequestWithURLComponents(url:URL,parameters: [String:Any],requestType: CastledNetworkRouter) -> URLRequest? {
        var components = URLComponents(string: url.absoluteString)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: "\(value)")
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        request = URLRequest(url: components.url ?? url)
        request?.httpMethod = requestType.method
        return request
    }
    private func createPostRequestWithBody(url:URL, parameters: [String:Any], requestType: CastledNetworkRouter) -> URLRequest? {
        request = URLRequest(url: url)
        request?.httpMethod = requestType.method
        request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.addValue("application/json", forHTTPHeaderField: "Accept")
        if let requestBody = getParameterBody(with: parameters) {
            request?.httpBody = requestBody
        }
        request?.httpMethod = requestType.method
        return request
    }
    private func getParameterBody(with parameters: [String:Any]) -> Data? {
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            return nil
        }
        return httpBody
    }
    private func createRequest(with url: URL, requestType: CastledNetworkRouter, parameters: [String: Any]) -> URLRequest? {
        
        if requestType.method == CastledNetworkRouter.post {
            
            return createPostRequestWithBody(url: url,
                                             parameters: parameters,
                                             requestType: requestType)
        }
        else {
            return createGetRequestWithURLComponents(url: url,
                                                     parameters: parameters,
                                                     requestType: requestType)
            
        }
    }
    
    func sendRequest<T:Any>(model: T.Type,requestType: CastledNetworkRouter,retryAttempt: Int? = 0) async -> Result<[String:Any], Error> {
        if #available(iOS 13.0, *) {
            do {
                
                let url = URL(string: requestType.baseURL+requestType.path)!
                //                print(url)
                guard let urlRequest = createRequest(with: url,
                                                     requestType: requestType,parameters: requestType.parameters) else {
                    return .failure(CastledException.Error(CastledExceptionMessages.paramsMisMatch.rawValue))
                }
                let (data, response) = try await URLSession.shared.data(for: urlRequest)
                do {
                    switch requestType {
                    case .registerUser,.registerEvents:
                        if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                            
                            return .success(["success":"1"])
                        }
                    default:
                        break
                    }
                    
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                            return .success(json)
                        }
                        else
                        {
                            if let error_message = json["message"]{
                                
                                let err =  CastledException.Error(error_message as! String)
                                return .failure(err)
                            }
                            else{
                                let err =  CastledException.Error(CastledExceptionMessages.common.rawValue)
                                return .failure(err)
                            }
                        }
                        
                        
                    }
                } catch let error as NSError {
                    return .failure(error)
                    
                }
            }
            catch {

                if retryAttempt! < retryLimit{
                    return await  CastledNetworkLayer.shared.sendRequest(model: model, requestType: requestType,retryAttempt: retryAttempt!+1)

                }
                
               // return .failure(error)

                return .failure(CastledException.Error(CastledExceptionMessages.common.rawValue))
            }
        }
        return .failure(CastledException.Error(CastledExceptionMessages.iOS13Less.rawValue))
        
    }
}

