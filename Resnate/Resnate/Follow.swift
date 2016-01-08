//
//  Follow.swift
//  Resnate
//
//  Created by Amir Moosavi on 20/11/2015.
//  Copyright © 2015 Resnate. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func followPlaylist(sender: UIBarButtonItem){
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["playlist":"\(sender.tag)", "token": "\(resnateToken)"]
        
        let URL = NSURL(string: "https://www.resnate.com/api/playlists/follow")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
            
            let unfollowButton = UIBarButtonItem(title: "Unfollow", style: .Plain, target: self, action: "unfollowPlaylist:")
            
            self.navigationItem.rightBarButtonItem = unfollowButton
            
            unfollowButton.tag = sender.tag
            
        }
        
    }
    
    func unfollowPlaylist(sender: UIBarButtonItem){
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["playlist":"\(sender.tag)", "token": "\(resnateToken)"]
        
        let URL = NSURL(string: "https://www.resnate.com/api/playlists/unfollow")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
            
            let followButton = UIBarButtonItem(title: "Follow", style: .Plain, target: self, action: "followPlaylist:")
            
            self.navigationItem.rightBarButtonItem = followButton
            
            followButton.tag = sender.tag
            
        }
        
    }
    
}