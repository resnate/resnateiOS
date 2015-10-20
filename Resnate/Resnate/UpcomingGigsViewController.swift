//
//  UpcomingGigsViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 02/07/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class UpcomingGigsViewController: UIViewController {
    
    var ID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        // Do any additional setup after loading the view.
        
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = String(ID)
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        
        request(req.buildURLRequest("users/", path: "/upcoming_gigs")).responseJSON { response in
            
                if let upcomingGigs = JSON(response.result.value!).array {
                    var y = 0
                    
                    for gig in upcomingGigs {
                        
                        let ugView = UIView(frame: CGRect(x: 0, y: y, width: 350, height: 250))
                        
                        let ugTapView = UIView(frame: CGRect(x: 0, y: 0, width: 350, height: 100))
                        
                        ugView.addSubview(ugTapView)
                        
                        let gigID = gig["id"].int!
                        
                        let songkickID = gig["songkick_id"].int!
                        
                        let songkickTap = UITapGestureRecognizer()
                        songkickTap.addTarget(self, action: "loadGig:")
                        ugTapView.tag = songkickID
                        
                        ugTapView.addGestureRecognizer(songkickTap)
                        ugTapView.userInteractionEnabled = true
                        
                        let userID = String(self.ID)
                        
                        let resnateID = "/\(userID)/\(String(songkickID))"
                        
                        let req = Router(OAuthToken: resnateToken, userID: resnateID)
                        
                        let width = UIScreen.mainScreen().bounds.width
                        
                        self.upcomingGigsView.addSubview(ugView)
                        
                        request(req.buildURLRequest("gigs/", path: "/friendsGoing")).responseJSON { response in
                                
                                
                                
                                let users = JSON(response.result.value!)
                                let count = users.count
                                
                                
                                if count > 0 {
                                    
                                    let friendsGoingLabel = UILabel(frame: CGRect(x: 10, y: 105, width: 100, height: 50))
                                    
                                    friendsGoingLabel.text = "Friends Going"
                                    
                                    friendsGoingLabel.textColor = UIColor.whiteColor()
                                    
                                    friendsGoingLabel.lineBreakMode = .ByWordWrapping
                                    
                                    friendsGoingLabel.numberOfLines = 2
                                    
                                    ugView.addSubview(friendsGoingLabel)
                                    
                                    
                                    for i in 0...count {
                                        
                                        var x = 120
                                        
                                        if let resnateID = users[i]["id"].int {
                                            
                                            let stringID = String(resnateID)
                                            
                                            let req = Router(OAuthToken: resnateToken, userID: stringID)
                                            
                                            request(req.buildURLRequest("users/", path: "/profile")).responseJSON { response in
                                                
                                                    var json = JSON(response.result.value!)
                                                    
                                                    if let uid = json["userID"].string {
                                                        
                                                        let url = NSURL(string: "https://graph.facebook.com/\(uid)/picture?width=200&height=200")
                                                        
                                                        self.getDataFromUrl(url!) { data in
                                                            dispatch_async(dispatch_get_main_queue()) {
                                                                
                                                                let friendsGoingView = UIImageView(frame: CGRect(x: x, y: 110, width: 40, height: 40))
                                                                
                                                                let goingImg = UIImage(data: data!)
                                                                
                                                                friendsGoingView.image = goingImg
                                                                
                                                                let tapRecProfile = UITapGestureRecognizer()
                                                                
                                                                tapRecProfile.addTarget(self, action: "profile:")
                                                                friendsGoingView.tag = resnateID
                                                                friendsGoingView.addGestureRecognizer(tapRecProfile)
                                                                friendsGoingView.userInteractionEnabled = true
                                                                
                                                                ugView.addSubview(friendsGoingView)
                                                                
                                                                x += 40
                                                            }
                                                        }
                                                        
                                                    }
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        let date = gig["gig_date"].string!
                        
                        let day = returnDayAndMonth(date).day
                        
                        let month = returnDayAndMonth(date).month
                        
                        let dayLabel = UILabel(frame: CGRect(x: 120, y: 20, width: 40, height: 35))
                        
                        dayLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                        
                        dayLabel.textAlignment = .Center
                        
                        dayLabel.text = day
                        dayLabel.backgroundColor = UIColor.whiteColor()
                        
                        let monthLabel = UILabel(frame: CGRect(x: 120, y: 0, width: 40, height: 22))
                        monthLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
                        monthLabel.backgroundColor = UIColor.redColor()
                        monthLabel.text = month as String
                        monthLabel.textColor = UIColor.whiteColor()
                        monthLabel.textAlignment = .Center
                        
                        
                        ugTapView.addSubview(dayLabel)
                        ugTapView.addSubview(monthLabel)
                        
                        
                        
                        if let songkickID = gig["songkick_id"].int {
                            
                            
                            let ugSK = "https://api.songkick.com/api/3.0/events/\(String(songkickID)).json?apikey=Pxms4Lvfx5rcDIuR"
                            
                            request(.GET, ugSK).responseJSON { response in

                                    var json = JSON(response.result.value!)
                                    
                                    
                                    
                                    
                                    
                                    
                                    if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                        
                                        
                                        
                                        
                                        
                                        let artistView = getArtistPic(artist)
                                        artistView.frame = CGRect(x: 10, y: 0, width: 100, height: 100)
                                        ugTapView.addSubview(artistView)
                                        
                                        
                                        
                                    }
                                    
                                    if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                        
                                        let gigNameLabel = UILabel(frame: CGRect(x: 170, y: 0, width: 135, height: 68))
                                        gigNameLabel.text = gigName
                                        gigNameLabel.textColor = UIColor.whiteColor()
                                        gigNameLabel.lineBreakMode = .ByTruncatingTail
                                        gigNameLabel.numberOfLines = 0
                                        
                                        gigNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                        gigNameLabel.sizeToFit()
                                        
                                        ugTapView.addSubview(gigNameLabel)
                                        
                                    }

                            }
                            
                            
                        }
                        
                        
                        
                        let shareImgSize = CGSize(width: 40, height: 40)
                        
                        let shareView = UIView(frame: CGRect(x: 0, y: 180, width: width, height: 40))
                        
                        let resnateShare = UIImageView(image: UIImage(named: "Share"))
                        resnateShare.frame.size = shareImgSize
                        resnateShare.frame.origin.x = width/3 - 20
                        shareView.addSubview(resnateShare)
                        
                        let tapRecShare = UITapGestureRecognizer()
                        
                        tapRecShare.addTarget(self, action: "share:")
                        resnateShare.tag = gigID
                        resnateShare.addGestureRecognizer(tapRecShare)
                        resnateShare.userInteractionEnabled = true
                        
                        
                        let fbShare = UIImageView(image: UIImage(named: "facebook.jpg"))
                        fbShare.frame.size = shareImgSize
                        fbShare.frame.origin.x = (width/2) - 20
                        shareView.addSubview(fbShare)
                        
                        
                        
                        let tapRecFb = UITapGestureRecognizer()
                        
                        tapRecFb.addTarget(self, action: "fbReview:")
                        fbShare.tag = gigID
                        fbShare.addGestureRecognizer(tapRecFb)
                        fbShare.userInteractionEnabled = true
                        
                        let twitShare = UIImageView(image: UIImage(named: "twitter"))
                        twitShare.frame.size = shareImgSize
                        twitShare.frame.origin.x = (width/3)*2 - 20
                        shareView.addSubview(twitShare)
                        
                        let tapRecTwit = UITapGestureRecognizer()
                        
                        tapRecTwit.addTarget(self, action: "twitter:")
                        twitShare.tag = gigID
                        twitShare.addGestureRecognizer(tapRecTwit)
                        twitShare.userInteractionEnabled = true

                        
                        ugView.addSubview(shareView)
                        
                        
                        y += 290
                        
                    }
                    
                    self.upcomingGigsView.contentSize.height = CGFloat(y + 30)

                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    @IBOutlet weak var upcomingGigsView: UIScrollView!
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
