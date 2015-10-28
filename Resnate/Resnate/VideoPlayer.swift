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

protocol VideoPlayerUIViewDelegate : class {
    func checkIfSharing(UIView: VideoPlayer)
}


class VideoPlayer: UIView, UIGestureRecognizerDelegate, FBSDKSharingDelegate {
    
    static let sharedInstance = VideoPlayer()
    
    weak var delegate:VideoPlayerUIViewDelegate?
    
    var videoPlayer = YouTubePlayerView(frame: CGRect(x: -170, y: UIScreen.mainScreen().bounds.height - 200, width: 160, height: 90))
    
    var playerControls = UIView(frame: CGRect(x: -170, y: UIScreen.mainScreen().bounds.height - 95, width: 160, height: 35))
    
    var ytID = ""
    
    var ytTitle = ""
    
    var shareID = ""
    
    var activityID = 0
    
    var playerOverlay = UIView(frame: CGRect(x: -170, y: UIScreen.mainScreen().bounds.height - 200, width: 160, height: 90))
    
    
    init() {
        
        super.init(frame: CGRectZero)
        
        self.playerOverlay.tag = -56
        
        self.videoPlayer.layer.borderWidth = 1
        
        self.videoPlayer.layer.borderColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0).CGColor
        
        self.playerControls.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        
        self.playerControls.tag = 999999999
        
        self.videoPlayer.userInteractionEnabled = false
        self.playerControls.userInteractionEnabled = false
        self.playerControls.userInteractionEnabled = true
        
        let pauseTap = UITapGestureRecognizer()
        pauseTap.addTarget(self, action: "pauseVid")
        self.playerOverlay.addGestureRecognizer(pauseTap)
        
        let swipeUp = UISwipeGestureRecognizer()
        swipeUp.direction = .Up
        swipeUp.addTarget(self, action: "showControls")
        self.playerOverlay.addGestureRecognizer(swipeUp)
        
        
        let swipeDown = UISwipeGestureRecognizer()
        swipeDown.direction = .Down
        swipeDown.addTarget(self, action: "hideControls")
        self.playerOverlay.addGestureRecognizer(swipeDown)
        
        
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.direction = .Right
        swipeRight.addTarget(self, action: "hidePlayer")
        self.playerOverlay.addGestureRecognizer(swipeRight)
        
        
        
        
        
        
        
        
        let addSong = UIImageView(frame: CGRect(x: 5, y: 5, width: 25, height: 25))
        
        addSong.image = UIImage(named: "plusWhite")
        
        self.playerControls.addSubview(addSong)
        
        
        let likeSong = UIImageView(frame: CGRect(x: 35, y: 5, width: 25, height: 25))
        
        likeSong.image = UIImage(named: "likeWhite")
        
        self.playerControls.addSubview(likeSong)
        
        
        let shareSong = UIImageView(frame: CGRect(x: 67, y: 5, width: 25, height: 25))
        
        shareSong.image = UIImage(named: "Share")
        
        self.playerControls.addSubview(shareSong)
        
        
        let fbSong = UIImageView(frame: CGRect(x: 99, y: 5, width: 25, height: 25))
        
        fbSong.image = UIImage(named: "facebook.jpg")
        
        self.playerControls.addSubview(fbSong)
        
        
        let twitSong = UIImageView(frame: CGRect(x: 129, y: 5, width: 25, height: 25))
        
        twitSong.image = UIImage(named: "twitter")
        
        self.playerControls.addSubview(twitSong)
        
        
        
        let tapLike = UITapGestureRecognizer()
        likeSong.addGestureRecognizer(tapLike)
        
        likeSong.userInteractionEnabled = true
        tapLike.addTarget(self, action: "likeSong:")
        
        
        let tapShareSong = UITapGestureRecognizer()
        
