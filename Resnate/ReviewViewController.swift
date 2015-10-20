//
//  ReviewViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 13/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit
import TwitterKit


class ReviewViewController: UIViewController, UIAlertViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITextViewDelegate {
    
    var ID = 0
    
    var activityID = 0
    
    var ytID = ""
    
    var ytTitle = ""
    
    var rating = 0
    
    var ratingButtons = [UIButton]()
    
    var commentTextView = UITextView(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - 79, width: UIScreen.mainScreen().bounds.width, height: 30))
    
    var postComment = UILabel(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: UIScreen.mainScreen().bounds.height - 79, width: 50, height: 30))
    
    func loadReviewNComments(){
        
        let reviewID = String(ID)
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: reviewID)
        
        request(req.buildURLRequest("reviews/", path: "")).responseJSON { response in
                
                let width = UIScreen.mainScreen().bounds.width
                
                let review = JSON(response.result.value!)
                
                let reviewView = self.reviewView
                
                let userID = review["user_id"].int!
                
                
                let navHeight = self.navigationController?.navigationBar.frame.height
                let reviewTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: navHeight!))
                reviewTitle.textAlignment = .Center
                reviewTitle.textColor = UIColor.whiteColor()
                reviewTitle.font = UIFont(name: "Helvetica Neue", size: 12)!
                reviewTitle.numberOfLines = 3
                
                
                let b = UIBarButtonItem(title: "", style: .Plain, target: self, action: "shareReview:")
                b.image = UIImage(named: "Share")!.imageWithRenderingMode(.AlwaysOriginal)
                b.tag = self.ID
                self.navigationItem.rightBarButtonItem = b
                
                let songOrSetlistLabel = UILabel(frame: CGRect(x: 5, y: 0, width: 100, height: 40))
                songOrSetlistLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                songOrSetlistLabel.textColor = UIColor.whiteColor()
                songOrSetlistLabel.textAlignment = .Center
                songOrSetlistLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                let tapSongOrSetlist = UITapGestureRecognizer()
                songOrSetlistLabel.addGestureRecognizer(tapSongOrSetlist)
                songOrSetlistLabel.userInteractionEnabled = true
                reviewView.addSubview(songOrSetlistLabel)
                
                
                if review["reviewable_type"] == "PastGig" {
                    
                    let pastGigID = String(stringInterpolationSegment: review["reviewable_id"])
                    
                    
                    let req = Router(OAuthToken: resnateToken, userID: pastGigID)
                    
                    
                    request(req.buildURLRequest("past_gigs/", path: "")).responseJSON { response in
                            
                            
                            let pastGig = JSON(response.result.value!)
                            
                            if let skID = pastGig["songkick_id"].int {
                                
                                songOrSetlistLabel.tag = skID
                                songOrSetlistLabel.text = "Setlist"
                                tapSongOrSetlist.addTarget(self, action: "toSetlist:")
                                
                                let artistLink = "https://api.songkick.com/api/3.0/events/" + String(skID) + ".json?apikey=Pxms4Lvfx5rcDIuR"
                                
                                request(.GET, artistLink).responseJSON { response in
                                        
                                        var json = JSON(response.result.value!)
                                        if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                            
                                            let artistView = getHugeArtistPic(artist)
                                            artistView.frame = CGRect(x: 0, y: 0, width: width, height: width)
                                            reviewView.addSubview(artistView)
                                        }
                                        
                                        if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                            
                                            reviewTitle.text = gigName
                                            self.navigationItem.titleView = reviewTitle
                                            
                                        }
                                }
                            }
                    }
                    
                } else if review["reviewable_type"] == "Song" {
                    
                    
                    let songID = String(stringInterpolationSegment: review["reviewable_id"])
                    
                    
                    let req = Router(OAuthToken: resnateToken, userID: songID)
                    
                    request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
                            
                            let song = JSON(response.result.value!)
                            
                            if let ytID = song["content"].string {
                                
                                let ytLink = "https://img.youtube.com/vi/" + ytID + "/hqdefault.jpg"
                                
                                let songImgUrl = NSURL(string: ytLink)
                                let reviewSongImg = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width/1.33))
                                self.getDataFromUrl(songImgUrl!) { data in
                                    dispatch_async(dispatch_get_main_queue()) {
                                        
                                        reviewSongImg.image = UIImage(data: data!)
                                        
                                        
                                        
                                    }
                                }
                                reviewView.addSubview(reviewSongImg)
                                
                                if let ytName = song["name"].string {
                                    
                                    self.ytID = ytID
                                    
                                    self.ytTitle = ytName
                                    
                                    songOrSetlistLabel.text = "Play"
                                    tapSongOrSetlist.addTarget(self, action: "playSingleSong")
                                    reviewTitle.text = ytName
                                    self.navigationItem.titleView = reviewTitle
                                    
                                }
                                
                            }
                    }
                    
                }
                
                
                
                
                
                if let content = review["content"].string {
                    
                    
                    
                    let reviewContent = UILabel(frame: CGRect(x: 0, y: 0, width: width - 20, height: CGFloat.max))
                    
                    reviewContent.lineBreakMode = .ByWordWrapping
                    reviewContent.numberOfLines = 0
                    
                    reviewContent.text = content
                    
                    reviewContent.font = UIFont(name: "HelveticaNeue-Light", size: 16)
                    
                    reviewContent.sizeToFit()
                    
                    var frame = reviewContent.frame
                    
                    songOrSetlistLabel.frame.origin.y = reviewContent.frame.height + width + 90
                    
                    
                    if review["reviewable_type"] == "PastGig" {
                        
                        frame.origin = CGPointMake(10, width + 5)
                        
                    } else {
                        
                        frame.origin = CGPointMake(10, width/1.33 + 5)
                        
                    }
                    
                    
                    
                    
                    reviewContent.frame = frame
                    
                    
                    reviewView.addSubview(reviewContent)
                    
                    if Int(resnateID) == userID {
                        let editLabel = UILabel(frame: CGRect(x: width/2 - 50, y: reviewContent.frame.height + width + 90, width: 100, height: 40))
                        
                        editLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                        editLabel.text = "Edit"
                        editLabel.textColor = UIColor.whiteColor()
                        editLabel.textAlignment = .Center
                        editLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                        let tapRecEdit = UITapGestureRecognizer()
                        
                        
                        tapRecEdit.addTarget(self, action: "editReview:")
                        editLabel.addGestureRecognizer(tapRecEdit)
                        editLabel.tag = review["id"].int!
                        
                        editLabel.userInteractionEnabled = true
                        
                        
                        reviewView.addSubview(editLabel)
                        
                        
                        let deleteLabel = UILabel(frame: CGRect(x: width - 105, y: reviewContent.frame.height + width + 90, width: 100, height: 40))
                        
                        deleteLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                        
                        deleteLabel.text = "Delete"
                        deleteLabel.textColor = UIColor.whiteColor()
                        deleteLabel.textAlignment = .Center
                        deleteLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                        let tapRecDelete = UITapGestureRecognizer()
                        
                        
                        tapRecDelete.addTarget(self, action: "deleteReview:")
                        deleteLabel.addGestureRecognizer(tapRecDelete)
                        deleteLabel.tag = review["id"].int!
                        
                        deleteLabel.userInteractionEnabled = true
                        
                        
                        reviewView.addSubview(deleteLabel)
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    let ratingView = UIView(frame: CGRect(x: 5, y: reviewContent.frame.height + width + 30, width: 300, height: 50))
                    
                    
                    
                    let filledStarImage = UIImage(named: "filledStar")
                    let emptyStarImage = UIImage(named: "emptyStar")
                    
                    var x = 0
                    
                    self.ratingButtons.removeAll(keepCapacity: true)
                    
                    for _ in 0..<5 {
                        
                        let button = UIButton(frame: CGRect(x: x, y: 0, width: 44, height: 44))
                        
                        
                        button.setImage(emptyStarImage, forState: .Normal)
                        button.setImage(filledStarImage, forState: .Selected)
                        button.setImage(filledStarImage, forState: [.Highlighted, .Selected])
                        
                        button.adjustsImageWhenHighlighted = false
                        
                        self.ratingButtons += [button]
                        
                        if let rating = review["rating"].int {
                            
                            self.rating = rating
                            
                            ratingView.addSubview(button)
                            
                            for (index, button) in self.ratingButtons.enumerate() {
                                
                                if index < self.rating {
                                    
                                    button.selected = true
                                    
                                    
                                }
                                
                            }
                            
                            if Int(resnateID) == userID {
                                
                                button.addTarget(self, action: "ratingButtonTapped:", forControlEvents: .TouchDown)
                                
                                ratingView.addSubview(button)
                                
                                
                            }
                            
                        } else {
                            
                            if Int(resnateID) == userID {
                                
                                button.addTarget(self, action: "ratingButtonTapped:", forControlEvents: .TouchDown)
                                
                                ratingView.addSubview(button)
                                
                                
                            }
                            
                        }
                        
                        
                        
                        
                        
                        x += 50
                    }
                    
                    let shareImgSize = CGSize(width: 40, height: 40)
                    
                    let shareView = UIView(frame: CGRect(x: 0, y: reviewContent.frame.height + width + 190, width: width, height: 40))
                    
                    let resnateShare = UIImageView(image: UIImage(named: "Share"))
                    resnateShare.frame.size = shareImgSize
                    
                    shareView.addSubview(resnateShare)
                    
                    let tapRecShare = UITapGestureRecognizer()
                    
                    tapRecShare.addTarget(self, action: "shareReview:")
                    resnateShare.tag = Int(reviewID)!
                    resnateShare.addGestureRecognizer(tapRecShare)
                    resnateShare.userInteractionEnabled = true
                    
                    
                    let fbShare = UIImageView(image: UIImage(named: "facebook.jpg"))
                    fbShare.frame.size = shareImgSize
                    
                    shareView.addSubview(fbShare)
                    
                    
                    
                    let tapRecFb = UITapGestureRecognizer()
                    
                    tapRecFb.addTarget(self, action: "fbReview:")
                    fbShare.tag = Int(reviewID)!
                    fbShare.addGestureRecognizer(tapRecFb)
                    fbShare.userInteractionEnabled = true
                    
                    let twitShare = UIImageView(image: UIImage(named: "twitter"))
                    twitShare.frame.size = shareImgSize
                    
                    shareView.addSubview(twitShare)
                    
                    let tapRecTwit = UITapGestureRecognizer()
                    
                    tapRecTwit.addTarget(self, action: "twitter:")
                    twitShare.tag = Int(reviewID)!
                    twitShare.addGestureRecognizer(tapRecTwit)
                    twitShare.userInteractionEnabled = true
                    
                    reviewView.addSubview(shareView)
                    
                    reviewView.addSubview(ratingView)
                    
                    if resnateID == String(userID) {
                        
                        fbShare.frame.origin.x = width/6 - 20
                        resnateShare.frame.origin.x = reviewView.center.x - 20
                        twitShare.frame.origin.x = (width/6)*5 - 20
                        
                    } else {
                        
                        let likeReview = UIImageView(image: UIImage(named: "like"))
                        
                        likeReview.frame.size = shareImgSize
                        
                        shareView.addSubview(likeReview)
                        
                        likeReview.frame.origin.x = width/8 - 20
                        fbShare.frame.origin.x = (width/8) * 3 - 20
                        resnateShare.frame.origin.x = (width/8)*5 - 20
                        twitShare.frame.origin.x = (width/8)*7 - 20
                        
                    }
                    
                    
                    let reviewCommentsView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 0))
                    
                    let activityReq = Router(OAuthToken: resnateToken, userID: reviewID)
                    
                    request(activityReq.buildURLRequest("Review/", path: "/findActivityComments")).responseJSON { response in
                        
                            let comments = JSON(response.result.value!)
                            
                            let req = Router(OAuthToken: resnateToken, userID: String(reviewID))
                            
                            request(req.buildURLRequest("reviews/", path: "/likes")).responseJSON { response in
                                
                                    let users = JSON(response.result.value!)
                                    let userCount = users.count
                                    
                                    let userCountLabel = UILabel(frame: CGRect(x: 10, y: reviewContent.frame.height + width + 140, width: 0, height: 40))
                                    
                                    if userCount == 1 {
                                        userCountLabel.text = "1 like"
                                    } else if userCount > 1 {
                                        userCountLabel.text = "\(userCount) likes"
                                    }
                                    
                                    userCountLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                                    
                                    userCountLabel.sizeToFit()
                                    
                                    reviewView.addSubview(userCountLabel)
                                    
                                    let commentsCountLabel = UILabel(frame: CGRect(x: userCountLabel.frame.width + 10, y: reviewContent.frame.height + width + 140, width: 0, height: 40))
                                    
                                    if comments.count == 1 {
                                        
                                        commentsCountLabel.text = "\(comments.count) comment"
                                        
                                    } else if comments.count > 1 {
                                        
                                        commentsCountLabel.text = "\(comments.count) comments"
                                        
                                    }
                                    
                                    commentsCountLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                                    
                                    commentsCountLabel.sizeToFit()
                                    
                                    reviewView.addSubview(commentsCountLabel)
                                    
                                }
                            
                            
                            var y = 0
                            
                            
                            
                            for (_, comment) in comments {
                                
                                let commentView = UIView(frame: CGRect(x: 0, y: y, width: Int(width), height: 50))
                                
                                commentView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
                                
                                
                                
                                if let commenterID = comment["user_id"].int {
                                    
                                    let req = Router(OAuthToken: resnateToken, userID: String(commenterID))
                                    
                                    request(req.buildURLRequest("users/", path: "")).responseJSON { response in
                                            
                                            var user = JSON(response.result.value!)
                                            
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
                                    
                                    
                                    if let body = comment["body"].string {
                                        
                                        let commentBodyLabel = UILabel(frame: CGRect(x: 60, y: 17, width: width - 40, height: 34))
                                        
                                        commentBodyLabel.text = body.stringByReplacingOccurrencesOfString("%0A", withString: "\n")
                                        
                                        commentBodyLabel.lineBreakMode = .ByTruncatingTail
                                        commentBodyLabel.numberOfLines = 0
                                        
                                        commentBodyLabel.sizeToFit()
                                        
                                        
                                        
                                        commentBodyLabel.textColor = UIColor.whiteColor()
                                        
                                        commentBodyLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                                        
                                        commentView.addSubview(commentBodyLabel)
                                        
                                        if let time = comment["updated_at"].string {
                                            
                                            let dateFormatter = NSDateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                                            
                                            let timeDateString = dateFormatter.dateFromString(time)
                                            
                                            let timeLabel = UILabel(frame: CGRect(x: 60, y: 17, width: width - 40, height: 14))
                                            
                                            timeLabel.frame.origin.y = commentBodyLabel.frame.height + 27
                                            
                                            y += Int(commentView.frame.height) + 30
                                            
                                            timeLabel.textColor = UIColor.whiteColor()
                                            
                                            timeLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                                            
                                            timeLabel.text = timeAgoSinceDate(timeDateString!, numericDates: true)
                                            
                                            commentView.addSubview(timeLabel)
                                            
                                            commentView.frame.size.height = timeLabel.frame.height + timeLabel.frame.origin.y + 10
                                            
                                            reviewCommentsView.addSubview(commentView)
                                            
                                            reviewCommentsView.frame.size.height = commentView.frame.height + commentView.frame.origin.y + 10
                                            
                                        }
                                        
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                            var commentsFrame = reviewCommentsView.frame
                            
                            commentsFrame.origin = CGPointMake(0, shareView.frame.origin.y + shareView.frame.height + 20)
                            
                            
                            
                            reviewCommentsView.frame = commentsFrame
                            
                            reviewView.addSubview(reviewCommentsView)
                            
                            reviewView.contentSize.height = reviewCommentsView.frame.height + reviewCommentsView.frame.origin.y + 50
                        
                        
                    }
                    
                    
                    
                    
                }

        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if self.view.frame.origin.y != 0 {
            
            commentTextView.frame.origin.y = UIScreen.mainScreen().bounds.height - 143
            postComment.frame.origin.y = UIScreen.mainScreen().bounds.height - 143
            
        }
        
        loadReviewNComments()
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        postComment.layer.zPosition = 9999
        
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
        
        let reviewID = String(ID)
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let findActivityReq = Router(OAuthToken: resnateToken, userID: reviewID)
        
        request(findActivityReq.buildURLRequest("Review/", path: "/findActivity")).responseJSON { response in
                
                var activity = JSON(response.result.value!)
                
                if let activityID = activity["id"].int {
                    
                    self.activityID = activityID
                    
                }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var reviewView: UIScrollView!
    
    
    func ratingButtonTapped(button: UIButton) {
        self.rating = self.ratingButtons.indexOf(button)! + 1
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["token": "\(resnateToken)", "rating":"\(self.rating)"]
        
            let URL = NSURL(string: "https://www.resnate.com/api/reviews/\(String(ID))/updateRating")!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
            mutableURLRequest.HTTPMethod = Method.PUT.rawValue
            mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
            }
        
        for (index, button) in self.ratingButtons.enumerate() {
            // If the index of a button is less than the rating, that button shouldn't be selected.
            button.selected = index < self.rating
        }
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
        
        if self.view.frame.origin.y != 0 {
            
            self.commentTextView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 143, self.view.bounds.width - 50, 30)
            self.postComment.frame = CGRectMake(self.view.bounds.width - 50, UIScreen.mainScreen().bounds.height - 143, 50, 30)
            
        } else {
            
            self.commentTextView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 79, self.view.bounds.width - 50, 30)
            self.postComment.frame = CGRectMake(self.view.bounds.width - 50, UIScreen.mainScreen().bounds.height - 79, 50, 30)
            
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

    func post(sender: AnyObject){
        
        if postComment.textColor == UIColor.whiteColor() {
            
            
            let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
            
            let resnateToken = dictionary!["token"] as! String
            
            if ((commentTextView.text!).characters.count <= 3000){
                
                let parameters =  ["body":"\(commentTextView.text)", "token": "\(resnateToken)"]
                
                
                
                let URL = NSURL(string: "https://www.resnate.com/api/activity/\(self.activityID)/comments/create")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                mutableURLRequest.HTTPMethod = Method.POST.rawValue
                mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                
                request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in

                        
                        self.loadReviewNComments()
                        
                        let delay = 1.5 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            let bottomOffset = CGPointMake(0, self.reviewView.contentSize.height - self.reviewView.bounds.size.height + 50)
                            self.reviewView.setContentOffset(bottomOffset, animated: true)
                        }
                }
            }
            
            
            commentTextView.text = "Write a comment..."
            commentTextView.textColor = UIColor.lightGrayColor()
            commentTextView.selectedTextRange = commentTextView.textRangeFromPosition(commentTextView.beginningOfDocument, toPosition: commentTextView.beginningOfDocument)
            postComment.textColor = UIColor.lightGrayColor()
            postComment.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
            
            self.view.endEditing(true)
            
        } else {
            
            self.view.endEditing(true)
            
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

}
