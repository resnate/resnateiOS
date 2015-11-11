//
//  Activity.swift
//  Resnate
//
//  Created by Amir Moosavi on 10/11/2015.
//  Copyright © 2015 Resnate. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func getGigInfo(gigID: Int, view: UIView, token: String, currentUserID: String, likerID: String){
        
        let width = Int(UIScreen.mainScreen().bounds.width)
        
        let imgWidth = Int(UIScreen.mainScreen().bounds.width) - 20
        
        let req = Router(OAuthToken: token, userID: String(gigID))
        
        request(req.buildURLRequest("gigs/", path: "")).responseJSON { response in
            
            let gig = JSON(response.result.value!)
            
            if let gigID = gig["id"].int {
                
                let likeGig = UIImageView(frame: CGRect(x: width/4 - 15, y: imgWidth + 120, width: 30, height: 30))
                
                view.addSubview(likeGig)
                
                let tapLike = UITapGestureRecognizer()
                
                likeGig.tag = gigID
                
                likeGig.addGestureRecognizer(tapLike)
                
                likeGig.userInteractionEnabled = true
                
                if currentUserID == likerID {
                    
                    likeGig.image = UIImage(named: "liked")
                    tapLike.addTarget(self, action: "unlikeSong:")
                    
                } else {
                    
                    let req = Router(OAuthToken: token, userID: currentUserID)
                    
                    request(req.buildURLRequest("likes/ifLike/Gig/", path: "/\(gigID)")).responseJSON { response in
                        if let re = response.result.value {
                            
                            let json = JSON(re)
                            
                            if let count = json["count"].int {
                                
                                if count > 0 {
                                    
                                    likeGig.image = UIImage(named: "liked")
                                    tapLike.addTarget(self, action: "unlikeGig:")
                                    
                                }
                                    
                                else {
                                    
                                    likeGig.image = UIImage(named: "likeWhite")
                                    tapLike.addTarget(self, action: "likeGig:")
                                }
                                
                                
                            }
                            
                            
                        }
                    }
                    
                    
                    
                }
                
                let songkickID = gig["songkick_id"].int!
                
                let artistLink = "https://api.songkick.com/api/3.0/events/\(songkickID).json?apikey=Pxms4Lvfx5rcDIuR"
                
                request(.GET, artistLink).responseJSON { response in
                    
                    var json = JSON(response.result.value!)
                    if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                        
                        let artistView = getHugeArtistPic(artist)
                        artistView.frame = CGRect(x: 10, y: 70, width: imgWidth, height: imgWidth)
                        view.addSubview(artistView)
                        
                        let tapGigActivity = UITapGestureRecognizer()
                        tapGigActivity.addTarget(self, action: "loadGig:")
                        artistView.tag = songkickID
                        
                        artistView.addGestureRecognizer(tapGigActivity)
                        artistView.userInteractionEnabled = true
                        
                    }
                    
                    if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                        
                        let gigNameLabel = UILabel(frame: CGRect(x: 80, y: 13.5, width: 240, height: 30))
                        
                        gigNameLabel.text = gigName
                        
                        gigNameLabel.textColor = UIColor.whiteColor()
                        gigNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                        gigNameLabel.numberOfLines = 2
                        
                        view.addSubview(gigNameLabel)
                        
                        
                    }
                    
                }
                
                let shareGig = UIImageView(frame: CGRect(x: width/4 * 3 - 15, y: imgWidth + 120, width: 30, height: 30))
                
                shareGig.image = UIImage(named: "Share")
                
                view.addSubview(shareGig)
                
                let tapShare = UITapGestureRecognizer()
                
                tapShare.addTarget(self, action: "shareGig:")
                shareGig.tag = gigID
                
                shareGig.addGestureRecognizer(tapShare)
                
                shareGig.userInteractionEnabled = true
                

                
            }
        }
        
    }
    
    func toActivity(sender: AnyObject) {
        
        let activityViewController = ActivityViewController(nibName: "ActivityViewController", bundle: nil)
        activityViewController.ID = sender.view!.tag
        self.navigationController?.pushViewController(activityViewController, animated: true)
        
    }
    
    
    
    
}

