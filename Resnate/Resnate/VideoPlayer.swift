//
//  VideoPlayer.swift
//  Resnate
//
//  Created by Amir Moosavi on 01/08/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit
import Foundation
import FBSDKShareKit
import TwitterKit

class VideoPlayer: UIView {
    
    static let sharedInstance = VideoPlayer()
    
    var videoPlayer = YouTubePlayerView(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 260, y: -200, width: 250, height: 141))
    
    var playerControls = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 260, y: UIScreen.mainScreen().bounds.height - 109, width: 250, height: 50))
    
    var ytID = ""
    
    var ytTitle = ""
    
    
    init() {
        
        super.init(frame: CGRectZero)
        
        self.videoPlayer.layer.borderWidth = 1
        
        self.videoPlayer.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.playerControls.backgroundColor = UIColor.whiteColor()
        
        self.playerControls.tag = 999999999
        
        let swipeUp = UISwipeGestureRecognizer()
        swipeUp.direction = .Up
        swipeUp.addTarget(self, action: "showControls")
        self.videoPlayer.addGestureRecognizer(swipeUp)
        
        
        let swipeDown = UISwipeGestureRecognizer()
        swipeDown.direction = .Down
        swipeDown.addTarget(self, action: "hideControls")
        self.videoPlayer.addGestureRecognizer(swipeDown)
        
        
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.direction = .Right
        swipeRight.addTarget(self, action: "hidePlayer")
        self.videoPlayer.addGestureRecognizer(swipeRight)
        
        
        
        
        
        
        
        
        let addSong = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
        
        addSong.image = UIImage(named: "plus")
        
        self.playerControls.addSubview(addSong)
        
        
        let likeSong = UIImageView(frame: CGRect(x: 55, y: 5, width: 40, height: 40))
        
        likeSong.image = UIImage(named: "like")
        
        self.playerControls.addSubview(likeSong)
        
        
        let shareSong = UIImageView(frame: CGRect(x: 105, y: 5, width: 40, height: 40))
        
        shareSong.image = UIImage(named: "Share")
        
        self.playerControls.addSubview(shareSong)
        
        
        let fbSong = UIImageView(frame: CGRect(x: 155, y: 5, width: 40, height: 40))
        
        fbSong.image = UIImage(named: "facebook.jpg")
        
        self.playerControls.addSubview(fbSong)
        
        
        let twitSong = UIImageView(frame: CGRect(x: 205, y: 5, width: 40, height: 40))
        
        twitSong.image = UIImage(named: "twitter")
        
        self.playerControls.addSubview(twitSong)

        
        let fbShareSong = UITapGestureRecognizer()
        
        fbShareSong.addTarget(self, action: "fbSong:")
        //fbSong.tag = sender.view!.tag
        fbSong.addGestureRecognizer(fbShareSong)
        fbSong.userInteractionEnabled = true
        
        
        let twitShareSong = UITapGestureRecognizer()
        
        twitShareSong.addTarget(self, action: "twitSong:")
        //twitSong.tag = sender.view!.tag
        twitSong.addGestureRecognizer(twitShareSong)
        twitSong.userInteractionEnabled = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playVid(videoID: String, tag: Int) {
        
        self.videoPlayer.layer.zPosition = 1
        
        self.videoPlayer.frame.origin.x = UIScreen.mainScreen().bounds.width - 260
        
        self.videoPlayer.frame.origin.y = UIScreen.mainScreen().bounds.height - 200
        
        self.playerControls.frame.origin.x = UIScreen.mainScreen().bounds.width - 260
        
        self.playerControls.frame.origin.y = UIScreen.mainScreen().bounds.height - 109
        
        
        
        var playingID = videoID
        
        self.videoPlayer.playerVars = ["playsinline": "1", "modestbranding": "1", "showinfo": "0", "rel": "0", "controls": "0", "iv_load_policy": "3", "autoplay": "1"]
        
        self.videoPlayer.loadVideoID(playingID)
        
        
        self.videoPlayer.tag = tag
        
        
        
    }
    
    func fbSong(sender: AnyObject){
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "youtu.be/\(self.ytID)")
        
        let dialog: FBSDKShareDialog = FBSDKShareDialog()
        dialog.fromViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode(rawValue: 0)!
        dialog.show()
    }
    
    func twitSong(sender: AnyObject){
        let composer = TWTRComposer()
        let url = "Listening to \(self.ytTitle) youtu.be/\(self.ytID) @resnate"
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
    
    func hidePlayer(){
        
        if UIApplication.sharedApplication().statusBarHidden == false
        {
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: .CurveEaseInOut | .AllowUserInteraction,
                animations: {
                    
                    self.videoPlayer.frame.origin.x = UIScreen.mainScreen().bounds.width + 10
                    self.playerControls.frame.origin.x = UIScreen.mainScreen().bounds.width + 10
                },
                completion: { finished in
                    

                    self.videoPlayer.stop()
                    
            })
            
        }
    }
    
    func showControls(){
        
        if UIApplication.sharedApplication().statusBarHidden == false
        {
            
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: .CurveEaseInOut | .AllowUserInteraction,
                animations: {
                    
                    self.videoPlayer.frame.origin.y = UIScreen.mainScreen().bounds.height - 250
                },
                completion: { finished in
                    
                    self.playerControls.layer.zPosition = 999
                    
            })
            
            
            
        }
        
        
    }
    
    
    func hideControls(){
        
        if UIApplication.sharedApplication().statusBarHidden == false
        {
            
            
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: .CurveEaseInOut | .AllowUserInteraction,
                animations: {
                    
                    self.videoPlayer.frame.origin.y = UIScreen.mainScreen().bounds.height - 200
                    self.playerControls.layer.zPosition = -1
                },
                completion: { finished in
                    
                    
                    
            })
        }
        
    }
    
}