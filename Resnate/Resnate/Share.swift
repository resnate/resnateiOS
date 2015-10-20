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
    
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
    
        let resnateToken = dictionary!["token"] as! String
    
        let resnateID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
    
    request(req.buildURLRequest("search/", path: "")).responseJSON { response in
        let json = JSON(response.result.value!)
            
            let users = json.array
            
            for user in users! {
                let name = user["name"].string!
                let id = user["id"].int!
                let uid = user["uid"].string!
                let friend = User(name: name, id: id, uid: uid)
                if friend.id != Int(resnateID) {
                    friends.append(friend)
                }
                
            }
            

        
        
        let shareViewController:ShareViewController = ShareViewController(nibName: "ShareViewController", bundle: nil)
        
        
        shareViewController.type = type
        
        shareViewController.shareID = shareID
        
        shareViewController.users = friends
        
        self.presentViewController(shareViewController, animated: true, completion: nil)
        
        
        
        
    }
    
    
}
    
    func closeShare(sender: AnyObject) {
        sender.view!!.superview!.superview!.removeFromSuperview()
    
    }
    
    func shareReview(sender: AnyObject){
        
        share("Review", shareID: String(sender.view!!.tag))
        
        
    }
    
    
    func shareGig(sender: AnyObject){
        share("Gig", shareID: String(sender.view!!.tag))
    }
    
    
    
    
    func fbReview(sender: AnyObject){
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "www.resnate.com/reviews/\(sender.view!!.tag)/pl")
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
    }
    
    


    func twitter(sender: AnyObject){
        let composer = TWTRComposer()
        let url = "I've written a review on @resnate! https://www.resnate.com/reviews/\(sender.view!!.tag)/pl"
        composer.setText(url)
        composer.setImage(UIImage(named: "fabric"))
        
        composer.showWithCompletion { (result) -> Void in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
            }
            else {
                print("Sending tweet!")
            }
        }
    }

    func checkIfSharing(UIView: VideoPlayer) {
        
        let ytPlayer = VideoPlayer.sharedInstance
            
        ytPlayer.hideControls()
            
        share("Song", shareID: ytPlayer.shareID)
            
        
    }

}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}
