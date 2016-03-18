//
//  Review.swift
//  Resnate
//
//  Created by Amir Moosavi on 11/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    
    func profile(sender: AnyObject) {
        
            
            let scrollProfileViewController:ScrollProfileViewController = ScrollProfileViewController(nibName: "ScrollProfileViewController", bundle: nil)
            
            scrollProfileViewController.ID = sender.view!.tag
            
            
            self.navigationController?.pushViewController(scrollProfileViewController, animated: true)
            
            
    
    }
    
    func followers(sender: UITapGestureRecognizer) {
        
        
        let followViewController:FollowViewController = FollowViewController(nibName: "FollowViewController", bundle: nil)
        
        followViewController.ID = sender.view!.tag
        
        followViewController.type = "followers"
        
        self.navigationController?.pushViewController(followViewController, animated: true)
        
        
        
        
    }
    
    func followees(sender: UITapGestureRecognizer) {
        
        
        let followViewController:FollowViewController = FollowViewController(nibName: "FollowViewController", bundle: nil)
        
        followViewController.ID = sender.view!.tag
        
        followViewController.type = "followees"
        
        self.navigationController?.pushViewController(followViewController, animated: true)
        
        
        
        
    }
    
    
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: NSData(data: data!))
            }.resume()
    }
    
    
    
    
    
func toReview(sender:AnyObject) {
    
    let reviewViewController:ReviewViewController = ReviewViewController(nibName: "ReviewViewController", bundle: nil)
    
    
    
    reviewViewController.ID = sender.view!.tag
    
    
    self.navigationController?.pushViewController(reviewViewController, animated: true)
    
    
    
    
}
    
    func toSetlist(sender: AnyObject) {
        
        let setlistViewController:SetlistViewController = SetlistViewController(nibName: "SetlistViewController", bundle: nil)
        
        setlistViewController.ID = sender.view!.tag
        
        self.navigationController?.pushViewController(setlistViewController, animated: true)
        
    }
    
    
    
    
    func writeGigReview(sender:UITapGestureRecognizer){
        
        
        
        let writeReviewViewController:WriteReviewViewController = WriteReviewViewController(nibName: "WriteReviewViewController", bundle: nil)
        
        writeReviewViewController.ID = sender.view!.tag
        
        writeReviewViewController.type = "PastGig"
        
        
        self.navigationController?.pushViewController(writeReviewViewController, animated: true)
        
    }
    
    func writeSongReview(sender:UITapGestureRecognizer){
        
        
        
        let writeReviewViewController:WriteReviewViewController = WriteReviewViewController(nibName: "WriteReviewViewController", bundle: nil)
        
        writeReviewViewController.ID = sender.view!.tag
        
        writeReviewViewController.type = "Song"
        
        
        self.presentViewController(writeReviewViewController, animated: true, completion: nil)
        
    }
    
    func deleteReview(sender:UITapGestureRecognizer){
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["token": "\(resnateToken)"]
        
        
        if UIApplication.sharedApplication().respondsToSelector(Selector("registerUserNotificationSettings:")) {
            
                let deleteAlert = UIAlertController(title: "Delete Review", message: "Are you sure you want to delete this review?", preferredStyle: UIAlertControllerStyle.Alert)
                
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction) in
                    
                    let URL = NSURL(string: "https://www.resnate.com/api/reviews/\(String(sender.view!.tag))")!
                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                    mutableURLRequest.HTTPMethod = Method.DELETE.rawValue
                    mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                    
                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                            self.navigationController?.popViewControllerAnimated(true)
                            
                            let window = UIApplication.sharedApplication().keyWindow
                            
                            if window!.rootViewController as? UITabBarController != nil {
                                let tababarController = window!.rootViewController as! UITabBarController
                                tababarController.selectedIndex = 0
                            }
                    }
                    
                    
                }))
                
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
                
                presentViewController(deleteAlert, animated: true, completion: nil)
            
            
        }
        
    }
    
    func editReview(sender:UITapGestureRecognizer){
        
        let writeReviewViewController:WriteReviewViewController = WriteReviewViewController(nibName: "WriteReviewViewController", bundle: nil)
        
        writeReviewViewController.ID = sender.view!.tag
        
        writeReviewViewController.type = "Review"
        
        
        self.navigationController?.pushViewController(writeReviewViewController, animated: true)
    }
    
    func loadGig(sender: AnyObject){
        let webViewController:WebViewController = WebViewController(nibName: "WebViewController", bundle: nil)
        
        webViewController.webURL = "https://www.songkick.com/concerts/\(sender.view!.tag)"
        
        self.presentViewController(webViewController, animated: true, completion: nil)
    }
    
    
}