        tapShareSong.addTarget(self, action: "share")
        //tapShareSong = sender.view!.tag
        shareSong.addGestureRecognizer(tapShareSong)
        shareSong.userInteractionEnabled = true

        
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playVid(videoID: String) {
        
        self.videoPlayer.tag = 1
        
        self.videoPlayer.layer.zPosition = 1
        
        self.playerOverlay.layer.zPosition = 2
        
        self.playerControls.layer.zPosition = -1
        
        self.videoPlayer.frame.origin.x = UIScreen.mainScreen().bounds.width - 170
        
        self.videoPlayer.frame.origin.y = UIScreen.mainScreen().bounds.height - 150
        
        self.playerOverlay.frame.origin.x = UIScreen.mainScreen().bounds.width - 170
        
        self.playerOverlay.frame.origin.y = UIScreen.mainScreen().bounds.height - 150
        
        self.playerControls.frame.origin.x = UIScreen.mainScreen().bounds.width - 170
        
        self.playerControls.frame.origin.y = UIScreen.mainScreen().bounds.height - 109
        
        
        self.playerOverlay.backgroundColor = UIColor.clearColor()
        
        for view in self.playerOverlay.subviews {
            
            if view.tag == -1 {
                
                view.removeFromSuperview()
                
            }
        }
        
        
        
        let playingID = videoID
        
        self.videoPlayer.playerVars = ["playsinline": "1", "modestbranding": "1", "showinfo": "0", "rel": "0", "controls": "0", "iv_load_policy": "3", "autoplay": "1"]
        
        self.videoPlayer.loadVideoID(playingID)
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["song" : ["content": "\(self.ytID)", "name": "\(self.ytTitle)" ], "token": "\(resnateToken)"]
        
        let URL = NSURL(string: "https://www.resnate.com/api/songs/")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters ).0).responseJSON { response in
                
                let json = JSON(response.result.value!)
            
                if let activity = json["activity"].string {
                    
                    self.activityID = Int(activity)!
                    
                }
        }
        
        
        
    }
    
    func pauseVid(){
        
        let playButton = UIImageView(frame: CGRect(x: 55, y: 21, width: 50, height: 50))
        
        if self.videoPlayer.frame.width == UIScreen.mainScreen().bounds.width {
            
            playButton.frame.origin.x = UIScreen.mainScreen().bounds.height/2 - 25
            playButton.frame.origin.y = UIScreen.mainScreen().bounds.width/2 - 25
            
        }
        
        playButton.tag = -1
        
        playButton.image = UIImage(named: "play")
        
        if self.videoPlayer.playerState == .Playing {
            
            self.videoPlayer.pause()
            
            self.playerOverlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            self.playerOverlay.addSubview(playButton)
            
        } else if self.videoPlayer.playerState == .Paused {
            
            self.videoPlayer.play()
            
            self.playerOverlay.backgroundColor = UIColor.clearColor()
            
            for view in self.playerOverlay.subviews {
                
                if view.tag == -1 {
                    
                    view.removeFromSuperview()
                    
                }
                
            }
            
        }
        
    }
    
    func likeSong(sender: AnyObject){
        
        let likeSong = UIImageView(frame: CGRect(x: 35, y: 5, width: 25, height: 25))
        
        likeSong.image = UIImage(named: "liked")
        
        self.playerControls.addSubview(likeSong)
        
        let tapUnlike = UITapGestureRecognizer()
        likeSong.addGestureRecognizer(tapUnlike)
        
        likeSong.userInteractionEnabled = true
        tapUnlike.addTarget(self, action: "unlikeSong:")
        
        sender.view!!.removeFromSuperview()
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["likeable_id" : "\(self.activityID)", "likeable_type" : "Song", "token": "\(resnateToken)"]
        
        let URL = NSURL(string: "https://www.resnate.com/api/likes/")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
           
        }
        
    }
    
    func unlikeSong(sender: AnyObject){
        
        let likeSong = UIImageView(frame: CGRect(x: 35, y: 5, width: 25, height: 25))
        
        likeSong.image = UIImage(named: "likeWhite")
        
        self.playerControls.addSubview(likeSong)
        
        let tapLike = UITapGestureRecognizer()
        likeSong.addGestureRecognizer(tapLike)
        
        likeSong.userInteractionEnabled = true
        tapLike.addTarget(self, action: "likeSong:")
        
        sender.view!!.removeFromSuperview()
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["likeable_id" : self.activityID, "likeable_type" : "Song", "token": "\(resnateToken)"]
        
        let URL = NSURL(string: "https://www.resnate.com/api/likes/")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.DELETE.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters as? [String : AnyObject]).0).responseJSON { response in
            
        }
    }
    
    func fbSong(sender: AnyObject){
        
        let content = FBSDKShareLinkContent()
        
        content.contentURL = NSURL(string: "https://youtu.be/\(self.ytID)")
        
        let shareDialog = FBSDKShareDialog()
        shareDialog.fromViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        shareDialog.shareContent = content
        shareDialog.delegate = self
        shareDialog.mode = .Native
        if !shareDialog.canShow() {
            shareDialog.mode = .FeedBrowser
        }
        
        shareDialog.show()
        
    }
    
    func twitSong(sender: AnyObject){
        let composer = TWTRComposer()
        let url = "Listening to \(self.ytTitle) youtu.be/\(self.ytID) @resnate"
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
    
    func hidePlayer(){
        
        if UIApplication.sharedApplication().statusBarHidden == false
        {
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: [.CurveEaseInOut, .AllowUserInteraction],
                animations: {
                    
                    self.videoPlayer.frame.origin.x = UIScreen.mainScreen().bounds.width + 10
                    self.playerOverlay.frame.origin.x = UIScreen.mainScreen().bounds.width + 10
                    self.playerControls.frame.origin.x = UIScreen.mainScreen().bounds.width + 10
                },
                completion: { finished in
                    

                    self.videoPlayer.stop()
                    self.videoPlayer.tag = -1
                    
            })
            
        }
    }
    
    func showControls(){
        
        if UIApplication.sharedApplication().statusBarHidden == false
        {
            
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: [.CurveEaseInOut, .AllowUserInteraction],
                animations: {
                    self.playerControls.frame.origin.x = UIScreen.mainScreen().bounds.width - 170
                    self.playerControls.frame.origin.y = UIScreen.mainScreen().bounds.height - 95
                    self.videoPlayer.frame.origin.y = UIScreen.mainScreen().bounds.height - 184
                    self.playerOverlay.frame.origin.y = UIScreen.mainScreen().bounds.height - 184
                },
                completion: { finished in
                    
                    self.playerControls.layer.zPosition = 999
                    self.playerControls.userInteractionEnabled = true
                    
            })
            
            
            
        }
        
        
    }
    
    func share(){
        videoPlayer.tag = -1
        delegate?.checkIfSharing(self)
    }
    
    
    func hideControls(){
        
        if UIApplication.sharedApplication().statusBarHidden == false
        {
            
            
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: [.CurveEaseInOut, .AllowUserInteraction],
                animations: {
                    
                    self.videoPlayer.frame.origin.y = UIScreen.mainScreen().bounds.height - 150
                    self.playerOverlay.frame.origin.y = UIScreen.mainScreen().bounds.height - 150
                    self.playerControls.layer.zPosition = -1
                },
                completion: { finished in
                    
                    self.playerControls.userInteractionEnabled = false
                    
            })
        }
        
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject: AnyObject]) {
        print(results)
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("sharer NSError")
        print(error.description)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("sharerDidCancel")
    }
    

    
}