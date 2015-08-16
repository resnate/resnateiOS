//
//  Router.swift
//  LoginTabbedAppSwift
//
//  Created by Amir Moosavi on 23/05/2015.
//  Copyright (c) 2015 Medigarage Studios LTD. All rights reserved.
//

import Foundation

struct Router {
    let baseURLString = "https://www.resnate.com/api/"
    let userID: String
    let OAuthToken: String
    var method: Method = .GET
    
    init(OAuthToken: String, userID: String) {
        self.OAuthToken = OAuthToken
        self.userID = userID
        
    }
    
    
    // MARK: URLRequestConvertible
    
    func buildURLRequest(prefix: String, path: String) -> NSURLRequest {
        let URL = NSURL(string: baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(prefix + userID + path))
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.setValue("Token \(OAuthToken)", forHTTPHeaderField: "Authorization")
        return mutableURLRequest
    }
    
}