//
//  ReviewViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 13/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

/*import UIKit
import TwitterKit


class ReviewViewController: UIViewController, UIAlertViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    let window = UIApplication.sharedApplication().keyWindow
    
    var ID = 0
    
    var activityID = 0
    
    var ytID = ""
    
    var ytTitle = ""
    
    var rating = 0
    
    var ratingButtons = [UIButton]()
    
    var commentTextView = UITextView(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - 79, width: UIScreen.mainScreen().bounds.width, height: 30))
    
    var postComment = UILabel(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: UIScreen.mainScreen().bounds.height - 79, width: 50, height: 30))
    
    let imgWidth = Int(UIScreen.mainScreen().bounds.width) - 20
    
    let imgHeight = Int(Double(UIScreen.mainScreen().bounds.width - 20) / 1.33)
    
    var reviewContentHeight: CGFloat = 0
    
    let width = UIScreen.mainScreen().bounds.width
    
    var resnateID = ""
    
    var resnateToken = ""
    
    var reviewContent: UILabel!
    
    var layoutManager = NSLayoutManager()
    var textContainer: NSTextContainer!
    var textStorage: NSTextStorage!
    
    var videoLocation = [Int: String]()
    
    var reviewSongs = [String: String]()
    
    var locations: [Int] = []
    
    let ytPlayer = VideoPlayer.sharedInstance
    
    let tapLike = UITapGestureRecognizer()
    
    func loadComments(reviewContent: UILabel, userID: Int, reviewID: String, review: JSON, songOrSetlistLabel: UILabel){
        
        if Int(self.resnateID) == userID {
            let editLabel = UILabel(frame: CGRect(x: self.width/2 - 50, y: self.reviewContentHeight + self.width + 210, width: 100, height: 40))
            
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
            
            
            let deleteLabel = UILabel(frame: CGRect(x: self.width - 105, y: self.reviewContentHeight + self.width + 210, width: 100, height: 40))
            
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
        
        songOrSetlistLabel.frame.origin.y = self.reviewContentHeight + self.width + 210
        
        let ratingView = UIView(frame: CGRect(x: 5, y: self.reviewContentHeight + width + 20, width: 300, height: 50))
        
        
        
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
        
        
        let reviewerInfo = UIView(frame: CGRect(x: 0, y: self.reviewContentHeight + width + 90, width: width, height: 50))
        reviewerInfo.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        let req = Router(OAuthToken: self.resnateToken, userID: String(userID))
        request(req.buildURLRequest("users/", path: "/profile")).responseJSON { response in
            
            var user = JSON(response.result.value!)
            
            if let userName = user["name"].string {
                
                if let userImageID = user["userID"].string {
                    
                    if let userID = user["id"].string {
                        
                        let userNameLabel = UILabel(frame: CGRect(x: 60, y: 3, width: 240, height: 50))
                        let levelName = user["level_name"].string!
                        userNameLabel.text = "Review by \n\(userName)"
                        
                        let miniBadge = UIImageView(frame: CGRect(x: self.width - 55, y: 2.5, width: 45, height: 45))
                        miniBadge.image = UIImage(named: "\(levelName).png")
                        reviewerInfo.addSubview(miniBadge)
                        
                        userNameLabel.numberOfLines = 3
                        userNameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
                        userNameLabel.textColor = UIColor.whiteColor()
                        userNameLabel.sizeToFit()
                        
                        
                        let tapRecProfile = UITapGestureRecognizer()
                        tapRecProfile.addTarget(self, action: "profile:")
                        
                        reviewerInfo.tag = Int(userID)!
                        reviewerInfo.addGestureRecognizer(tapRecProfile)
                        reviewerInfo.userInteractionEnabled = true
                        
                        reviewerInfo.addSubview(userNameLabel)
                        
                        let activityUserImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                        
                        let userImgUrl = NSURL(string: "https://graph.facebook.com/\(userImageID)/picture?width=100&height=100")
                        
                        self.getDataFromUrl(userImgUrl!) { data in
                            dispatch_async(dispatch_get_main_queue()) {
                                activityUserImg.image = UIImage(data: data!)
                                
                                reviewerInfo.addSubview(activityUserImg)
                                
                            }
                        }
                        
                        
                    }
                    
                }
                
            }
        }
        reviewView.addSubview(reviewerInfo)
        
        let shareImgSize = CGSize(width: 40, height: 40)
        
        let shareView = UIView(frame: CGRect(x: 0, y: self.reviewContentHeight + width + 280, width: width, height: 40))
        
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
            
            let req = Router(OAuthToken: resnateToken, userID: resnateID)
            
            let likeReview = UIImageView(image: UIImage(named: "like"))
            
            likeReview.tag = Int(reviewID)!
            
            
            likeReview.addGestureRecognizer(tapLike)
            likeReview.userInteractionEnabled = true
            
            request(req.buildURLRequest("likes/ifLike/Review/", path: "/\(reviewID)")).responseJSON { response in
                if let re = response.result.value {
                    
                    let json = JSON(re)
                    
                    if let count = json["count"].int {
                        
                        if count > 0 {
                            likeReview.image = UIImage(named: "liked")
                            self.tapLike.removeTarget(self, action: "likeReview:")
                            self.tapLike.addTarget(self, action: "unlikeReview:")
                        } else {
                            self.tapLike.addTarget(self, action: "likeReview:")
                        }
                        
                    }
                }
            }
            
            
            
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
            
            let req = Router(OAuthToken: self.resnateToken, userID: String(reviewID))
            
            request(req.buildURLRequest("reviews/", path: "/likes")).responseJSON { response in
                
                let users = JSON(response.result.value!)
                let userCount = users.count
                
                let userCountLabel = UILabel(frame: CGRect(x: 10, y: reviewContent.frame.height + self.width + 150, width: 0, height: 40))
                
                if userCount == 1 {
                    userCountLabel.text = "1 like"
                } else if userCount > 1 {
                    userCountLabel.text = "\(userCount) likes"
                }
                
                userCountLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
                
                userCountLabel.sizeToFit()
                
                self.reviewView.addSubview(userCountLabel)
                
                let commentsCountLabel = UILabel(frame: CGRect(x: userCountLabel.frame.width + 20, y: reviewContent.frame.height + self.width + 150, width: 0, height: 40))
                
                if comments.count == 1 {
                    
                    commentsCountLabel.text = "\(comments.count) comment"
                    
                } else if comments.count > 1 {
                    
                    commentsCountLabel.text = "\(comments.count) comments"
                    
                }
                
                commentsCountLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
                
                commentsCountLabel.sizeToFit()
                
                self.reviewView.addSubview(commentsCountLabel)
                
            }
            
            
            var y = 0
            
            
            
            for (_, comment) in comments {
                
                let commentView = UIView(frame: CGRect(x: 0, y: y, width: Int(self.width), height: 50))
                
                commentView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
                
                
                
                if let commenterID = comment["user_id"].int {
                    
                    let req = Router(OAuthToken: self.resnateToken, userID: String(commenterID))
                    
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
                        
                        let commentBodyLabel = UILabel(frame: CGRect(x: 60, y: 17, width: self.width - 40, height: 34))
                        
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
                            
                            let timeLabel = UILabel(frame: CGRect(x: 60, y: 17, width: self.width - 40, height: 14))
                            
                            timeLabel.frame.origin.y = commentBodyLabel.frame.height + 27
                            
                            timeLabel.textColor = UIColor.whiteColor()
                            
                            timeLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                            
                            timeLabel.text = timeAgoSinceDate(timeDateString!, numericDates: true)
                            
                            commentView.addSubview(timeLabel)
                            
                            commentView.frame.size.height = timeLabel.frame.height + timeLabel.frame.origin.y + 10
                            
                            y += Int(commentView.frame.height) + 30
                            
                            reviewCommentsView.addSubview(commentView)
                            
                            reviewCommentsView.frame.size.height = commentView.frame.height + commentView.frame.origin.y + 10
                            
                        }
                        
                        
                        
                    }
                    
                }
                
            }
            var commentsFrame = reviewCommentsView.frame
            
            commentsFrame.origin = CGPointMake(0, shareView.frame.origin.y + shareView.frame.height + 20)
            
            
            
            reviewCommentsView.frame = commentsFrame
            
            self.reviewView.addSubview(reviewCommentsView)
            
            self.reviewView.contentSize.height = reviewCommentsView.frame.height + reviewCommentsView.frame.origin.y + 50
            
            
        }
        
    }
    
    func loadReviewNComments(){
        
        let reviewID = String(ID)
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        self.resnateToken = dictionary!["token"] as! String
        
        self.resnateID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: reviewID)
        
        request(req.buildURLRequest("reviews/", path: "")).responseJSON { response in
            
            
            
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
                
                
                let req = Router(OAuthToken: self.resnateToken, userID: pastGigID)
                
                
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
                                artistView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.width)
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
                
                
                let req = Router(OAuthToken: self.resnateToken, userID: songID)
                
                request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
                    
                    let song = JSON(response.result.value!)
                    
                    if let ytID = song["content"].string {
                        
                        let ytLink = "https://img.youtube.com/vi/" + ytID + "/hqdefault.jpg"
                        
                        let songImgUrl = NSURL(string: ytLink)
                        let reviewSongImg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.width/1.33))
                        self.getDataFromUrl(songImgUrl!) { data in
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                reviewSongImg.image = UIImage(data: data!)
                                reviewSongImg.tag = Int(songID)!
                                let tapReviewImg = UITapGestureRecognizer()
                                reviewSongImg.addGestureRecognizer(tapReviewImg)
                                reviewSongImg.userInteractionEnabled = true
                                tapReviewImg.addTarget(self, action: "playSingleSong:")
                                
                            }
                        }
                        reviewView.addSubview(reviewSongImg)
                        
                        if let ytName = song["name"].string {
                            
                            self.ytID = ytID
                            
                            self.ytTitle = ytName
                            
                            songOrSetlistLabel.text = "Play"
                            tapSongOrSetlist.addTarget(self, action: "playSingleSong:")
                            songOrSetlistLabel.tag = Int(songID)!
                            reviewTitle.text = ytName
                            self.navigationItem.titleView = reviewTitle
                            
                        }
                        
                    }
                }
                
            }
            
            
            
            
            
            if let content = review["content"].string {
                
                
                
                self.reviewContent = UILabel(frame: CGRect(x: 0, y: 0, width: self.width - 20, height: CGFloat.max))
                
                self.reviewContent.lineBreakMode = .ByWordWrapping
                self.reviewContent.numberOfLines = 0
                
                self.reviewContent.text = content
                
                self.reviewContent.font = UIFont(name: "HelveticaNeue-Light", size: 16)
                
                
                
                self.reviewContent.sizeToFit()
                
                var frame = self.reviewContent.frame
                
                
                
                
                if review["reviewable_type"] == "PastGig" {
                    
                    frame.origin = CGPointMake(10, self.width + 5)
                    
                } else {
                    
                    frame.origin = CGPointMake(10, self.width/1.33 + 5)
                    songOrSetlistLabel.frame.origin.y = self.reviewContent.frame.height + self.width + 210
                    
                }
                
                
                let youTubeURLs = self.matchesForRegexInText("(?:https?:\\/\\/)?(?:www\\.)?(?:youtube.com.+v[=/]|youtu.be/)([-a-zA-Z0-9_]+)", text: self.reviewContent.text)
                
                let imgurURLs = self.matchesForRegexInText("(?:https?:\\/\\/)?(?:www\\.)?(?:i\\.imgur\\.com\\/|imgur\\.com\\/)([-a-zA-Z0-9_]+)?(?:\\.(gif|jpg|png)|)", text: self.reviewContent.text)
                
                var i = 0
                
                var j = 0
                
                if youTubeURLs.count >= 1 {
                    
                    self.reviewContent.frame = frame
                    
                    for youTubeURL in youTubeURLs {
                        
                        let youTubeID = youTubeURL.componentsSeparatedByString("v=")[1]
                        
                        let reviewImgUrl = NSURL(string: "https://img.youtube.com/vi/\(youTubeID)/hqdefault.jpg")
                        
                        let titleSearch = "https://www.googleapis.com/youtube/v3/videos?id=\(youTubeID)&key=AIzaSyCa2qY9zSZWCKyX6HftBDvSSszkjJQSd8Y&part=snippet"
                        
                        request(.GET, titleSearch).responseJSON { response in
                            let results = JSON(response.result.value!)
                            
                            if let items = results["items"].array {
                                for item in items {
                                    if let item = item.dictionary {
                                        if let snippet = item["snippet"]!.dictionary {
                                            if let songTitle = snippet["title"]!.string {
                                                
                                                self.reviewSongs[youTubeID] = songTitle
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        self.getDataFromUrl(reviewImgUrl!) { data in
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                self.addEmbeddedURL(data!, type: "YouTube", imgURL: youTubeURL, imgID: youTubeID)
                                
                                i += 1
                                
                                
                                if i == youTubeURLs.count && j == imgurURLs.count {
                                    
                                    self.loadComments(self.reviewContent, userID: userID, reviewID: reviewID, review: review, songOrSetlistLabel: songOrSetlistLabel)
                                    
                                }
                                
                                
                                
                            }
                        }
                        
                        
                    }
                    
                    for imgurURL in imgurURLs {
                        
                        var imgurID = imgurURL.componentsSeparatedByString(".com/")[1]
                        let index = imgurID.startIndex.advancedBy(7)
                        imgurID = imgurID.substringWithRange(Range<String.Index>(start: imgurID.startIndex, end: index))
                        let reviewImgUrl = NSURL(string: "http://i.imgur.com/\(imgurID).png")
                        
                        self.getDataFromUrl(reviewImgUrl!) { data in
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                self.addEmbeddedURL(data!, type: "Imgur", imgURL: imgurURL, imgID: imgurID)
                                
                                j += 1
                                
                                if i == youTubeURLs.count && j == imgurURLs.count {
                                    
                                    self.loadComments(self.reviewContent, userID: userID, reviewID: reviewID, review: review, songOrSetlistLabel: songOrSetlistLabel)
                                    
                                }
                                
                                
                                
                            }
                        }
                        
                        
                    }
                    
                } else {
                    
                    self.reviewContent.frame = frame
                    self.reviewContentHeight = self.reviewContent.frame.height
                    self.loadComments(self.reviewContent, userID: userID, reviewID: reviewID, review: review, songOrSetlistLabel: songOrSetlistLabel)
                    
                }
                
                
                
                
                
                reviewView.addSubview(self.reviewContent)
                
                
                
            }
            
        }
        
    }
    
    func addEmbeddedURL(data: NSData, type: String, imgURL: String, imgID: String) {
        let attributedString = NSMutableAttributedString(attributedString: self.reviewContent.attributedText!)
        let textAttachment = NSTextAttachment()
        let embeddedImage = UIImage(data: data)
        
        if type == "YouTube" {
            
            let playButton = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            playButton.image = UIImage(named: "play")
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: self.reviewContent.frame.width, height: self.reviewContent.frame.width/1.33), false, 0.0)
            
            embeddedImage!.drawInRect(CGRect(origin: CGPointZero, size: CGSize(width: self.reviewContent.frame.width, height: self.reviewContent.frame.width/1.33)))
            playButton.image!.drawInRect(CGRect(origin: CGPoint(x: self.reviewContent.frame.width/2 - 37.5, y: self.reviewContent.frame.width/1.33/2 - 37.5), size: CGSize(width: 75, height: 75)))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            textAttachment.image = newImage
            
        } else if type == "Imgur" {
            
            textAttachment.image = embeddedImage
            
        }
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        
        
        let range = (attributedString.string as NSString).rangeOfString(imgURL)
        self.videoLocation[range.location] = imgID
        
        self.locations.append(range.location)
        attributedString.replaceCharactersInRange(range, withAttributedString: attrStringWithImage)
        
        self.reviewContent.attributedText = attributedString
        
        self.reviewContent.frame.size.height += textAttachment.image!.size.height
        
        self.reviewContentHeight = self.reviewContent.frame.height
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "handleTapOnLabel:")
        self.reviewContent.addGestureRecognizer(tap)
        self.reviewContent.userInteractionEnabled = true
        
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSizeZero)
        let textStorage = NSTextStorage(attributedString: attributedString)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0;
        textContainer.lineBreakMode = self.reviewContent.lineBreakMode
        textContainer.maximumNumberOfLines = self.reviewContent.numberOfLines
        
        self.textContainer = textContainer
        self.layoutManager = layoutManager
        self.textStorage = textStorage
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.commentTextView.removeFromSuperview()
        self.postComment.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.window!.addSubview(commentTextView)
        self.window!.addSubview(postComment)
        loadReviewNComments()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
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
    
    func likeReview(sender: UITapGestureRecognizer){
        let imageView = sender.view as! UIImageView
        imageView.image = UIImage(named: "liked")
        
        tapLike.removeTarget(self, action: "likeReview:")
        tapLike.addTarget(self, action: "unlikeReview:")
        
        let parameters =  ["likeable_id" : "\(imageView.tag)", "likeable_type" : "Review", "token": "\(resnateToken)"]
        
        let URL = NSURL(string: "https://www.resnate.com/api/likes/")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
            
        }
        
    }
    
    func unlikeReview(sender: UITapGestureRecognizer){
        let imageView = sender.view as! UIImageView
        imageView.image = UIImage(named: "like")
        
        tapLike.removeTarget(self, action: "unlikeReview:")
        tapLike.addTarget(self, action: "likeReview:")
        
        let parameters =  ["likeable_id" : "\(imageView.tag)", "likeable_type" : "Review", "token": "\(resnateToken)"]
        
        let URL = NSURL(string: "https://www.resnate.com/api/likes/")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.DELETE.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
            
        }
    }
    
    
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
            self.commentTextView.frame = CGRectMake(0, (UIScreen.mainScreen().bounds.height - keyboardHeight - 30), self.view.bounds.width - 50, 30)
            self.postComment.frame = CGRectMake(self.view.bounds.width - 50, (UIScreen.mainScreen().bounds.height - keyboardHeight - 30), 50, 30)
            }, completion: nil)
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        self.commentTextView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 79, self.view.bounds.width - 50, 30)
        self.postComment.frame = CGRectMake(self.view.bounds.width - 50, UIScreen.mainScreen().bounds.height - 79, 50, 30)
        
        
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
            
            if (commentTextView.text!).characters.count <= 3000 {
                
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
            
            self.window!.endEditing(true)
            
        } else {
            self.window!.endEditing(true)
            
        }
        
        
        
    }
    
    func playSingleSong(sender: AnyObject){
        
        self.window!.endEditing(true)
        
        
        
        self.tabBarController?.view.addSubview(ytPlayer.videoPlayer)
        
        ytPlayer.playVid(self.ytID)
        
        ytPlayer.ytID = self.ytID
        
        ytPlayer.ytTitle = self.ytTitle
        
        ytPlayer.shareID = "\(sender.view!.tag)"
        
    }
    
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch {
            print("invalid regex")
            return []
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.textContainer != nil {
            self.textContainer.size = self.reviewContent.bounds.size
        }
        
    }
    
    func handleTapOnLabel(tapGesture: UITapGestureRecognizer) {
        
        let locationOfTouchInLabel = tapGesture.locationInView(tapGesture.view)
        let labelSize = tapGesture.view!.bounds.size
        let textBoundingBox = self.layoutManager.usedRectForTextContainer(self.textContainer)
        let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
            locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = self.layoutManager.characterIndexForPoint(locationOfTouchInTextContainer, inTextContainer: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if self.locations.contains(indexOfCharacter) {
            
            let youTubeID = self.videoLocation[indexOfCharacter]!
            
            self.window!.endEditing(true)
            
            self.tabBarController?.view.addSubview(ytPlayer.videoPlayer)
            
            ytPlayer.playVid(youTubeID)
            
            ytPlayer.ytID = youTubeID
            
            ytPlayer.ytTitle = self.reviewSongs[youTubeID]!
            
        }
    }
}
*/