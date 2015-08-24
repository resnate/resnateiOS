//
//  PastGigsViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 21/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class PastGigsViewController: UIViewController {
    
    
    func toSetlist(sender: AnyObject) {
        
        let setlistViewController:SetlistViewController = SetlistViewController(nibName: "SetlistViewController", bundle: nil)
        
        setlistViewController.ID = sender.view!.tag
        
        self.navigationController?.pushViewController(setlistViewController, animated: true)
        
    }
    
    
    
    
    var ID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        // Do any additional setup after loading the view.
        
        
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = String(ID)
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        self.navigationItem.title = "Past Gigs & Reviews"
        
        
        
        
        request(req.buildURLRequest("users/", path: "/past_gigs")).responseJSON { (_, _, json, error) in
            if json != nil {
                
                
                if let pastGigs = JSON(json!).array {
                    
                    
                    
                    var y = 0
                    
                    for pastGig in pastGigs {
                    
                        let width = UIScreen.mainScreen().bounds.width
                        
                        
                        let pgView = UIView(frame: CGRect(x: 0, y: y, width: 350, height: 250))
                        
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
                        
                        
                        
                        
                        
                        if let id = pastGig["id"].int {
                            
                            let resnateID = String(id)
                            
                            let req = Router(OAuthToken: resnateToken, userID: resnateID)
                            
                            
                            request(req.buildURLRequest("past_gigs/", path: "/review")).responseJSON { (_, _, json, error) in
                                if json != nil {
                                    var json = JSON(json!)
                                    if let id = json["id"].int {
                                        
                                        let reviewLabel = UILabel(frame: CGRect(x: 0, y: 190, width: width, height: 40))
                                        
                                        reviewLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                                        
                                        reviewLabel.text = "Review"
                                        reviewLabel.textColor = UIColor.whiteColor()
                                        reviewLabel.textAlignment = .Center
                                        reviewLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                                        let tapRec = UITapGestureRecognizer()
                                        
                                        
                                        tapRec.addTarget(self, action: "toModalReview:")
                                        reviewLabel.addGestureRecognizer(tapRec)
                                        reviewLabel.tag = id
                                        
                                        reviewLabel.userInteractionEnabled = true
                                        
                                        
                                        pgView.addSubview(reviewLabel)
                                        
                                    } else {
                                        let resnateID = dictionary!["userID"] as! String
                                        let pgUserID = String(pastGig["user_id"].int!)
                                        
                                        if resnateID == pgUserID {
                                            
                                            let reviewLabel = UILabel(frame: CGRect(x: 0, y: 190, width: width, height: 40))
                                            
                                            reviewLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                                            
                                            reviewLabel.text = "Write a Review"
                                            reviewLabel.textColor = UIColor.whiteColor()
                                            reviewLabel.textAlignment = .Center
                                            reviewLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                                            let tapRec = UITapGestureRecognizer()
                                            
                                            tapRec.addTarget(self, action: "writeGigReview:")
                                            reviewLabel.addGestureRecognizer(tapRec)
                                            reviewLabel.tag = id
                                            
                                            reviewLabel.userInteractionEnabled = true
                                            
                                            
                                            pgView.addSubview(reviewLabel)
                                            
                                        }
                                    }
                                }
                            }
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                        
                        if let songkickID = pastGig["songkick_id"].int {
                            
                            
                            let setlistLabel = UILabel(frame: CGRect(x: 0, y: 130, width: width, height: 40))
                            
                            setlistLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                            
                            setlistLabel.text = "Setlist"
                            setlistLabel.textColor = UIColor.whiteColor()
                            setlistLabel.textAlignment = .Center
                            setlistLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                            let tapRec = UITapGestureRecognizer()
                            
                            
                            tapRec.addTarget(self, action: "toSetlist:")
                            setlistLabel.addGestureRecognizer(tapRec)
                            setlistLabel.tag = songkickID
                            
                            setlistLabel.userInteractionEnabled = true
                            
                            
                            pgView.addSubview(setlistLabel)
                            
                            
                            
                            
                            
                            
                            let pgSK = "https://api.songkick.com/api/3.0/events/\(String(songkickID)).json?apikey=Pxms4Lvfx5rcDIuR"
                            
                            request(.GET, pgSK).responseJSON { (_, _, json, _) in
                                if json != nil {
                                    var json = JSON(json!)
                                    
                                    
                                    
                                    
                                    
                                    
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
                            
                            
                        }
                        
                        
                        
                        y += 290
                        
                    }
                    
                    self.pastGigsView.contentSize.height = CGFloat(y + 30)
                }
                
                
                
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
