//
//  ReviewViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 13/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit
import TwitterKit


class ReviewViewController: UIViewController, UIAlertViewDelegate, UITextFieldDelegate, UITableViewDelegate {
    
    var ID = 0
    
    var rating = 0
    
    var ratingButtons = [UIButton]()
    
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        let reviewID = String(ID)
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: reviewID)
        
        request(req.buildURLRequest("reviews/", path: "")).responseJSON { (_, _, json, error) in
            if json != nil {
                
                let height = UIScreen.mainScreen().bounds.height
                
                let width = UIScreen.mainScreen().bounds.width
                
                let review = JSON(json!)
                
                let reviewView = self.reviewView
                
                let userID = review["user_id"].int!
                
                
                
                
                if review["reviewable_type"] == "PastGig" {
                    
                    
                    
                    
                    let pastGigID = String(stringInterpolationSegment: review["reviewable_id"])
                    
                    
                    let req = Router(OAuthToken: resnateToken, userID: pastGigID)
                    
                    
                    request(req.buildURLRequest("past_gigs/", path: "")).responseJSON { (_, _, json, _) in
                        if json != nil {
                            
                            
                            let pastGig = JSON(json!)
                            if let skID = pastGig["songkick_id"].int {
                                
                                let artistLink = "https://api.songkick.com/api/3.0/events/" + String(skID) + ".json?apikey=Pxms4Lvfx5rcDIuR"
                                
                                request(.GET, artistLink).responseJSON { (_, _, json, _) in
                                    if json != nil {
                                        
                                        
                                        
                                        
                                        var json = JSON(json!)
                                        if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                            
                                            
                                            
                                            
                                            
                                            let artistView = getHugeArtistPic(artist)
                                            artistView.frame = CGRect(x: 0, y: 0, width: width, height: width)
                                            reviewView.addSubview(artistView)
                                        }
                                        
                                        if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                            
                                            let navHeight = self.navigationController?.navigationBar.frame.height
                                            let reviewTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: navHeight!))
                                            reviewTitle.text = gigName
                                            reviewTitle.textAlignment = .Center
                                            reviewTitle.textColor = UIColor.whiteColor()
                                            reviewTitle.font = UIFont(name: "Helvetica Neue", size: 12)!
                                            reviewTitle.numberOfLines = 3
                                            self.navigationItem.titleView = reviewTitle
                                            var b = UIBarButtonItem(title: "", style: .Plain, target: self, action: "shareGigReview:")
                                            b.image = UIImage(named: "Share")!.imageWithRenderingMode(.AlwaysOriginal)
                                            b.tag = self.ID
                                            
                                            self.navigationItem.rightBarButtonItem = b
                                            
                                        }
                                        
                                        
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                } else if review["reviewable_type"] == "Song" {
                    
                    
                    let songID = String(stringInterpolationSegment: review["reviewable_id"])
                    
                    
                    let req = Router(OAuthToken: resnateToken, userID: songID)
                    
                    request(req.buildURLRequest("songs/", path: "")).responseJSON { (_, _, json, _) in
                        if json != nil {
                            
                            let song = JSON(json!)
                            
                            if let ytID = song["content"].string {
                                
                                let ytLink = "https://img.youtube.com/vi/" + ytID + "/hqdefault.jpg"
                                
                                
                                
                                let songReviewView = getYTPic(ytLink)
                                songReviewView.frame = CGRect(x: 0, y: 0, width: width, height: width/1.33)
                                reviewView.addSubview(songReviewView)
                                
                                
                            }
                            
                            if let ytName = song["name"].string {
                                let reviewTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
                                reviewTitle.text = ytName
                                reviewTitle.numberOfLines = 3
                                self.navigationItem.titleView?.addSubview(reviewTitle)
                            }
                            
                            
                        }
                    }
                    
                }
                
                
                
                
                
                if let content = review["content"].string {
                    
                    
                    
                    let reviewContent = UILabel(frame: CGRect(x: 0, y: 0, width: width - 20, height: CGFloat.max))
                    
                    reviewContent.lineBreakMode = .ByWordWrapping
                    reviewContent.numberOfLines = 0
                    
                    reviewContent.text = content
                    
                    reviewContent.font = UIFont(name: "HelveticaNeue-Light", size: 13)
                    
                    reviewContent.sizeToFit()
                    
                    var frame = reviewContent.frame
                    
                    
                    if review["reviewable_type"] == "PastGig" {
                        frame.origin = CGPointMake(10, width + 5)
                    } else {
                        frame.origin = CGPointMake(10, width/1.33 + 5)
                    }
                    
                    
                    
                    
                    reviewContent.frame = frame
                    
                    
                    
                    
                    
                    reviewView.addSubview(reviewContent)
                    
                    
                    reviewView.contentSize.height = reviewContent.frame.height + width + 260
                    
                    
                    
                    if resnateID.toInt() == userID {
                        let editLabel = UILabel(frame: CGRect(x: 0, y: reviewContent.frame.height + width + 90, width: width/2 - 1, height: 40))
                        
                        editLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                        editLabel
                        editLabel.text = "Edit"
                        editLabel.textColor = UIColor.whiteColor()
                        editLabel.textAlignment = .Center
                        editLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                        let tapRecEdit = UITapGestureRecognizer()
                        
                        
                        tapRecEdit.addTarget(self, action: "editReview:")
                        editLabel.addGestureRecognizer(tapRecEdit)
                        editLabel.tag = review["id"].int!
                        
                        editLabel.userInteractionEnabled = true
                        
                        
                        reviewView.addSubview(editLabel)
                        
                        
                        let deleteLabel = UILabel(frame: CGRect(x: width/2 + 1, y: reviewContent.frame.height + width + 90, width: width/2 - 1, height: 40))
                        
                        deleteLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                        
                        deleteLabel.text = "Delete"
                        deleteLabel.textColor = UIColor.whiteColor()
                        deleteLabel.textAlignment = .Center
                        deleteLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                        let tapRecDelete = UITapGestureRecognizer()
                        
                        
                        tapRecDelete.addTarget(self, action: "deleteReview:")
                        deleteLabel.addGestureRecognizer(tapRecDelete)
                        deleteLabel.tag = review["id"].int!
                        
                        deleteLabel.userInteractionEnabled = true
                        
                        
                        reviewView.addSubview(deleteLabel)
                    }
                    else {
                        let likeLabel = UILabel(frame: CGRect(x: 0, y: reviewContent.frame.height + width + 90, width: width, height: 40))
                        
                        likeLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                        likeLabel.text = "Like"
                        likeLabel.textColor = UIColor.whiteColor()
                        likeLabel.textAlignment = .Center
                        likeLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                        let tapRecLike = UITapGestureRecognizer()
                        
                        
                        tapRecLike.addTarget(self, action: "likeReview:")
                        likeLabel.addGestureRecognizer(tapRecLike)
                        likeLabel.tag = review["id"].int!
                        
                        likeLabel.userInteractionEnabled = true
                        
                        
                        reviewView.addSubview(likeLabel)
                    }
                    
                    
                    let req = Router(OAuthToken: resnateToken, userID: String(reviewID))
                    
                    request(req.buildURLRequest("reviews/", path: "/likes")).responseJSON { (_, _, json, _) in
                        if json != nil {
                            var users = JSON(json!)
                            let userCount = users.count
                            
                            let userCountLabel = UILabel(frame: CGRect(x: 10, y: reviewContent.frame.height + width + 140, width: width, height: 40))
                            
                            if userCount == 1 {
                                userCountLabel.text = "1 like"
                            } else {
                                userCountLabel.text = "\(userCount) likes"
                            }
                            
                            userCountLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                            
                            reviewView.addSubview(userCountLabel)
                            
                        }
                    }
                    
                    let ratingView = UIView(frame: CGRect(x: 5, y: reviewContent.frame.height + width + 30, width: 300, height: 50))
                    
                    
                    
                    let filledStarImage = UIImage(named: "filledStar")
                    let emptyStarImage = UIImage(named: "emptyStar")
                    
                    var x = 0
                    
                    for _ in 0..<5 {
                        
                        let button = UIButton(frame: CGRect(x: x, y: 0, width: 44, height: 44))
                        
                        
                        button.setImage(emptyStarImage, forState: .Normal)
                        button.setImage(filledStarImage, forState: .Selected)
                        button.setImage(filledStarImage, forState: .Highlighted | .Selected)
                        
                        button.adjustsImageWhenHighlighted = false
                        
                        button.addTarget(self, action: "ratingButtonTapped:", forControlEvents: .TouchDown)
                        self.ratingButtons += [button]
                        
                        
                        ratingView.addSubview(button)
                        
                        x += 50
                    }
                    
                    let shareImgSize = CGSize(width: 40, height: 40)
                    
                    let shareView = UIView(frame: CGRect(x: 0, y: reviewContent.frame.height + width + 190, width: width, height: 40))
                    
                    let resnateShare = UIImageView(image: UIImage(named: "Share"))
                    resnateShare.frame.size = shareImgSize
                    resnateShare.frame.origin.x = width/3 - 20
                    shareView.addSubview(resnateShare)
                    
                    let tapRecShare = UITapGestureRecognizer()
                    
                    tapRecShare.addTarget(self, action: "shareGigReview:")
                    resnateShare.tag = reviewID.toInt()!
                    resnateShare.addGestureRecognizer(tapRecShare)
                    resnateShare.userInteractionEnabled = true
                    
                    
                    let fbShare = UIImageView(image: UIImage(named: "facebook.jpg"))
                    fbShare.frame.size = shareImgSize
                    fbShare.frame.origin.x = reviewView.center.x - 20
                    shareView.addSubview(fbShare)
                    
                    
                    
                    let tapRecFb = UITapGestureRecognizer()
                    
                    tapRecFb.addTarget(self, action: "fbReview:")
                    fbShare.tag = reviewID.toInt()!
                    fbShare.addGestureRecognizer(tapRecFb)
                    fbShare.userInteractionEnabled = true
                    
                    let twitShare = UIImageView(image: UIImage(named: "twitter"))
                    twitShare.frame.size = shareImgSize
                    twitShare.frame.origin.x = (width/3)*2 - 20
                    shareView.addSubview(twitShare)
                    
                    let tapRecTwit = UITapGestureRecognizer()
                    
                    tapRecTwit.addTarget(self, action: "twitter:")
                    twitShare.tag = reviewID.toInt()!
                    twitShare.addGestureRecognizer(tapRecTwit)
                    twitShare.userInteractionEnabled = true
                    
                    reviewView.addSubview(shareView)
                    
                    reviewView.addSubview(ratingView)
                    
                }
                
                
                
                
                
                
                let req = Router(OAuthToken: resnateToken, userID: String(userID))
                
                request(req.buildURLRequest("users/", path: "/profile")).responseJSON { (_, _, json, _) in
                    if json != nil {
                        var json = JSON(json!)
                        
                        let name = json["name"].string!
                        
                        //self.reviewAuthor.text = name
                        
                    }
                }
                
                
                
                
                
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var reviewView: UIScrollView!
    
    
    func ratingButtonTapped(button: UIButton) {
        self.rating = find(self.ratingButtons, button)! + 1
        
        updateButtonSelectionStates()
    }
    
    func updateButtonSelectionStates() {
        
        for (index, button) in enumerate(self.ratingButtons) {
            // If the index of a button is less than the rating, that button shouldn't be selected.
            button.selected = index < self.rating
        }
        
    }

}
