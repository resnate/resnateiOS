//
//  Share.swift
//  Resnate
//
//  Created by Amir Moosavi on 14/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import Foundation
import UIKit
import FBSDKShareKit
import TwitterKit

struct User: Equatable {
    var name: String
    var id: Int
    var uid: String
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name
}

extension UIViewController {

    func share(type: String, shareID: String) {
    
        
        var friends: [User] = []
    
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
    
        let resnateToken = dictionary!["token"] as! String
    
        let resnateID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
    
    request(req.buildURLRequest("search/", path: "")).responseJSON { (_, _, json, error) in
        if json != nil {
            
            var users = JSON(json!)
            
            for (index, user) in users {
                var name = user["name"].string!
                var id = user["id"].int!
                var uid = user["uid"].string!
                var friend = User(name: name, id: id, uid: uid)
                if friend.id != resnateID.toInt() {
                    friends.append(friend)
                }
                
            }
            

        }
        
        let shareViewController:ShareViewController = ShareViewController(nibName: "ShareViewController", bundle: nil)
        
        
        shareViewController.type = type
        
        shareViewController.shareID = shareID
        
        shareViewController.users = friends
        
        self.navigationController?.pushViewController(shareViewController, animated: true)
    }
    
    
}
    
    func closeShare(sender: AnyObject) {
        sender.view!.superview!.superview!.removeFromSuperview()
    
    }
    
    func shareGigReview(sender: AnyObject){
        
        share("Review", shareID: String(sender.tag!))
        
        
    }
    
    
    
    
    
    
    
    func fbReview(sender: AnyObject){
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "www.resnate.com/reviews/\(sender.view!.tag)/pl")
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
    }
    
    


    func twitter(sender: AnyObject){
        let composer = TWTRComposer()
        let url = "I've written a review on @resnate! https://www.resnate.com/reviews/\(sender.view!.tag)/pl"
        composer.setText(url)
        composer.setImage(UIImage(named: "fabric"))
        
        composer.showWithCompletion { (result) -> Void in
            if (result == TWTRComposerResult.Cancelled) {
                println("Tweet composition cancelled")
            }
            else {
                println("Sending tweet!")
            }
        }
    }

    func checkIfSharing(UIView: VideoPlayer) {
        
        let ytPlayer = VideoPlayer.sharedInstance
        
        if ytPlayer.videoPlayer.tag == -1 {
            
            ytPlayer.hideControls()
            
            share("Song", shareID: ytPlayer.shareID)
            
        } else {
            println("no")
        }
        
        
    }

}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}
