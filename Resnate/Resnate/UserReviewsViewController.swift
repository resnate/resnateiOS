//
//  UserReviewsViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 06/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class UserReviewsViewController: UIViewController, UIScrollViewDelegate {
    
    var ID = 0
    
    var page = 1
    
    var y = 0
    
    let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.userReviewsView.delegate = self
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        let resnateToken = self.dictionary!["token"] as! String
        
        let resnateID = String(ID)
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        let width = Int(UIScreen.mainScreen().bounds.width)
        
        loadReviews(req, resnateToken: resnateToken, width: width)
        
        
        
        request(req.buildURLRequest("users/", path: "/profile")).responseJSON { response in
            if let re = response.result.value {
                let json = JSON(re)
                
                let first_name = json["first_name"].string!
                self.navigationItem.title = "  \(first_name)'s Reviews"
                
            }
        }
        
        
    }
    
    func loadReviews(req: Router, resnateToken: String, width: Int){
        
        self.userReviewsView.contentSize.height += 10
        
        let loadingView = UIActivityIndicatorView(frame: CGRect(x: Int(UIScreen.mainScreen().bounds.width/2 - 25), y: Int(self.userReviewsView.contentSize.height - 30), width: 50, height: 50))
        
        self.userReviewsView.addSubview(loadingView)
        
        loadingView.startAnimating()
        
        self.userReviewsView.tag = -1
        
        request(req.buildURLRequest("users/", path: "/reviews/\(page)")).responseJSON { response in
            
            if let re = response.result.value {
                
                if let reviews = JSON(re).array {
                    
                    for review in reviews {
                        
                        let reviewView = UIView(frame: CGRect(x: 10, y: self.y, width: width - 20, height: 150))
                        self.userReviewsView.addSubview(reviewView)
                        
                        let tapRec = UITapGestureRecognizer()
                        
                        if let reviewID = review["id"].int {
                            tapRec.addTarget(self, action: "toReview:")
                            reviewView.addGestureRecognizer(tapRec)
                            
                            reviewView.tag = reviewID
                            reviewView.userInteractionEnabled = true
                            
                            
                            
                            let req = Router(OAuthToken: resnateToken, userID: String(reviewID))
                            
                            request(req.buildURLRequest("reviews/", path: "/likes")).responseJSON { response in
                                if let re = response.result.value {
                                    let users = JSON(re)
                                    let userCount = users.count
                                    
                                    let userCountLabel = UILabel(frame: CGRect(x: 0, y: 110, width: 100, height: 40))
                                    
                                    if userCount == 0 {
                                        
                                    }
                                    else if userCount == 1 {
                                        userCountLabel.text = "1 like"
                                    } else {
                                        userCountLabel.text = "\(userCount) likes"
                                    }
                                    
                                    userCountLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                                    
                                    userCountLabel.textColor = UIColor.whiteColor()
                                    
                                    userCountLabel.textAlignment = .Center
                                    
                                    reviewView.addSubview(userCountLabel)
                                    
                                }
                            }
                            
                            
                        }
                        
                        
                        
                        
                        
                        let reviewTitle = UILabel(frame: CGRect(x: 120, y: self.y, width: width - 150, height: 70))
                        
                        reviewTitle.lineBreakMode = .ByTruncatingTail
                        reviewTitle.numberOfLines = 3
                        
                        setBoldText(reviewTitle)
                        
                        
                        
                        if review["reviewable_type"] == "PastGig" {
                            
                            
                            
                            
                            let pastGigID = String(stringInterpolationSegment: review["reviewable_id"])
                            
                            
                            let req = Router(OAuthToken: resnateToken, userID: pastGigID)
                            
                            
                            request(req.buildURLRequest("past_gigs/", path: "")).responseJSON { response in
                                
                                if let re = response.result.value {
                                    
                                    
                                    let pastGig = JSON(re)
                                    if let skID = pastGig["songkick_id"].int {
                                        
                                        let artistLink = "https://api.songkick.com/api/3.0/events/" + String(skID) + ".json?apikey=Pxms4Lvfx5rcDIuR"
                                        
                                        request(.GET, artistLink).responseJSON { response in
                                            if let re = response.result.value {
                                                
                                                
                                                
                                                
                                                let json = JSON(re)
                                                if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    let artistView = getArtistPic(artist)
                                                    artistView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                                                    reviewView.addSubview(artistView)
                                                }
                                                
                                                if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                                    
                                                    reviewTitle.text = gigName
                                                    reviewTitle.sizeToFit()
                                                    self.userReviewsView.addSubview(reviewTitle)
                                                    
                                                    
                                                }
                                                
                                                
                                                
                                            }
                                        }
                                    }
                                }
                            }
                            
                        } else if review["reviewable_type"] == "Song" {
                            
                            
                            let songID = String(stringInterpolationSegment: review["reviewable_id"])
                            
                            
                            let req = Router(OAuthToken: resnateToken, userID: songID)
                            
                            request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
                                if let re = response.result.value {
                                    
                                    let song = JSON(re)
                                    
                                    if let ytID = song["content"].string {
                                        
                                        let ytLink = "https://img.youtube.com/vi/" + ytID + "/hqdefault.jpg"
                                        
                                        let songImgUrl = NSURL(string: ytLink)
                                        let reviewSongImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                                        self.getDataFromUrl(songImgUrl!) { data in
                                            dispatch_async(dispatch_get_main_queue()) {
                                                
                                                reviewSongImg.image = UIImage(data: data!)
                                                
                                                
                                                
                                            }
                                        }
                                        reviewView.addSubview(reviewSongImg)
                                        
                                        
                                    }
                                    
                                    if let ytName = song["name"].string {
                                        
                                        reviewTitle.text = ytName
                                        reviewTitle.sizeToFit()
                                        self.userReviewsView.addSubview(reviewTitle)
                                    }
                                    
                                    
                                }
                            }
                            
                            
                        }
                        
                        if let content = review["content"].string {
                            
                            let reviewContent = UILabel(frame: CGRect(x: 120, y: self.y + 55, width: width - 150, height: 100))
                            
                            reviewContent.textColor = UIColor.whiteColor()
                            reviewContent.text = content
                            reviewContent.font = UIFont(name: "HelveticaNeue-Light", size: 12)
                            
                            
                            reviewContent.numberOfLines = 3
                            reviewContent.sizeToFit()
                            
                            
                            self.userReviewsView.addSubview(reviewContent)
                        }
                        
                        self.y += 180
                        
                    }
                    
                    
                    self.page += 1
                    
                    self.userReviewsView.contentSize.height = CGFloat(self.y + 20)
                }
                
                loadingView.stopAnimating()
                
                self.userReviewsView.tag = 0
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) && scrollView.contentSize.height > 1 && scrollView.tag != -1) {
            
            let resnateToken = dictionary!["token"] as! String
            
            let resnateID = String(ID)
            
            let req = Router(OAuthToken: resnateToken, userID: resnateID)
            
            let width = Int(UIScreen.mainScreen().bounds.width)
            
            loadReviews(req, resnateToken: resnateToken, width: width)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var userReviewsView: UIScrollView!

    
}
