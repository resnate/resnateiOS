//
//  UserReviewsViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 06/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class UserReviewsViewController: UIViewController {
    
    var ID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = String(ID)
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        
        request(req.buildURLRequest("users/", path: "/reviews")).responseJSON { (_, _, json, error) in
            if json != nil {
                
                if let reviews = JSON(json!).array {
                    
                   
                    var y = 0
                    
                    for review in reviews {
                        
                        let reviewView = UIView(frame: CGRect(x: 0, y: y, width: 350, height: 150))
                        self.userReviewsView.addSubview(reviewView)
                        
                        let tapRec = UITapGestureRecognizer()
                        
                        if let reviewID = review["id"].int {
                            tapRec.addTarget(self, action: "toModalReview:")
                            reviewView.addGestureRecognizer(tapRec)
                            
                            reviewView.tag = reviewID
                            reviewView.userInteractionEnabled = true
                            
                        }
                        
                        
                        
                        
                        
                        let reviewTitle = UILabel(frame: CGRect(x: 110, y: y, width: 200, height: 70))
                        
                        reviewTitle.lineBreakMode = .ByTruncatingTail
                        reviewTitle.numberOfLines = 3
                        
                        setBoldText(reviewTitle)
                        
                        
                        
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
                            
                            request(req.buildURLRequest("songs/", path: "")).responseJSON { (_, _, json, _) in
                                if json != nil {
                                    
                                    let song = JSON(json!)
                                    
                                    if let ytID = song["content"].string {
                                        
                                        let ytLink = "https://img.youtube.com/vi/" + ytID + "/hqdefault.jpg"
                                        
                                        
                                        
                                        let songReviewView = getYTPic(ytLink)
                                        songReviewView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                                        reviewView.addSubview(songReviewView)
                                        self.userReviewsView.addSubview(reviewView)
                                        
                                        
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
                            
                            let reviewContent = UILabel(frame: CGRect(x: 110, y: y + 60, width: 200, height: 100))
                            
                            setSKLabelText(reviewContent)
                            reviewContent.text = content
                            
                            reviewContent.numberOfLines = 4
                            reviewContent.sizeToFit()
                            
                            
                            self.userReviewsView.addSubview(reviewContent)
                        }
                        
                        
                        y += 180
                        
                    }
                    
                    
                    
                    
                    self.userReviewsView.contentSize.height = CGFloat(y + 20)
                }
                
                
                
                
                
                
                
                
                
                
                
                
            } else {
                println(error)
            }
        }
        
        
        request(req.buildURLRequest("users/", path: "/profile")).responseJSON { (_, _, json, _) in
            if json != nil {
                var json = JSON(json!)
                
                let first_name = json["first_name"].string!
                self.navigationItem.title = "  \(first_name)'s Reviews"
                
            }
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var userReviewsView: UIScrollView!

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
