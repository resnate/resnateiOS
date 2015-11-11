//
//  NotificationsViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 07/11/2015.
//  Copyright © 2015 Resnate. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var ID = 0
    
    var totalY = 10
    
    var page = 1
    
    let width = Int(UIScreen.mainScreen().bounds.width)
    
    let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
    
    let loadingView = UIActivityIndicatorView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 - 25, y: 30, width: 50, height: 50))
    
    
    
    func getNotifications(page: Int, totalY: Int) {
        
        let resnateToken = dictionary!["token"] as! String
        
        
        self.scrollView.tag = -1
        
        self.scrollView.addSubview(loadingView)
        
        self.scrollView.contentSize.height += 100
        
        self.loadingView.startAnimating()
        
        let resnateID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: resnateToken)
        
        request(req.buildURLRequest("messages/", path: "/notifications/\(page)")).responseJSON { response in
            
            if let re = response.result.value {
                
                let notifications = JSON(re)
                
                var y = totalY
                
                for (_, notification) in notifications {
                    
                    let notificationView = UIView(frame: CGRect(x: 0, y: y, width: self.width, height: 60))
                    notificationView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:0.5)
                    self.scrollView.addSubview(notificationView)
                    notificationView.userInteractionEnabled = true
                    
                    if let participants = notification["participants"].array {
                        
                        for participant in participants {
                            
                            if let userID = participant["id"].int {
                                
                                if Int(resnateID) != userID {
                                    
                                    if let name = participant["name"].string {
                                        
                                        if let message = notification["message"].dictionary {

                                            let notificationLabel = UILabel(frame: CGRect(x: 60, y: 5, width: self.width - 65, height: 35))
                                            notificationLabel.textColor = UIColor.whiteColor()
                                            notificationLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                            notificationLabel.numberOfLines = 2
                                            notificationView.addSubview(notificationLabel)
                                            
                                            let subject = message["subject"]!.string!

                                            let time = message["created_at"]!.string!
                                            
                                            let dateFormatter = NSDateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                            
                                            let activityDateString = dateFormatter.dateFromString(time)
                                            
                                            let timeAgoLabel = UILabel(frame: CGRect(x: 60, y: 37, width: 150, height: 15))
                                            timeAgoLabel.textColor = UIColor.whiteColor()
                                            timeAgoLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
                                            timeAgoLabel.text = timeAgoSinceDate(activityDateString!, numericDates: true)
                                            notificationView.addSubview(timeAgoLabel)
                                            
                                            let index = subject.startIndex.advancedBy(0)
                                            
                                            let userImg = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
                                            notificationView.addSubview(userImg)
                                            
                                            if subject[index] != "B" {
                                                
                                                if let uid = participant["uid"].string {
                                                    
                                                    let userImgUrl = NSURL(string: "https://graph.facebook.com/\(uid)/picture?width=200&height=200")
                                                    
                                                    self.getDataFromUrl(userImgUrl!) { data in
                                                        dispatch_async(dispatch_get_main_queue()) {
                                                            userImg.image = UIImage(data: data!)
                                                            
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                            
                                            
                                            if subject[index] == "S" {
                                                
                                                let songID = subject.componentsSeparatedByString("|")[1]
                                                
                                                let req = Router(OAuthToken: resnateToken, userID: songID)
                                                
                                                request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
                                                    
                                                    if let re = response.result.value {
                                                        
                                                        let song = JSON(re)
                                                        
                                                        let songName = song["name"].string!
                                                        
                                                        notificationLabel.text = "\(name) liked \(songName)"
                                                        
                                                        if let activityID = message["body"]!.string {
                                                            
                                                            let tapActivity = UITapGestureRecognizer()
                                                            tapActivity.addTarget(self, action: "toActivity:")
                                                            notificationView.addGestureRecognizer(tapActivity)
                                                            
                                                            if Int(activityID) >= 0 {
                                                                
                                                                notificationView.tag = Int(activityID)!
                                                                
                                                            }
                                                            
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                            } else if subject[index] == "G" {
                                                
                                                let gigID = subject.componentsSeparatedByString("|")[1]
                                                
                                                let req = Router(OAuthToken: resnateToken, userID: gigID)
                                                
                                                request(req.buildURLRequest("gigs/", path: "")).responseJSON { response in
                                                    
                                                    if let re = response.result.value {
                                                        
                                                        let gig = JSON(re)
                                                        
                                                        if let skID = gig["songkick_id"].int {
                                                            
                                                            let artistLink = "https://api.songkick.com/api/3.0/events/" + String(skID) + ".json?apikey=Pxms4Lvfx5rcDIuR"
                                                            
                                                            request(.GET, artistLink).responseJSON { response in
                                                                if let re = response.result.value {
                                                                    
                                                                    let json = JSON(re)
                                                                    
                                                                    if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                                                        
                                                                        notificationLabel.text = "\(name) liked \(gigName)."
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                        if let activityID = message["body"]!.string {
                                                            
                                                            print(activityID)
                                                            
                                                            let tapActivity = UITapGestureRecognizer()
                                                            tapActivity.addTarget(self, action: "toActivity:")
                                                            notificationView.addGestureRecognizer(tapActivity)
                                                            
                                                            if Int(activityID) >= 0 {
                                                                
                                                                notificationView.tag = Int(activityID)!
                                                                
                                                            }
                                                            
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                            } else if subject[index] == "R" {
                                                
                                                let reviewID = subject.componentsSeparatedByString("|")[1]
                                                
                                                let req = Router(OAuthToken: resnateToken, userID: reviewID)
                                                
                                                request(req.buildURLRequest("reviews/", path: "")).responseJSON { response in
                                                    
                                                    if let re = response.result.value {
                                                        
                                                        let review = JSON(re)
                                                        
                                                        if let reviewable_id = review["reviewable_id"].int {
                                                            
                                                            let tapReview = UITapGestureRecognizer()
                                                            tapReview.addTarget(self, action: "toReview:")
                                                            notificationView.addGestureRecognizer(tapReview)
                                                            notificationView.tag = Int(reviewID)!
                                                            
                                                            if let reviewable_type = review["reviewable_type"].string {
                                                                
                                                                let req = Router(OAuthToken: resnateToken, userID: String(reviewable_id))
                                                                
                                                                if reviewable_type == "PastGig" {
                                                                    
                                                                    request(req.buildURLRequest("past_gigs/", path: "")).responseJSON { response in
                                                                        
                                                                        if let re = response.result.value {
                                                                            
                                                                            let pastGig = JSON(re)
                                                                            
                                                                            if let skID = pastGig["songkick_id"].int {
                                                                                
                                                                                let artistLink = "https://api.songkick.com/api/3.0/events/" + String(skID) + ".json?apikey=Pxms4Lvfx5rcDIuR"
                                                                                
                                                                                request(.GET, artistLink).responseJSON { response in
                                                                                    if let re = response.result.value {
                                                                                        
                                                                                        let json = JSON(re)
                                                                                        
                                                                                        if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                                                                            
                                                                                            notificationLabel.text = "\(name) liked your review of \(gigName)."
                                                                                            
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                } else {
                                                                    
                                                                    request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
                                                                        
                                                                        if let re = response.result.value {
                                                                            
                                                                            let song = JSON(re)
                                                                            
                                                                            if let songID = song["id"].int {
                                                                                
                                                                                if let songName = song["name"].string {
                                                                                    
                                                                                    notificationLabel.text = "\(name) liked your review of \(songName)."
                                                                                    
                                                                                    
                                                                                }
                                                                                
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                            } else if subject[index] == "U" {
                                                
                                                notificationLabel.text = "\(name) is now following you."
                                                let tapUser = UITapGestureRecognizer()
                                                tapUser.addTarget(self, action: "profile:")
                                                notificationView.addGestureRecognizer(tapUser)
                                                notificationView.tag = userID
                                                
                                            } else if subject[index] == "B" {
                                                
                                                let badgeName = subject.componentsSeparatedByString("|")[1]
                                                
                                                userImg.image = UIImage(named: "\(badgeName).png")
                                                notificationLabel.text = "New level: \(badgeName)"
                                                
                                            } else if subject[index] == "C" {
                                                
                                                let typeAndID = subject.componentsSeparatedByString("|")[1]
                                                
                                                let commentableType = typeAndID[index]
                                                
                                                let commentableIndex = typeAndID.startIndex.advancedBy(1)
                                                
                                                let commentableID = typeAndID.substringFromIndex(commentableIndex)
                                                
                                                if commentableType == "S" {
                                                    
                                                    let req = Router(OAuthToken: resnateToken, userID: commentableID)
                                                    
                                                    request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
                                                        
                                                        if let re = response.result.value {
                                                            
                                                            let song = JSON(re)
                                                            
                                                            if let songName = song["name"].string {
                                                                
                                                                notificationLabel.text = "\(name) commented on \(songName)"
                                                                
                                                            }
                                                            
                                                            if let activityURL = message["body"]!.string {
                                                                
                                                                let tapActivity = UITapGestureRecognizer()
                                                                tapActivity.addTarget(self, action: "toActivity:")
                                                                notificationView.addGestureRecognizer(tapActivity)
                                                                
                                                                if let activityURLint = Int(activityURL) {
                                                                    
                                                                    notificationView.tag = activityURLint
                                                                    
                                                                }
                                                                
                                                                
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                } else if commentableType == "R" {
                                                    
                                                    let req = Router(OAuthToken: resnateToken, userID: commentableID)
                                                    
                                                    request(req.buildURLRequest("reviews/", path: "")).responseJSON { response in
                                                        
                                                        if let re = response.result.value {
                                                            
                                                            let review = JSON(re)
                                                            
                                                            if let reviewable_id = review["reviewable_id"].int {
                                                                
                                                                let tapReview = UITapGestureRecognizer()
                                                                tapReview.addTarget(self, action: "toReview:")
                                                                notificationView.addGestureRecognizer(tapReview)
                                                                notificationView.tag = Int(commentableID)!
                                                                
                                                                if let reviewable_type = review["reviewable_type"].string {
                                                                    
                                                                    let req = Router(OAuthToken: resnateToken, userID: String(reviewable_id))
                                                                    
                                                                    if reviewable_type == "PastGig" {
                                                                        
                                                                        request(req.buildURLRequest("past_gigs/", path: "")).responseJSON { response in
                                                                            
                                                                            if let re = response.result.value {
                                                                                
                                                                                let pastGig = JSON(re)
                                                                                
                                                                                if let skID = pastGig["songkick_id"].int {
                                                                                    
                                                                                    let artistLink = "https://api.songkick.com/api/3.0/events/" + String(skID) + ".json?apikey=Pxms4Lvfx5rcDIuR"
                                                                                    
                                                                                    request(.GET, artistLink).responseJSON { response in
                                                                                        if let re = response.result.value {
                                                                                            
                                                                                            let json = JSON(re)
                                                                                            
                                                                                            if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                                                                                
                                                                                                notificationLabel.text = "\(name) liked your review of \(gigName)."
                                                                                                
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                        
                                                                    } else {
                                                                        
                                                                        request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
                                                                            
                                                                            if let re = response.result.value {
                                                                                
                                                                                let song = JSON(re)
                                                                                
                                                                                if let songID = song["id"].int {
                                                                                    
                                                                                    if let songName = song["name"].string {
                                                                                        
                                                                                        notificationLabel.text = "\(name) liked your review of \(songName)."
                                                                                        
                                                                                        
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
                        
                    }
                    
                    y += 70
                    
                }
                
                self.loadingView.stopAnimating()
                
                self.scrollView.contentSize.height = CGFloat(y)
                
                self.loadingView.frame.origin.y = CGFloat(y)
                
                self.totalY = y
                
                self.page += 1
                
                self.scrollView.tag = 0
                
            }
        }
        
        let parameters = ["token" : "\(resnateToken)", "type" : "notification"]
        
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://www.resnate.com/api/markAsRead/")!)
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
            
            
            
            let tabArray = self.tabBarController?.tabBar.items as NSArray!
            
            if let profileTab = tabArray.objectAtIndex(1) as? UITabBarItem {
                
                profileTab.badgeValue = nil
                
                let profileNav = self.tabBarController?.viewControllers![1] as! UINavigationController
                let profileView = profileNav.viewControllers[0] as! ScrollProfileViewController
                
                profileView.notificationCount = 0
                
            }
            
            
            
        }
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.scrollView.delegate = self

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        self.navigationItem.title = "Notifications"
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        getNotifications(self.page, totalY: self.totalY)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) && scrollView.contentSize.height > 1 && scrollView.tag != -1) {
            
            self.getNotifications(self.page, totalY: self.totalY)
            
        }
        
    }

}
