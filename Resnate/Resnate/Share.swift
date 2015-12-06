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
import ReachabilitySwift

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
        
            if let re = response.result.value {
            
                let json = JSON(re)
            
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
    }
    
    func addToPlaylist(song: [String: String]) {
        
        let addPlaylistViewController = AddPlaylistViewController(nibName: "AddPlaylistViewController", bundle: nil)
        
        addPlaylistViewController.song = song
        
        self.presentViewController(addPlaylistViewController, animated: true, completion: nil)
        
    }
    
    
    func closeShare(sender: AnyObject) {
        sender.view!.superview!.superview!.removeFromSuperview()
    
    }
    
    func shareSingleSong(sender: AnyObject) {
        
        let songID = sender.view!.tag
            
        share("Song", shareID: "\(songID)")
        
    }
    
    func shareReview(sender: AnyObject){
        
        share("Review", shareID: String(sender.view!.tag))
        
    }
    
    func sharePlaylist(sender: AnyObject){
        
        share("Playlist", shareID: String(sender.tag))
        print(sender.view!.tag)
    }
    
    
    func shareGig(sender: AnyObject){
        share("Gig", shareID: String(sender.view!.tag))
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
                print("Tweet composition cancelled")
            }
            else {
                print("Sending tweet!")
            }
        }
    }

    func checkIfSharing(UIView: VideoPlayer) {
        
        let ytPlayer = VideoPlayer.sharedInstance
            
        share("Song", shareID: ytPlayer.shareID)
        
    }
    
    func checkIfAdding(UIView: VideoPlayer){
        
        let ytPlayer = VideoPlayer.sharedInstance
        
        addToPlaylist([ytPlayer.ytTitle : ytPlayer.ytID])
        
    }
    
    func closeModal() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}
