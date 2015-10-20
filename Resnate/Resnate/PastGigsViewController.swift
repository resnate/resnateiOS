//
//  PastGigsViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 21/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class PastGigsViewController: UIViewController {
    
    
    
    
    
    
    
    var ID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        // Do any additional setup after loading the view.
        
        
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = String(ID)
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        self.navigationItem.title = "Past Gigs & Reviews"
        
        
        
        
        request(req.buildURLRequest("users/", path: "/past_gigs")).responseJSON { response in
            
            let json = JSON(response.result.value!)
                
                
                if let pastGigs = json.array {
                    
                    
                    
                    var y = 0
                    
                    for pastGig in pastGigs {
                        
                        let pgView = UIView(frame: CGRect(x: 10, y: y, width: 350, height: 250))
                        
                        self.pastGigsView.addSubview(pgView)
                        
                        
                        
                        let date = pastGig["gig_date"].string!
                        
                        let day = returnDayAndMonth(date).day
                        
                        let month = returnDayAndMonth(date).month
                        
                        let dayLabel = UILabel(frame: CGRect(x: 110, y: 20, width: 40, height: 35))
                        
                        dayLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                        
                        dayLabel.textAlignment = .Center
                        
                        dayLabel.text = day
                        dayLabel.backgroundColor = UIColor.whiteColor()
                        
                        let monthLabel = UILabel(frame: CGRect(x: 110, y: 0, width: 40, height: 22))
                        monthLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
                        monthLabel.backgroundColor = UIColor.redColor()
                        monthLabel.text = month as String
                        monthLabel.textColor = UIColor.whiteColor()
                        monthLabel.textAlignment = .Center
                        
                        
                        
                        
                        pgView.addSubview(dayLabel)
                        pgView.addSubview(monthLabel)
                        
                        
                        
                        
                        
                        let id = pastGig["id"].int!
                            
                            let resnateID = String(id)
                            
                            let req = Router(OAuthToken: resnateToken, userID: resnateID)
                            
                            
                            request(req.buildURLRequest("past_gigs/", path: "/review")).responseJSON { response in
                                
                                
                                
                                var json = JSON(response.result.value!)
                                
                                print(json)
                                    
                                    let reviewLabel = UILabel(frame: CGRect(x: 110, y: 130, width: 100, height: 40))
                                    
                                    reviewLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:0.9)
                                    
                                    reviewLabel.textColor = UIColor.whiteColor()
                                    reviewLabel.textAlignment = .Center
                                    reviewLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                                    reviewLabel.numberOfLines = 2
                                    
                                    let tapReview = UITapGestureRecognizer()
                                    reviewLabel.addGestureRecognizer(tapReview)
                                    
                                    
                                    reviewLabel.userInteractionEnabled = true
                                    
                                    if let reviewID = json["id"].int {
                                        
                                        reviewLabel.tag = reviewID
                                        
                                        reviewLabel.text = "Review"
                                        
                                        tapReview.addTarget(self, action: "toReview:")
                                        
                                        pgView.addSubview(reviewLabel)
                                        
                                    } else {
                                        let resnateID = dictionary!["userID"] as! String
                                        let pgUserID = String(pastGig["user_id"].int!)
                                        
                                        if resnateID == pgUserID {
                                            
                                            reviewLabel.text = "Write a \nReview"
                                            
                                            tapReview.addTarget(self, action: "writeGigReview:")
                                            
                                            pgView.addSubview(reviewLabel)
                                            
                                        }
                                    }
                                
                            }
                            
                            
                            
                        
                        
                        
                        
                        
                        
                        
                        
                        if let songkickID = pastGig["songkick_id"].int {
                            
                            
                            let setlistLabel = UILabel(frame: CGRect(x: 0, y: 130, width: 100, height: 40))
                            
                            setlistLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:0.9)
                            
                            setlistLabel.text = "Setlist"
                            setlistLabel.textColor = UIColor.whiteColor()
                            setlistLabel.textAlignment = .Center
                            setlistLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                            let tapRec = UITapGestureRecognizer()
                            
                            
                            tapRec.addTarget(self, action: "toSetlist:")
                            setlistLabel.addGestureRecognizer(tapRec)
                            setlistLabel.tag = songkickID
                            
                            setlistLabel.userInteractionEnabled = true
                            
                            
                            pgView.addSubview(setlistLabel)
                            
                            
                            
                            
                            
                            
                            let pgSK = "https://api.songkick.com/api/3.0/events/\(String(songkickID)).json?apikey=Pxms4Lvfx5rcDIuR"
                            
                            request(.GET, pgSK).responseJSON { response in
                                var json = JSON(response.result.value!)
                                    
                                    
                                    
                                    
                                    
                                    
                                    if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                        
                                        
                                        
                                        
                                        
                                        let artistView = getArtistPic(artist)
                                        artistView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                                        pgView.addSubview(artistView)
                                        
                                        
                                        
                                    }
                                    
                                    if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                        
                                        let gigNameLabel = UILabel(frame: CGRect(x: 160, y: 0, width: 145, height: 68))
                                        gigNameLabel.text = gigName
                                        gigNameLabel.textColor = UIColor.whiteColor()
                                        gigNameLabel.lineBreakMode = .ByTruncatingTail
                                        gigNameLabel.numberOfLines = 0
                                        
                                        gigNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                        gigNameLabel.sizeToFit()
                                        
                                        pgView.addSubview(gigNameLabel)
                                        
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                
                            }
                            
                            
                        }
                        
                        
                        
                        y += 250
                        
                    }
                    
                    self.pastGigsView.contentSize.height = CGFloat(y + 30)
                }
                

            
            
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var pastGigsView: UIScrollView!
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
