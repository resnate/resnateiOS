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
    
    var ytID = ""
    
    var ytTitle = ""
    
    let width = Int(UIScreen.mainScreen().bounds.width)
    
    let imgWidth = Int(UIScreen.mainScreen().bounds.width) - 20
    
    let imgHeight = Int(Double(UIScreen.mainScreen().bounds.width - 20) / 1.33)
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var commentTextView = UITextView(frame: CGRect(x: 0, y: 300, width: UIScreen.mainScreen().bounds.width, height: 30))
    
    var postComment = UILabel(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: 300, width: 50, height: 30))
    
    var type = ""

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
        
        let postTap = UITapGestureRecognizer()
        
        postComment.addGestureRecognizer(postTap)
        
        postTap.addTarget(self, action: "post:")
        postComment.tag = self.ID
        
        postComment.userInteractionEnabled = true
        
        
        
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        returnComments()
        
    }
    
    func returnComments(){
        
        self.scrollView.subviews.map({ $0.removeFromSuperview() })
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
        
        let resnateToken = dictionary!["token"] as! String
        
        let activityID = String(self.ID)
        
        let req = Router(OAuthToken: resnateToken, userID: activityID)
        
        request(req.buildURLRequest("", path: "/activities")).responseJSON { (_, _, json, error) in
            if json != nil {
                
                var activity = JSON(json!)
                
                var activityView = UIView(frame: CGRect(x: 0, y: 10, width: self.width, height: self.imgHeight + 100))
                
                self.scrollView.addSubview(activityView)
                
                if let type = activity["trackable_type"].string {
                    
                    self.type = type
                    
                    let verbLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 14))
                    verbLabel.textColor = UIColor.whiteColor()
                    verbLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                    
                    
                    if type == "Song" {
                        
                        verbLabel.text = "listened to"
                        
                        if let songID = activity["trackable_id"].int {
                            
                            let req = Router(OAuthToken: resnateToken, userID: String(songID))
                            
                            request(req.buildURLRequest("songs/", path: "")).responseJSON { (_, _, json, error) in
                                if json != nil {
                                    
                                    var song = JSON(json!)
                                    
                                    if let songID = song["id"].int {
                                        
                                        if let songName = song["name"].string {
                                            
                                            if let songContent = song["content"].string {
                                                
                                                self.ytID = songContent
                                                
                                                self.ytTitle = songName
                                                
                                                let likeSong = UIImageView(frame: CGRect(x: self.width/4 - 15, y: self.imgHeight + 120, width: 30, height: 30))
                                                
                                                likeSong.image = UIImage(named: "likeWhite")
                                                
                                                activityView.addSubview(likeSong)
                                                
                                                let shareSong = UIImageView(frame: CGRect(x: self.width/4 * 3 - 15, y: self.imgHeight + 120, width: 30, height: 30))
                                                
                                                shareSong.image = UIImage(named: "Share")
                                                
                                                activityView.addSubview(shareSong)
                                                
                                                let ytSong = [songName: songContent]
                                                
                                                let songNameLabel = UILabel(frame: CGRect(x: 80, y: 13.5, width: 240, height: 30))
                                                
                                                songNameLabel.text = songName
                                                songNameLabel.textColor = UIColor.whiteColor()
                                                songNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                                songNameLabel.numberOfLines = 2
                                                
                                                let tapVideo = UITapGestureRecognizer()
                                                
                                                tapVideo.addTarget(self, action: "playSingleSong")
                                                songNameLabel.tag = self.ID
                                                
                                                songNameLabel.addGestureRecognizer(tapVideo)
                                                
                                                songNameLabel.userInteractionEnabled = true
                                                
                                                activityView.addSubview(songNameLabel)
                                                
                                                
                                                let activitysongImg = UIImageView(frame: CGRect(x: 10, y: 70, width: self.imgWidth, height: self.imgHeight))
                                                
                                                let userImgUrl = NSURL(string: "https://img.youtube.com/vi/\(songContent)/hqdefault.jpg")
                                                
                                                self.getDataFromUrl(userImgUrl!) { data in
                                                    dispatch_async(dispatch_get_main_queue()) {
                                                        activitysongImg.image = UIImage(data: data!)
                                                        
                                                        let tapVideo = UITapGestureRecognizer()
                                                        
                                                        tapVideo.addTarget(self, action: "playSingleSong")
                                                        activitysongImg.tag = self.ID
                                                        
                                                        activitysongImg.addGestureRecognizer(tapVideo)
                                                        
                                                        activitysongImg.userInteractionEnabled = true
                                                        
                                                        activityView.addSubview(activitysongImg)
                                                        
                                                    }
                                                }
                                                
                                                
                                                
                                                if let listenerID = song["user_id"].int {
                                                    
                                                    let req = Router(OAuthToken: resnateToken, userID: String(listenerID))
                                                    
                                                    request(req.buildURLRequest("users/", path: "")).responseJSON { (_, _, json, error) in
                                                        if json != nil {
                                                            
                                                            var user = JSON(json!)
                                                            
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
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                            }
                            
                            
                        }
                        
                        
                    }
                    
                }
                
                
                let commentImgView = UIImageView(frame: CGRect(x: self.width/2 - 15, y: self.imgHeight + 120, width: 30, height: 30))
                
                commentImgView.image = UIImage(named: "comment")
                
                activityView.addSubview(commentImgView)
                
                let req = Router(OAuthToken: resnateToken, userID: String(activityID))
                
                request(req.buildURLRequest("activity/", path: "/comments/count")).responseJSON { (_, _, json, error) in
                    if json != nil {
                        
                        var counts = JSON(json!)
                        
                        if let commentsCount = counts["commentsCount"].int {
                            
                            if let likesCount = counts["likesCount"].int {
                                
                                let commentsAndLikesLabel = UILabel(frame: CGRect(x: 10, y: 80 + self.imgHeight, width: 300, height: 20))
                                
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
                                    
                                } else {
                                    
                                    commentsAndLikesLabel.text = "Like, comment or share!"
                                    
                                }
                                
                                commentsAndLikesLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                                
                                commentsAndLikesLabel.textColor = UIColor.whiteColor()
                                
                                activityView.addSubview(commentsAndLikesLabel)
                                
                            }
                            
                            
                            if commentsCount > 0 {
                                
                                request(req.buildURLRequest("activity/", path: "/comments/index")).responseJSON { (_, _, json, error) in
                                    if json != nil {
                                        
                                        var comments = JSON(json!)
                                        
                                        var y = 170
                                        
                                        for (index, comment) in comments {
                                            
                                            let commentView = UIView(frame: CGRect(x: 10, y: y  + self.imgHeight, width: self.width - 20, height: 50))
                                            
                                            commentView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
                                            
                                            activityView.addSubview(commentView)
                                            
                                            if let commenterID = comment["user_id"].int {
                                                
                                                let req = Router(OAuthToken: resnateToken, userID: String(commenterID))
                                                
                                                request(req.buildURLRequest("users/", path: "")).responseJSON { (_, _, json, error) in
                                                    if json != nil {
                                                        
                                                        var user = JSON(json!)
                                                        
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
                                                        
                                                        var dateFormatter = NSDateFormatter()
                                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                                                        
                                                        var timeDateString = dateFormatter.dateFromString(time)
                                                        
                                                        let timeLabel = UILabel(frame: CGRect(x: 60, y: 17, width: self.width - 40, height: 14))
                                                        
                                                        timeLabel.frame.origin.y = commentBodyLabel.frame.height + 27
                                                        
                                                        y += Int(commentView.frame.height) + 30
                                                        
                                                        timeLabel.textColor = UIColor.whiteColor()
                                                        
                                                        timeLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                                                        
                                                        timeLabel.text = timeAgoSinceDate(timeDateString!, true)
                                                        
                                                        commentView.addSubview(timeLabel)
                                                        
                                                    }
                                                    
                                                    
                                                    
                                                }
                                                
                                            }
                                            
                                            
                                        }
                                        
                                        self.scrollView.contentSize.height = CGFloat(self.imgHeight + y + 240)
                                        
                                    }
                                }
                                
                            }
                            
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
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.commentTextView.frame = CGRectMake(0, (self.view.bounds.height - keyboardHeight - 30), self.view.bounds.width - 50, 30)
            self.postComment.frame = CGRectMake(self.view.bounds.width - 50, (self.view.bounds.height - keyboardHeight - 30), 50, 30)
            }, completion: nil)

    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.commentTextView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 141, self.view.bounds.width - 50, 30)
        self.postComment.frame = CGRectMake(self.view.bounds.width - 50, UIScreen.mainScreen().bounds.height - 141, 50, 30)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if count(updatedText) == 0 {
            
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
        else if textView.textColor == UIColor.lightGrayColor() && count(text) > 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
            postComment.textColor = UIColor.whiteColor()
            postComment.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
        }
        
        let length = count(textView.text.utf16) + count(text.utf16) - range.length
        
        return length <= 5000
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
    }
    
    

    func playSingleSong(){
        
        self.view.endEditing(true)
        
        let ytPlayer = VideoPlayer.sharedInstance
        
        self.tabBarController?.view.addSubview(ytPlayer.videoPlayer)
        
        ytPlayer.playVid(self.ytID)
        
        ytPlayer.ytID = self.ytID
        
        ytPlayer.ytTitle = self.ytTitle
        
        ytPlayer.shareID = "\(self.ytID),\(self.ytTitle)"
        
    }
    
    func post(sender: AnyObject){
        
        if postComment.textColor == UIColor.whiteColor() {
            
            
            let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
            
            let resnateToken = dictionary!["token"] as! String
            
            let resnateID = dictionary!["userID"] as! String
            
            if (count(commentTextView.text!) <= 3000){
                
                let parameters =  ["body":"\(commentTextView.text)", "token": "\(resnateToken)"]
                
                
                
                let URL = NSURL(string: "https://www.resnate.com/api/activity/\(self.ID)/comments/create")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                mutableURLRequest.HTTPMethod = Method.POST.rawValue
                mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                
                request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { (_, _, JSON, error) in
                    if JSON != nil {
                        
                        println(JSON)
                        
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
