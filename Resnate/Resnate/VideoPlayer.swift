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
    func checkIfAdding(UIView: VideoPlayer)
}


class VideoPlayer: UIView, UIGestureRecognizerDelegate, FBSDKSharingDelegate, UITextViewDelegate {
    
    static let sharedInstance = VideoPlayer()
    
    weak var delegate:VideoPlayerUIViewDelegate?
    
    var videoReviewView = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width*2, y: -UIScreen.mainScreen().bounds.height, width: 160, height: 90))
    
    var reviewTextView = UITextView(frame: CGRect(x: 0, y: 50, width: 160, height: 90))
    
    var postReview = UILabel(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - UIScreen.mainScreen().bounds.width/1.85 - 40, width: UIScreen.mainScreen().bounds.width, height: 40))
    
    var videoPlayer = YouTubePlayerView(frame: CGRect(x: -170, y: UIScreen.mainScreen().bounds.height - 200, width: 160, height: 90))
    
    let videoSlider = PlaybackSlider(frame: CGRect(x: 5, y: UIScreen.mainScreen().bounds.height - 35, width: UIScreen.mainScreen().bounds.width, height: 30))
    
    let currentTime = UILabel(frame: CGRect(x: 5, y: UIScreen.mainScreen().bounds.width/1.85 - 35, width: 70, height: 30))
    
    let duration = UILabel(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 45, y: UIScreen.mainScreen().bounds.width/1.85 - 35, width: 70, height: 30))
    
    let pauseButton = UIImageView(frame: CGRect(x: 55, y: 21, width: 50, height: 50))
    
    let playButton = UIImageView(frame: CGRect(x: 55, y: 21, width: 50, height: 50))
    
    let width = UIScreen.mainScreen().bounds.width
    
    var ytID = ""
    
    var ytTitle = ""
    
    var shareID = ""
    
    var activityID = 0
    
    var playerOverlay = UIView(frame: CGRect(x: -200, y: -100, width: 160, height: 90))
    
    var touches = false
    
    
    init() {
        
        super.init(frame: CGRectZero)
        
        self.videoPlayer.addSubview(self.playerOverlay)
        
        self.postReview.text = "Post Review"
        
        self.reviewTextView.textColor = UIColor.lightGrayColor()
        
        self.reviewTextView.selectedTextRange = self.reviewTextView.textRangeFromPosition(self.reviewTextView.beginningOfDocument, toPosition: self.reviewTextView.beginningOfDocument)
        
        self.postReview.textAlignment = .Center
        
        self.postReview.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        
        self.postReview.textColor = UIColor.lightGrayColor()
        
        self.duration.textColor = UIColor.whiteColor()
        
        self.duration.font = UIFont(name: "HelveticaNeue-Light", size: 11)
        
        self.currentTime.textColor = UIColor.whiteColor()
        
        self.currentTime.font = UIFont(name: "HelveticaNeue-Light", size: 11)
        
        let postTap = UITapGestureRecognizer()
        
        self.postReview.addGestureRecognizer(postTap)
        
        postTap.addTarget(self, action: "postSongReview")
        
        self.postReview.userInteractionEnabled = true
        
        self.videoPlayer.layer.borderWidth = 1
        
        self.videoPlayer.layer.borderColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0).CGColor
        
        self.videoPlayer.userInteractionEnabled = false
        
        self.reviewTextView.delegate = self
        
        
        
        let pauseTap = UITapGestureRecognizer()
        pauseTap.addTarget(self, action: "expandOrFade")
        self.playerOverlay.addGestureRecognizer(pauseTap)
        
        let swipeUp = UISwipeGestureRecognizer()
        swipeUp.direction = .Up
        swipeUp.addTarget(self, action: "reviewView")
        self.playerOverlay.addGestureRecognizer(swipeUp)
        
        
        let swipeDown = UISwipeGestureRecognizer()
        swipeDown.direction = .Down
        swipeDown.addTarget(self, action: "hideReviewView")
        self.playerOverlay.addGestureRecognizer(swipeDown)
        
        
        let swipeRight = UISwipeGestureRecognizer()
        swipeRight.direction = .Right
        swipeRight.addTarget(self, action: "hidePlayer")
        self.playerOverlay.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.direction = .Left
        swipeLeft.addTarget(self, action: "hidePlayerLeft")
        self.playerOverlay.addGestureRecognizer(swipeLeft)
        
        
        videoReviewView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        let fifthWidth = width/5
        
        
        let addSong = UIImageView(frame: CGRect(x: width/2 - 20 - (2*fifthWidth), y: 5, width: 40, height: 40))
        
        addSong.image = UIImage(named: "plusWhite")
        
        self.videoReviewView.addSubview(addSong)
        
        
        let likeSong = UIImageView(frame: CGRect(x: width/2 - 20 - fifthWidth, y: 5, width: 40, height: 40))
        
        likeSong.image = UIImage(named: "likeWhite")
        
        likeSong.tag = -713
        
        self.videoReviewView.addSubview(likeSong)
        
        
        let shareSong = UIImageView(frame: CGRect(x: width/2 - 20, y: 5, width: 40, height: 40))
        
        shareSong.image = UIImage(named: "Share")
        
        self.videoReviewView.addSubview(shareSong)
        
        
        let fbSong = UIImageView(frame: CGRect(x: width/2 - 20 + fifthWidth, y: 5, width: 40, height: 40))
        
        fbSong.image = UIImage(named: "facebook.jpg")
        
        self.videoReviewView.addSubview(fbSong)
        
        
        let twitSong = UIImageView(frame: CGRect(x: width/2 - 20 + (2*fifthWidth), y: 5, width: 40, height: 40))
        
        twitSong.image = UIImage(named: "twitter")
        
        self.videoReviewView.addSubview(twitSong)
        
        let tapAdd = UITapGestureRecognizer()
        addSong.addGestureRecognizer(tapAdd)
        addSong.userInteractionEnabled = true
        tapAdd.addTarget(self, action: "addSong")
        
        let tapLike = UITapGestureRecognizer()
        likeSong.addGestureRecognizer(tapLike)
        likeSong.userInteractionEnabled = true
        tapLike.addTarget(self, action: "likeSong:")
        
        
        let tapShareSong = UITapGestureRecognizer()
        tapShareSong.addTarget(self, action: "share")
        shareSong.addGestureRecognizer(tapShareSong)
        shareSong.userInteractionEnabled = true

        
        let fbShareSong = UITapGestureRecognizer()
        fbShareSong.addTarget(self, action: "fbSong")
        fbSong.addGestureRecognizer(fbShareSong)
        fbSong.userInteractionEnabled = true
        
        
        let twitShareSong = UITapGestureRecognizer()
        twitShareSong.addTarget(self, action: "twitSong")
        twitSong.addGestureRecognizer(twitShareSong)
        twitSong.userInteractionEnabled = true
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reviewKeyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reviewKeyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSong(){
        
        print(self.shareID)
        delegate?.checkIfAdding(self)
        
    }
    
    
    func playVid(videoID: String) {
        
        self.videoPlayer.tag = 1
        
        self.videoPlayer.layer.zPosition = 9
        
        self.playerOverlay.layer.zPosition = 99
        
        self.videoPlayer.frame.origin.x = UIScreen.mainScreen().bounds.width - 170
        
        self.videoPlayer.frame.origin.y = UIScreen.mainScreen().bounds.height - 150
        
        self.playerOverlay.frame.origin.x = UIScreen.mainScreen().bounds.width - 170
        
        self.playerOverlay.frame.origin.y = UIScreen.mainScreen().bounds.height - 150
        
        self.playerOverlay.backgroundColor = UIColor.clearColor()
        
        for view in self.playerOverlay.subviews {
            

                
                view.removeFromSuperview()
                

        }
        
        let playingID = videoID
        
        self.videoPlayer.playerVars = ["playsinline": "1", "modestbranding": "1", "showinfo": "0", "rel": "0", "controls": "0", "iv_load_policy": "3", "autoplay": "1"]
        
        self.videoPlayer.loadVideoID(playingID)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let privacy = userDefaults.boolForKey("listening_preference")
        
        if privacy == false {
            
            let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
            
            let resnateToken = dictionary!["token"] as! String
            
            let resnateID = dictionary!["userID"] as! String
            
            let parameters =  ["song" : ["content": "\(self.ytID)", "name": "\(self.ytTitle)" ], "token": "\(resnateToken)"]
            
            let URL = NSURL(string: "https://www.resnate.com/api/songs/")!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
            mutableURLRequest.HTTPMethod = Method.POST.rawValue
            mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
            
            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters ).0).responseJSON { response in
                
                let json = JSON(response.result.value!)
                
                if let activity = json["activity"].string {
                    
                    self.activityID = Int(activity)!
                    
                    let req = Router(OAuthToken: resnateToken, userID: activity)
                    
                    request(req.buildURLRequest("likes/ifLike/Song/\(resnateID)/", path: "")).responseJSON { response in
                        
                        if let re = response.result.value {
                            
                            let json = JSON(re)
                            
                            if let count = json["count"].int {
                                
                                if count > 0 {
                                    
                                    for view in self.videoReviewView.subviews {
                                        
                                        if view.tag == -713 {
                                            let imageView = view as! UIImageView
                                            imageView.image = UIImage(named: "liked")
                                            imageView.gestureRecognizers?.removeAll(keepCapacity: false)
                                            let tapUnlike = UITapGestureRecognizer()
                                            tapUnlike.addTarget(self, action: "unlikeSong:")
                                            imageView.addGestureRecognizer(tapUnlike)
                                            view.tag = -714
                                            
                                        }
                                    }
                                    
                                } else {
                                    
                                    for view in self.videoReviewView.subviews {
                                        
                                        if view.tag == -714 {
                                            let imageView = view as! UIImageView
                                            imageView.image = UIImage(named: "likeWhite")
                                            imageView.gestureRecognizers?.removeAll(keepCapacity: false)
                                            let tapLike = UITapGestureRecognizer()
                                            tapLike.addTarget(self, action: "likeSong:")
                                            imageView.addGestureRecognizer(tapLike)
                                            view.tag = -713
                                            
                                        }
                                    }
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                    }
                    
                    
                }
            }
            
        }
        
    }
    
    func resumeVid(){
        
        for view in self.playerOverlay.subviews {
            
            view.removeFromSuperview()
            
        }
        self.touches = false
        
        self.playerOverlay.backgroundColor = UIColor.clearColor()
        
        self.videoPlayer.play()
    }
    
    func pauseVid(){
        
        self.pauseButton.removeFromSuperview()
        
        self.playerOverlay.addSubview(playButton)
        
        playButton.layer.zPosition = 999
        
        if self.videoPlayer.frame.width == UIScreen.mainScreen().bounds.width && UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            
            playButton.frame = CGRect(x: UIScreen.mainScreen().bounds.height/2 - 25, y: UIScreen.mainScreen().bounds.width/2 - 25, width: 50, height: 50)
            
        } else if self.videoPlayer.frame.width == UIScreen.mainScreen().bounds.width && UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) == false {
            
            playButton.frame = CGRect(x: UIScreen.mainScreen().bounds.width/2 - 25, y: UIScreen.mainScreen().bounds.width/1.85/2 - 25, width: 50, height: 50)
            
        }
        
        self.touches = true
        
        playButton.image = UIImage(named: "play")
        
        let tapPlay = UITapGestureRecognizer()
        
        tapPlay.addTarget(self, action: "resumeVid")
        
        playButton.addGestureRecognizer(tapPlay)
        
        playButton.userInteractionEnabled = true
        
        if self.videoPlayer.playerState == .Playing {
            
            self.videoPlayer.pause()
            
            //no overlay in mini player
            
            if self.videoPlayer.frame.width == UIScreen.mainScreen().bounds.width && UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            
                self.playerOverlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
                
                self.playerOverlay.addSubview(playButton)
                
                self.videoPlayer.getDuration({ (youTubeTime) -> () in
                    self.playerOverlay.addSubview(self.duration)
                    self.duration.text = youTubeTime.youTubeTime
                })
                
                self.videoPlayer.getCurrentTime({ (youTubeTime) -> () in
                        
                        self.playerOverlay.addSubview(self.currentTime)
                        self.currentTime.text = youTubeTime.youTubeTime
                    
                })
                
            }
            
        } else if self.videoPlayer.playerState == .Paused {
            
            self.videoPlayer.play()
            
            
            self.playerOverlay.backgroundColor = UIColor.clearColor()
            
            for view in self.playerOverlay.subviews {
                

                    
                    view.removeFromSuperview()
                    

                
            }
            
        }
        
    }
    
    func expandOrFade(){
        
        if Int(self.videoPlayer.frame.width) == 160 {

            reviewView()
            
        } else {
        
            if self.playerOverlay.subviews.count == 0 {
                
                if self.videoPlayer.playerState == .Playing {
                    
                    pauseButton.image = UIImage(named: "pause")
                    
                    let tapPause = UITapGestureRecognizer()
                    
                    tapPause.addTarget(self, action: "pauseVid")
                    
                    pauseButton.addGestureRecognizer(tapPause)
                    
                    pauseButton.userInteractionEnabled = true
                    
                    self.playerOverlay.addSubview(pauseButton)
                    
                } else if self.videoPlayer.playerState == .Paused {
                    
                    playButton.image = UIImage(named: "play")
                    
                    let tapPlay = UITapGestureRecognizer()
                    
                    tapPlay.addTarget(self, action: "resumeVid")
                    
                    playButton.addGestureRecognizer(tapPlay)
                    
                    playButton.userInteractionEnabled = true
                    
                    playButton.frame = CGRect(x: UIScreen.mainScreen().bounds.width/2 - 25, y: UIScreen.mainScreen().bounds.width/1.85/2 - 25, width: 50, height: 50)
                    
                    self.playerOverlay.addSubview(playButton)
                    
                    self.videoPlayer.getDuration({ (youTubeTime) -> () in
                        self.playerOverlay.addSubview(self.duration)
                        self.duration.text = youTubeTime.youTubeTime
                    })
                    
                    self.videoPlayer.getCurrentTime({ (youTubeTime) -> () in
                        
                        self.playerOverlay.addSubview(self.currentTime)
                        self.currentTime.text = youTubeTime.youTubeTime
                        
                    })
                    
                }
                
                
                
                self.playerOverlay.addSubview(self.videoSlider)
                
                if self.videoPlayer.frame.width == UIScreen.mainScreen().bounds.width && UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
                    
                    pauseButton.frame = CGRect(x: UIScreen.mainScreen().bounds.height/2 - 25, y: UIScreen.mainScreen().bounds.width/2 - 25, width: 50, height: 50)
                    
                    self.currentTime.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.width - 35, width: 70, height: 30)
                    
                    self.duration.frame = CGRect(x: UIScreen.mainScreen().bounds.height - 45, y: UIScreen.mainScreen().bounds.width - 35, width: 70, height: 30)
                    
                    self.videoSlider.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.width - 65, width: UIScreen.mainScreen().bounds.height - 10, height: 30)
                    
                } else if self.videoPlayer.frame.width == UIScreen.mainScreen().bounds.width && UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) == false {
                    
                    pauseButton.frame = CGRect(x: UIScreen.mainScreen().bounds.width/2 - 25, y: UIScreen.mainScreen().bounds.width/1.85/2 - 25, width: 50, height: 50)
                    
                    self.currentTime.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.width/1.85 - 35, width: 70, height: 30)
                    
                    self.duration.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 45, y: UIScreen.mainScreen().bounds.width/1.85 - 35, width: 70, height: 30)
                    
                    self.videoSlider.frame = CGRect(x: 5, y: self.playerOverlay.frame.height - 55, width: UIScreen.mainScreen().bounds.width - 10, height: 30)
                    
                }
                
                if self.playerOverlay.backgroundColor != UIColor(white: 0, alpha: 0.5) {
                    
                    UIView.animateWithDuration(0.25, animations: {
                        self.playerOverlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
                    })
                    
                    self.videoPlayer.getDuration({ (youTubeTime) -> () in
                        self.playerOverlay.addSubview(self.duration)
                        self.duration.text = youTubeTime.youTubeTime
                    })
                    self.videoPlayer.getCurrentTime({ (youTubeTime) -> () in
                        
                        self.playerOverlay.addSubview(self.currentTime)
                        self.currentTime.text = youTubeTime.youTubeTime
                        
                    })
                } else {
                    self.playerOverlay.backgroundColor = UIColor.clearColor()
                    self.playerOverlay.subviews.map({ $0.removeFromSuperview() })
                }
                
            }
            
            let delay = 2.25 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                if self.touches == false && self.videoPlayer.playerState == .Playing {
                    self.playerOverlay.backgroundColor = UIColor.clearColor()
                    self.playerOverlay.subviews.map({ $0.removeFromSuperview() })
                }
            }
            
        }
        
    }
    
    func fadeOutOverlay(){
        
        self.playerOverlay.backgroundColor = UIColor.clearColor()
        self.playerOverlay.subviews.map({ $0.removeFromSuperview() })
        
    }
    
    func likeSong(sender: AnyObject){
        
        let fifthWidth = self.width/5
        
        let width = UIScreen.mainScreen().bounds.width
        
        let likeSong = UIImageView(frame: CGRect(x: width/2 - 20 - fifthWidth, y: 5, width: 40, height: 40))
        
        likeSong.image = UIImage(named: "liked")
        
        self.videoReviewView.addSubview(likeSong)
        
        let tapUnlike = UITapGestureRecognizer()
        likeSong.addGestureRecognizer(tapUnlike)
        
        likeSong.userInteractionEnabled = true
        tapUnlike.addTarget(self, action: "unlikeSong:")
        
        sender.view!.removeFromSuperview()
        
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
        
        let fifthWidth = self.width/5
        
        let width = UIScreen.mainScreen().bounds.width
        
        let likeSong = UIImageView(frame: CGRect(x: width/2 - 20 - fifthWidth, y: 5, width: 40, height: 40))
        
        likeSong.image = UIImage(named: "likeWhite")
        
        self.videoReviewView.addSubview(likeSong)
        
        let tapLike = UITapGestureRecognizer()
        likeSong.addGestureRecognizer(tapLike)
        
        likeSong.userInteractionEnabled = true
        tapLike.addTarget(self, action: "likeSong:")
        
        sender.view!.removeFromSuperview()
        
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
    
    func fbSong(){
        
        print(self.ytID)
        
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
    
    func twitSong(){
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
            self.reviewTextView.endEditing(true)
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: [.CurveEaseInOut, .AllowUserInteraction],
                animations: {
                    
                    self.videoPlayer.frame.origin.x = UIScreen.mainScreen().bounds.width + 10
                    self.playerOverlay.frame.origin.x = UIScreen.mainScreen().bounds.width + 10
                    
                },
                completion: { finished in

                    self.videoPlayer.stop()
                    
            })
            
        }
    }
    
    func hidePlayerLeft(){
        
        if UIApplication.sharedApplication().statusBarHidden == false
        {
            self.reviewTextView.endEditing(true)
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: [.CurveEaseInOut, .AllowUserInteraction],
                animations: {
                    
                    self.videoPlayer.frame.origin.x = -UIScreen.mainScreen().bounds.width - 190
                    self.playerOverlay.frame.origin.x = UIScreen.mainScreen().bounds.width + 10
                    self.videoReviewView.frame.origin.x = UIScreen.mainScreen().bounds.width
                },
                completion: { finished in
                    
                    
                    self.videoPlayer.stop()
                    
            })
            
        }
    }
    
    
    func reviewView(){
        
        self.reviewTextView.text = "Write a review for \(ytTitle)"
        
        if UIApplication.sharedApplication().statusBarHidden == false
        {
            
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: [.CurveEaseInOut, .AllowUserInteraction],
                animations: {

                    self.videoPlayer.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width/1.85)
                    
                    self.videoReviewView.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.width/1.85, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - UIScreen.mainScreen().bounds.width/1.85)
                    
                    self.reviewTextView.frame = CGRect(x: 0, y: 50, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - UIScreen.mainScreen().bounds.width/1.85 - 90)
                    
                    self.playerOverlay.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width/1.85)
                    
                    self.videoSlider.frame = CGRect(x: 5, y: self.playerOverlay.frame.height - 55, width: UIScreen.mainScreen().bounds.width - 10, height: 30)
                },
                completion: { finished in
                    UIApplication.sharedApplication().statusBarHidden = true
                        
                        self.pauseButton.frame.origin.x = UIScreen.mainScreen().bounds.width/2 - 25
                        self.pauseButton.frame.origin.y = UIScreen.mainScreen().bounds.width/1.85/2 - 25

                        self.playButton.frame.origin.x = UIScreen.mainScreen().bounds.width/2 - 25
                        self.playButton.frame.origin.y = UIScreen.mainScreen().bounds.width/1.85/2 - 25
                    
            })
            
            
            
        }
        
        
    }
    
    func share(){
        videoPlayer.tag = -1
        delegate?.checkIfSharing(self)
    }
    
    
    func hideReviewView(){
        
        UIApplication.sharedApplication().statusBarHidden = false
        
        self.playerOverlay.backgroundColor = UIColor.clearColor()
        
        if self.videoPlayer.frame.width > 160
        {
            self.reviewTextView.endEditing(true)
            
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: [.CurveEaseInOut, .AllowUserInteraction],
                animations: {
                    
                    //minimise player to bottom right
                    self.videoPlayer.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 170, y: UIScreen.mainScreen().bounds.height - 150, width: 160, height: 90)
                    
                    self.playerOverlay.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 170, y: UIScreen.mainScreen().bounds.height - 150, width: 160, height: 90)
                    
                    self.videoReviewView.frame = CGRect(x: UIScreen.mainScreen().bounds.width, y: UIScreen.mainScreen().bounds.height, width: 160, height: 90)
                    
                    
                },
                completion: { finished in
                    
                    if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
                        
                        //no buttons in portrait mini player
                        for view in self.playerOverlay.subviews {
                            
                            view.removeFromSuperview()
                            
                        }
                        
                    } else {

                        self.currentTime.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.width - 35, width: 70, height: 30)
                        
                        self.duration.frame = CGRect(x: UIScreen.mainScreen().bounds.height - 45, y: UIScreen.mainScreen().bounds.width - 35, width: 70, height: 30)
                    }
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.characters.count == 0 {
            
            textView.text = "Write a review for this song/album/show!"
            textView.textColor = UIColor.lightGrayColor()
            postReview.textColor = UIColor.lightGrayColor()
            postReview.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if textView.textColor == UIColor.lightGrayColor() && text.characters.count > 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
            postReview.textColor = UIColor.whiteColor()
            postReview.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
        }
        
        let length = textView.text.utf16.count + text.utf16.count - range.length
        
        return length <= 5000
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
    }
    
    func reviewKeyboardWillShow(notification: NSNotification) {
        self.reviewTextView.selectedTextRange = self.reviewTextView.textRangeFromPosition(self.reviewTextView.beginningOfDocument, toPosition: self.reviewTextView.beginningOfDocument)
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardHeight:CGFloat = keyboardSize.height
        self.reviewTextView.frame = CGRect(x: 0, y: 50, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - UIScreen.mainScreen().bounds.width/1.85 - 90 - keyboardHeight)
        self.postReview.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - UIScreen.mainScreen().bounds.width/1.85 - 40 - keyboardHeight, width: UIScreen.mainScreen().bounds.width, height: 40)
        
        
    }
    
    func reviewKeyboardWillHide(sender: NSNotification) {
        
        self.postReview.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - UIScreen.mainScreen().bounds.width/1.85 - 40, width: UIScreen.mainScreen().bounds.width, height: 40)
        self.reviewTextView.frame = CGRect(x: 0, y: 50, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - UIScreen.mainScreen().bounds.width/1.85 - 90)
        
        
    }
    
    func postSongReview() {
        
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        if self.postReview.backgroundColor == UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0) {
            
          
                
                if self.reviewTextView.text != "Write a review for this song/album/show!" && self.shareID != "" {
                    
                    let parameters =  ["token": "\(resnateToken)", "review": ["reviewable_id": "\(self.shareID)", "content":"\(self.reviewTextView.text)", "reviewable_type": "Song" ]]
                    
                    
                    
                    let URL = NSURL(string: "https://www.resnate.com/api/reviews")!
                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                    mutableURLRequest.HTTPMethod = Method.POST.rawValue
                    mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                    
                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters as? [String : AnyObject]).0).responseJSON { response in
                        
                        self.reviewTextView.text = "Write a review for this song/album/show!"
                        
                        self.reviewTextView.textColor = UIColor.lightGrayColor()
                        
                        self.reviewTextView.endEditing(true)
                        
                        self.hideReviewView()
                    }
                    
                }
                
                
            
            
            
        }
        
    }
}