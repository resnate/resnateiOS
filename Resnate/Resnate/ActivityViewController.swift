//
//  ActivityViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 16/09/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, UITextViewDelegate {
    
    var ID = 0
    
    let width = Int(UIScreen.mainScreen().bounds.width)
    
    let imgWidth = Int(UIScreen.mainScreen().bounds.width) - 20
    
    let imgHeight = Int(Double(UIScreen.mainScreen().bounds.width - 20) / 1.33)
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var commentTextView = UITextView(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - 79, width: UIScreen.mainScreen().bounds.width, height: 30))
    
    var postComment = UILabel(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: UIScreen.mainScreen().bounds.height - 79, width: 50, height: 30))
    
    var type = ""
    
    var song = [String: String]()
    
    let ytPlayer = VideoPlayer.sharedInstance
    
    
    func getSongInfo(songID: Int, view: UIView, token: String, currentUserID: String, likerID: String)  {
        
        let req = Router(OAuthToken: token, userID: String(songID))
        
        request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
            
            let song = JSON(response.result.value!)
            
            if let songID = song["id"].int {
                
                if let songName = song["name"].string {
                    
                    if let songContent = song["content"].string {
                        
                        let likeSong = UIImageView(frame: CGRect(x: self.width/4 - 15, y: self.imgWidth + 120, width: 30, height: 30))
                        
                        view.addSubview(likeSong)
                        
                        let tapLike = UITapGestureRecognizer()
                        
                        
                        likeSong.tag = songID
                        
                        likeSong.addGestureRecognizer(tapLike)
                        
                        likeSong.userInteractionEnabled = true
                        
                        if currentUserID == likerID {
                            
                            likeSong.image = UIImage(named: "liked")
                            tapLike.addTarget(self, action: "unlikeSong:")
                            
                        } else {
                            
                            let req = Router(OAuthToken: token, userID: currentUserID)
                            
                            request(req.buildURLRequest("likes/ifLike/Song/", path: "/\(songID)")).responseJSON { response in
                                if let re = response.result.value {
                                    
                                    let json = JSON(re)
                                    
                                    if let count = json["count"].int {
                                        
                                        if count > 0 {
                                            
                                            likeSong.image = UIImage(named: "liked")
                                            tapLike.addTarget(self, action: "unlikeSong:")
                                            
                                        }
                                            
                                        else {
                                            
                                            likeSong.image = UIImage(named: "likeWhite")
                                            tapLike.addTarget(self, action: "likeSong:")
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                            }
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        let shareSong = UIImageView(frame: CGRect(x: self.width/4 * 3 - 15, y: self.imgWidth + 120, width: 30, height: 30))
                        
                        shareSong.image = UIImage(named: "Share")
                        
                        view.addSubview(shareSong)
                        
                        let tapShare = UITapGestureRecognizer()
                        
                        tapShare.addTarget(self, action: "shareSingleSong:")
                        shareSong.tag = songID
                        
                        shareSong.addGestureRecognizer(tapShare)
                        
                        shareSong.userInteractionEnabled = true
                        
                        let ytSong = [songName: songContent]
                        
                        let songNameLabel = UILabel(frame: CGRect(x: 80, y: 13.5, width: 240, height: 30))
                        
                        songNameLabel.text = songName
                        
                        songNameLabel.textColor = UIColor.whiteColor()
                        songNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                        songNameLabel.numberOfLines = 2
                        
                        view.addSubview(songNameLabel)
                        
                        let activitysongImg = UIImageView(frame: CGRect(x: 10, y: 125, width: self.imgWidth, height: self.imgHeight))
                        
                        
                        
                        let tapVideo = UITapGestureRecognizer()
                        
                        tapVideo.addTarget(self, action: "playSong:")
                        activitysongImg.tag = songID
                        
                        activitysongImg.addGestureRecognizer(tapVideo)
                        
                        activitysongImg.userInteractionEnabled = true
                        
                        view.addSubview(activitysongImg)
                        
                        
                        let songImgUrl = NSURL(string: "https://img.youtube.com/vi/\(songContent)/hqdefault.jpg")
                        
                        self.getDataFromUrl(songImgUrl!) { data in
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                activitysongImg.image = UIImage(data: data!)
                                
                                
                                
                            }
                        }
                        
                        
                    }
                    
                }
                
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(commentTextView)
        
        commentTextView.text = "Write a comment..."
        
        commentTextView.selectedTextRange = commentTextView.textRangeFromPosition(commentTextView.beginningOfDocument, toPosition: commentTextView.beginningOfDocument)
        
        commentTextView.delegate = self
        
        commentTextView.backgroundColor = UIColor.whiteColor()
        
        commentTextView.textColor = UIColor.lightGrayColor()
        
        commentTextView.layer.borderWidth = 1
        
        commentTextView.layer.borderColor = UIColor.blackColor().CGColor
        
        commentTextView.layer.zPosition = 999
        
        commentTextView.becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
            
        self.view.addSubview(postComment)
        
        postComment.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        postComment.text = "Post"
        
        postComment.textColor = UIColor.lightGrayColor()
        
        postComment.font = UIFont(name: "HelveticaNeue", size: 12)
        
        postComment.textAlignment = .Center
        
        postComment.layer.borderWidth = 1
        
        postComment.layer.borderColor = UIColor.blackColor().CGColor
        
        postComment.layer.zPosition = 9999
        
        let postTap = UITapGestureRecognizer()
        
        postComment.addGestureRecognizer(postTap)
        
        postTap.addTarget(self, action: "post:")
        postComment.tag = self.ID
        
        postComment.userInteractionEnabled = true
        
        
        
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        returnComments()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if self.view.frame.origin.y != 0 {
            
            commentTextView.frame.origin.y = UIScreen.mainScreen().bounds.height - 143
            postComment.frame.origin.y = UIScreen.mainScreen().bounds.height - 143
            
        }
        print(postComment.frame.origin.y)
        returnComments()
        
    }
    
    func returnComments(){
        
        self.scrollView.subviews.map({ $0.removeFromSuperview() })
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateID = dictionary!["userID"] as! String
        
        let resnateToken = dictionary!["token"] as! String
        
        let activityID = String(self.ID)
        
        let req = Router(OAuthToken: resnateToken, userID: activityID)
        
        request(req.buildURLRequest("", path: "/activities")).responseJSON { response in
            
            if let re = response.result.value {
                
                let activity = JSON(re)
                
                let activityView = UIView(frame: CGRect(x: 0, y: 10, width: self.width, height: self.imgHeight + 100))
                
                self.scrollView.addSubview(activityView)
                
                if let type = activity["trackable_type"].string {
                    
                    self.type = type
                    
                    
                    let verbLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 14))
                    
                    let userNameLabel = UILabel(frame: CGRect(x: 80, y: 0, width: 190, height: 14))
                    userNameLabel.textColor = UIColor.whiteColor()
                    userNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                    
                    let tapRecProfile = UITapGestureRecognizer()
                    tapRecProfile.addTarget(self, action: "profile:")
                    
                    userNameLabel.addGestureRecognizer(tapRecProfile)
                    userNameLabel.userInteractionEnabled = true
                    
                    activityView.addSubview(userNameLabel)
                    
                    let commentImgView = UIImageView(frame: CGRect(x: self.width/2 - 15, y: self.imgWidth + 120, width: 30, height: 30))
                    
                    commentImgView.image = UIImage(named: "comment")
                    
                    activityView.addSubview(commentImgView)
                    
                    let commentsAndLikesLabel = UILabel(frame: CGRect(x: 10, y: self.imgWidth + 80, width: 300, height: 20))
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                    
                    if let date = activity["created_at"].string {
                        
                        let activityDateString = dateFormatter.dateFromString(date)
                        
                        let timeAgoLabel = UILabel(frame: CGRect(x: 80, y: 45, width: 150, height: 14))
                        timeAgoLabel.textColor = UIColor.whiteColor()
                        timeAgoLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                        timeAgoLabel.text = timeAgoSinceDate(activityDateString!, numericDates: true)
                        activityView.addSubview(timeAgoLabel)
                        
                    }
                    
                    if let ownerID = activity["owner_id"].int {
                        
                        let req = Router(OAuthToken: resnateToken, userID: String(ownerID))
                        
                        request(req.buildURLRequest("users/", path: "")).responseJSON { response in
                            if let re = response.result.value {
                                
                                let user = JSON(re)
                                
                                if let userName = user["name"].string {
                                    
                                    if let userImageID = user["uid"].string {
                                        
                                        if let userID = user["id"].int {
                                            
                                            let userNameLabel = UILabel(frame: CGRect(x: 80, y: 0, width: 190, height: 14))
                                            
                                            userNameLabel.text = userName
                                            userNameLabel.textColor = UIColor.whiteColor()
                                            userNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                            
                                            userNameLabel.sizeToFit()
                                            
                                            
                                            
                                            let tapRecProfile = UITapGestureRecognizer()
                                            tapRecProfile.addTarget(self, action: "profile:")
                                            
                                            userNameLabel.tag = userID
                                            userNameLabel.addGestureRecognizer(tapRecProfile)
                                            userNameLabel.userInteractionEnabled = true
                                            
                                            verbLabel.frame.origin.x = userNameLabel.frame.width + 85
                                            verbLabel.textColor = UIColor.whiteColor()
                                            verbLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                                            
                                            verbLabel.sizeToFit()
                                            
                                            activityView.addSubview(userNameLabel)
                                            
                                            activityView.addSubview(verbLabel)
                                            
                                            let activityUserImg = UIImageView(frame: CGRect(x: 10, y: 0, width: 60, height: 60))
                                            
                                            let userImgUrl = NSURL(string: "https://graph.facebook.com/\(userImageID)/picture?width=200&height=200")
                                            
                                            self.getDataFromUrl(userImgUrl!) { data in
                                                dispatch_async(dispatch_get_main_queue()) {
                                                    activityUserImg.image = UIImage(data: data!)
                                                    
                                                    activityView.addSubview(activityUserImg)
                                                    
                                                    let tapRecProfile = UITapGestureRecognizer()
                                                    tapRecProfile.addTarget(self, action: "profile:")
                                                    
                                                    activityUserImg.tag = userID
                                                    activityUserImg.addGestureRecognizer(tapRecProfile)
                                                    activityUserImg.userInteractionEnabled = true
                                                    
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                    if type == "Song" {
                        
                        verbLabel.text = "listened to"
                        
                        if let songID = activity["trackable_id"].int {
                            
                            self.getSongInfo(songID, view: activityView, token: resnateToken, currentUserID: resnateID, likerID: "")
                            
                            
                        }
                        
                    } else if type == "Socialization::ActiveRecordStores::Follow" {
                        
                        verbLabel.text = "followed"
                        
                        if let trackableID = activity["trackable_id"].int {
                            
                            let followReq = Router(OAuthToken: resnateToken, userID: String(trackableID))
                            
                            request(followReq.buildURLRequest("follows/", path: "")).responseJSON { response in
                                if let re = response.result.value {
                                    
                                    let followable = JSON(re)
                                    
                                    let followeeNameLabel = UILabel(frame: CGRect(x: 80, y: 13.5, width: 240, height: 30))
                                    followeeNameLabel.textColor = UIColor.whiteColor()
                                    followeeNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                    followeeNameLabel.numberOfLines = 2
                                    
                                    activityView.addSubview(followeeNameLabel)
                                    
                                    if let followable_id = followable["followable_id"].int {
                                        
                                        if let followable_type = followable["followable_type"].string {
                                            
                                            if followable_type == "User" {
                                                
                                                let userReq = Router(OAuthToken: resnateToken, userID: String(followable_id))
                                                
                                                request(userReq.buildURLRequest("users/", path: "")).responseJSON { response in
                                                    
                                                    if let re = response.result.value {
                                                        
                                                        let user = JSON(re)
                                                        
                                                        if let uid = user["uid"].string {
                                                            
                                                            let imgUrl = NSURL(string: "https://graph.facebook.com/\(uid)/picture?width=500&height=500")
                                                            
                                                            self.getDataFromUrl(imgUrl!) { data in
                                                                dispatch_async(dispatch_get_main_queue()) {
                                                                    
                                                                    let userImageView = UIImageView(frame: CGRect(x: 10, y: 70, width: self.imgWidth, height: self.imgWidth))
                                                                    userImageView.image = UIImage(data: data!)
                                                                    activityView.addSubview(userImageView)
                                                                    
                                                                    let tapRecProfile = UITapGestureRecognizer()
                                                                    tapRecProfile.addTarget(self, action: "profile:")
                                                                    
                                                                    userImageView.tag = followable_id
                                                                    userImageView.addGestureRecognizer(tapRecProfile)
                                                                    userImageView.userInteractionEnabled = true
                                                                    
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                        if let name = user["name"].string {
                                                            
                                                            followeeNameLabel.text = name
                                                            let tapRecProfile = UITapGestureRecognizer()
                                                            tapRecProfile.addTarget(self, action: "profile:")
                                                            
                                                            followeeNameLabel.tag = followable_id
                                                            followeeNameLabel.addGestureRecognizer(tapRecProfile)
                                                            followeeNameLabel.userInteractionEnabled = true
                                                            
                                                        }
                                                        
                                                    }
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                        
                        
                    } else if type == "Gig" {
                        
                        verbLabel.text = "is going to"
                        
                        
                        if let gigID = activity["trackable_id"].int {
                            
                            self.getGigInfo(gigID, view: activityView, token: resnateToken, currentUserID: resnateID, likerID: "")
                            
                        }
                        
                    } else if type == "Socialization::ActiveRecordStores::Like" {
                        
                        verbLabel.text = "liked"
                        
                        if let likeID = activity["trackable_id"].int {
                            
                            let req = Router(OAuthToken: resnateToken, userID: String(likeID))
                            
                            request(req.buildURLRequest("likes/", path: "")).responseJSON { response in
                                if let re = response.result.value {
                                    
                                    var like = JSON(re)
                                    
                                    if let likeable_type = like["likeable_type"].string {
                                        
                                        if let likeable_id = like["likeable_id"].int {
                                            
                                            if let liker_id = like["liker_id"].int {
                                                
                                                if likeable_type == "Song" {
                                                    
                                                    self.getSongInfo(likeable_id, view: activityView, token: resnateToken, currentUserID: resnateID, likerID: String(liker_id))
                                                    
                                                } else if likeable_type == "Gig" {
                                                    
                                                    self.getGigInfo(likeable_id, view: activityView, token: resnateToken, currentUserID: resnateID, likerID: String(liker_id))
                                                    
                                                }
                                                
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                            }
                            
                            
                        }
                        
                    } else if type == "User" {
                        
                        if let userID = activity["trackable_id"].int {
                            
                            let req = Router(OAuthToken: resnateToken, userID: String(userID))
                            
                            request(req.buildURLRequest("users/", path: "/level")).responseJSON { response in
                                
                                let json = JSON(response.result.value!)
                                
                                if let badgeName = json["level_name"].string {
                                    
                                    let badgeView = UIImageView(frame: CGRect(x: 10, y: 70, width: self.imgWidth, height: self.imgWidth))
                                    
                                    activityView.addSubview(badgeView)
                                    
                                    badgeView.image = UIImage(named: badgeName)
                                    
                                    let badgeNameLabel = UILabel(frame: CGRect(x: 80, y: 13.5, width: 240, height: 30))
                                    
                                    badgeNameLabel.text = "New badge: \(badgeName)"
                                    
                                    badgeNameLabel.textColor = UIColor.whiteColor()
                                    badgeNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                    badgeNameLabel.numberOfLines = 2
                                    
                                    activityView.addSubview(badgeNameLabel)
                                    
                                    
                                }
                                
                            }
                            
                        }
                        
                        
                        
                    }
                    
                    let req = Router(OAuthToken: resnateToken, userID: String(activityID))
                    
                    request(req.buildURLRequest("activity/", path: "/comments/count")).responseJSON { response in
                        
                        if let re = response.result.value {
                            
                            let counts = JSON(re)
                            
                            if let commentsCount = counts["commentsCount"].int {
                                
                                if let likesCount = counts["likesCount"].int {
                                    
                                    
                                    
                                    if commentsCount == 1 && likesCount == 0 {
                                        
                                        commentsAndLikesLabel.text = "\(commentsCount) comment"
                                        
                                    } else if commentsCount > 1 && likesCount == 0 {
                                        
                                        commentsAndLikesLabel.text = "\(commentsCount) comments"
                                        
                                    } else if commentsCount > 1 && likesCount == 1 {
                                        
                                        commentsAndLikesLabel.text = "\(commentsCount) comments \(likesCount) like"
                                        
                                    }  else if commentsCount > 1 && likesCount > 1 {
                                        
                                        commentsAndLikesLabel.text = "\(commentsCount) comments \(likesCount) likes"
                                        
                                    }   else if commentsCount == 1 && likesCount > 1 {
                                        
                                        commentsAndLikesLabel.text = "\(commentsCount) comment \(likesCount) likes"
                                        
                                    }    else if commentsCount == 0 && likesCount > 1 {
                                        
                                        commentsAndLikesLabel.text = "\(likesCount) likes"
                                        
                                    }    else if commentsCount == 0 && likesCount == 1 {
                                        
                                        commentsAndLikesLabel.text = "\(likesCount) like"
                                        
                                    } 
                                    
                                    commentsAndLikesLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                                    
                                    commentsAndLikesLabel.textColor = UIColor.whiteColor()
                                    
                                    activityView.addSubview(commentsAndLikesLabel)
                                    
                                }
                                
                                var y = 190
                                
                                if commentsCount > 0 {
                                    
                                    request(req.buildURLRequest("activity/", path: "/comments/index")).responseJSON { response in
                                        if let re = response.result.value {
                                            
                                            let comments = JSON(re)
                                            
                                            for (_, comment) in comments {
                                                
                                                let commentView = UIView(frame: CGRect(x: 10, y: y  + self.imgHeight, width: self.width - 20, height: 50))
                                                
                                                commentView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
                                                
                                                activityView.addSubview(commentView)
                                                
                                                if let commenterID = comment["user_id"].int {
                                                    
                                                    let req = Router(OAuthToken: resnateToken, userID: String(commenterID))
                                                    
                                                    request(req.buildURLRequest("users/", path: "")).responseJSON { response in
                                                        if let re = response.result.value {
                                                            
                                                            let user = JSON(re)
                                                            
                                                            if let userName = user["name"].string {
                                                                
                                                                if let userImageID = user["uid"].string {
                                                                    
                                                                    if let userID = user["id"].int {
                                                                        
                                                                        let userNameLabel = UILabel(frame: CGRect(x: 60, y: 3, width: 190, height: 14))
                                                                        
                                                                        userNameLabel.text = userName
                                                                        userNameLabel.textColor = UIColor.whiteColor()
                                                                        userNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                                                        
                                                                        userNameLabel.sizeToFit()
                                                                        
                                                                        
                                                                        let tapRecProfile = UITapGestureRecognizer()
                                                                        tapRecProfile.addTarget(self, action: "profile:")
                                                                        
                                                                        userNameLabel.tag = userID
                                                                        userNameLabel.addGestureRecognizer(tapRecProfile)
                                                                        userNameLabel.userInteractionEnabled = true
                                                                        
                                                                        commentView.addSubview(userNameLabel)
                                                                        
                                                                        let activityUserImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                                                                        
                                                                        let userImgUrl = NSURL(string: "https://graph.facebook.com/\(userImageID)/picture?width=100&height=100")
                                                                        
                                                                        self.getDataFromUrl(userImgUrl!) { data in
                                                                            dispatch_async(dispatch_get_main_queue()) {
                                                                                activityUserImg.image = UIImage(data: data!)
                                                                                
                                                                                commentView.addSubview(activityUserImg)
                                                                                
                                                                                let tapRecProfile = UITapGestureRecognizer()
                                                                                tapRecProfile.addTarget(self, action: "profile:")
                                                                                
                                                                                activityUserImg.tag = userID
                                                                                activityUserImg.addGestureRecognizer(tapRecProfile)
                                                                                activityUserImg.userInteractionEnabled = true
                                                                                
                                                                            }
                                                                        }
                                                                        
                                                                        
                                                                    }
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                    if let body = comment["body"].string {
                                                        
                                                        let commentBodyLabel = UILabel(frame: CGRect(x: 60, y: 17, width: self.width - 40, height: 34))
                                                        
                                                        commentBodyLabel.text = body.stringByReplacingOccurrencesOfString("%0A", withString: "\n")
                                                        
                                                        commentBodyLabel.lineBreakMode = .ByTruncatingTail
                                                        commentBodyLabel.numberOfLines = 0
                                                        
                                                        commentBodyLabel.sizeToFit()
                                                        
                                                        
                                                        
                                                        commentBodyLabel.textColor = UIColor.whiteColor()
                                                        
                                                        commentBodyLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                                                        
                                                        commentView.addSubview(commentBodyLabel)
                                                        
                                                        commentView.frame.size.height = commentBodyLabel.frame.height + 50
                                                        
                                                        if let time = comment["updated_at"].string {
                                                            
                                                            let dateFormatter = NSDateFormatter()
                                                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                                                            
                                                            let timeDateString = dateFormatter.dateFromString(time)
                                                            
                                                            let timeLabel = UILabel(frame: CGRect(x: 60, y: 17, width: self.width - 40, height: 14))
                                                            
                                                            timeLabel.frame.origin.y = commentBodyLabel.frame.height + 27
                                                            
                                                            y += Int(commentView.frame.height) + 30
                                                            
                                                            timeLabel.textColor = UIColor.whiteColor()
                                                            
                                                            timeLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                                                            
                                                            timeLabel.text = timeAgoSinceDate(timeDateString!, numericDates: true)
                                                            
                                                            commentView.addSubview(timeLabel)
                                                            
                                                        }
                                                        
                                                        
                                                        
                                                    }
                                                    
                                                }
                                                
                                                
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                                self.scrollView.contentSize.height = CGFloat(self.imgHeight + y + 240)
                                
                            }
                            
                        } else {
                            
                            self.scrollView.contentSize.height = CGFloat(self.imgHeight + 270)
                         
                        }
                    }
                }
                
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardHeight:CGFloat = keyboardSize.height
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.commentTextView.frame = CGRectMake(0, (self.view.bounds.height - keyboardHeight - 30), self.view.bounds.width - 50, 30)
            self.postComment.frame = CGRectMake(self.view.bounds.width - 50, (self.view.bounds.height - keyboardHeight - 30), 50, 30)
            }, completion: nil)

    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        if self.navigationController?.viewControllers.count > 2 {
            
            self.commentTextView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 79, self.view.bounds.width - 50, 30)
            self.postComment.frame = CGRectMake(self.view.bounds.width - 50, UIScreen.mainScreen().bounds.height - 79, 50, 30)
            
        } else {
            
            self.commentTextView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 141, self.view.bounds.width - 50, 30)
            self.postComment.frame = CGRectMake(self.view.bounds.width - 50, UIScreen.mainScreen().bounds.height - 141, 50, 30)
            
        }
        
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.characters.count == 0 {
            
            textView.text = "Write a comment..."
            textView.textColor = UIColor.lightGrayColor()
            postComment.textColor = UIColor.lightGrayColor()
            postComment.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
            
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
            postComment.textColor = UIColor.whiteColor()
            postComment.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
        }
        
        let length = textView.text.utf16.count + text.utf16.count - range.length
        
        return length <= 5000
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
    }
    
    

    func playSong(sender: AnyObject){
        
        self.view.endEditing(true)
        
        let ytPlayer = VideoPlayer.sharedInstance
        
        self.tabBarController?.view.addSubview(ytPlayer.videoPlayer)
        
        let song = self.song
        
        for (name, ytID) in song {
            
            ytPlayer.ytID = ytID
            
            ytPlayer.ytTitle = name
            
            ytPlayer.shareID = "\(self.ID)"
            
            ytPlayer.playVid(ytID)
            
        }
        
        
    }
    
    func post(sender: AnyObject){
        
        if postComment.textColor == UIColor.whiteColor() {
            
            
            let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
            
            let resnateToken = dictionary!["token"] as! String
            
            if ((commentTextView.text!).characters.count <= 3000){
                
                let parameters =  ["body":"\(commentTextView.text)", "token": "\(resnateToken)"]
                
                
                
                let URL = NSURL(string: "https://www.resnate.com/api/activity/\(self.ID)/comments/create")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                mutableURLRequest.HTTPMethod = Method.POST.rawValue
                mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                
                request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                        
                        let delay = 1.5 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            let bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height + 50)
                            self.scrollView.setContentOffset(bottomOffset, animated: true)
                        }
                    
                }
            }
            
            
            commentTextView.text = "Write a comment..."
            commentTextView.textColor = UIColor.lightGrayColor()
            commentTextView.selectedTextRange = commentTextView.textRangeFromPosition(commentTextView.beginningOfDocument, toPosition: commentTextView.beginningOfDocument)
            postComment.textColor = UIColor.lightGrayColor()
            postComment.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
            
            self.view.endEditing(true)
            
            returnComments()
            
        } else {
            
            self.view.endEditing(true)
            
        }  
        
    }

}
