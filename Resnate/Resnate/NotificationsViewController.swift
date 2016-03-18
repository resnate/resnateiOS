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
    
    var notificationCount = 0
    
    var moreThanOne = false
    
    var totalY = 10
    
    var page = 1
    
    let width = Int(UIScreen.mainScreen().bounds.width)
    
    let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
    
    var resnateToken = ""
    
    var resnateID = ""
    
    let loadingView = UIActivityIndicatorView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 - 25, y: 30, width: 50, height: 50))
    
    let noNotifs = UILabel(frame: CGRect(x: Int(UIScreen.mainScreen().bounds.width)/2 - 150, y: 140, width: 300, height: 67))
    
    var refreshControl: UIRefreshControl!
    
    func getNotification(notification: JSON, y: Int){

        let notificationView = UIView(frame: CGRect(x: 0, y: y, width: self.width, height: 60))
        notificationView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:0.5)
        self.scrollView.addSubview(notificationView)
        notificationView.userInteractionEnabled = true
        
        if let sender = notification["sender"].dictionary {
            
            if let userID = sender["id"]!.int {
                
                if Int(resnateID) != userID {
                    
                    if let name = sender["name"]!.string {
                        
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
                                
                                if let uid = sender["uid"]!.string {
                                    
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
                                                
                                                let req = Router(OAuthToken: self.resnateToken, userID: String(reviewable_id))
                                                
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
                                
                            } else if subject[index] == "P" {
                                
                                let playlistID = subject.componentsSeparatedByString("|")[1]
                                
                                let req = Router(OAuthToken: resnateToken, userID: playlistID)
                                
                                request(req.buildURLRequest("playlists/", path: "")).responseJSON { response in
                                    
                                    if let re = response.result.value {
                                        
                                        let playlist = JSON(re)
                                        
                                        if let playlistName = playlist["name"].string {
                                            
                                            notificationLabel.text = "\(name) is now following \(playlistName)."
                                            
                                            
                                            
                                            
                                        }
                                        
                                    }
                                }
                                
                            } else if subject[index] == "C" {
                                
                                let typeAndID = subject.componentsSeparatedByString("|")[1]
                                
                                let commentableType = typeAndID[index]
                                
                                let commentableIndex = typeAndID.startIndex.advancedBy(1)
                                
                                let activityID = typeAndID.substringFromIndex(commentableIndex)
                                
                                let tapActivity = UITapGestureRecognizer()
                                tapActivity.addTarget(self, action: "toActivity:")
                                notificationView.addGestureRecognizer(tapActivity)
                                
                                notificationView.tag = Int(activityID)!

                                let req = Router(OAuthToken: resnateToken, userID: activityID)
                                
                                request(req.buildURLRequest("", path: "/activities")).responseJSON { response in
                                    
                                    if let re = response.result.value {
                                        
                                        let activity = JSON(re)
                                        
                                        if let commentableID = activity["trackable_id"].int {
                                            
                                            if commentableType == "S" {
                                                
                                                let req = Router(OAuthToken: self.resnateToken, userID: String(commentableID))
                                                
                                                request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
                                                    
                                                    if let re = response.result.value {
                                                        
                                                        let song = JSON(re)

                                                        if let songName = song["name"].string {
                                                            
                                                            notificationLabel.text = "\(name) commented on \(songName)"
                                                            
                                                        }
                                                        
                                                    }
                                                }
                                                
                                            } else if commentableType == "R" {
                                                
                                                let req = Router(OAuthToken: self.resnateToken, userID: String(commentableID))
                                                            
                                                            request(req.buildURLRequest("reviews/", path: "")).responseJSON { response in
                                                                
                                                                if let re = response.result.value {
                                                                    
                                                                    let review = JSON(re)
                                                                    
                                                                    let reviewID = review["id"].int!
                                                                    
                                                                    let tapActivity = UITapGestureRecognizer()
                                                                    tapActivity.addTarget(self, action: "toReview:")
                                                                    notificationView.addGestureRecognizer(tapActivity)
                                                                    notificationView.tag = reviewID
                                                                    
                                                                    if let reviewable_id = review["reviewable_id"].int {
                                                                        
                                                                        if let reviewable_type = review["reviewable_type"].string {
                                                                            
                                                                            if let reviewer_id = review["user_id"].int {
                                                                                
                                                                                let req = Router(OAuthToken: self.resnateToken, userID: String(reviewable_id))
                                                                                
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
                                                                                                            
                                                                                                            if reviewer_id == userID {
                                                                                                                
                                                                                                                notificationLabel.text = "\(name) commented on your review of \(gigName)."
                                                                                                                
                                                                                                            } else {
                                                                                                                
                                                                                                                notificationLabel.text = "\(name) commented on a review of \(gigName)."
                                                                                                                
                                                                                                            }
                                                                                                            
                                                                                                            
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
                                                                                                    
                                                                                                    if reviewer_id == userID {
                                                                                                    
                                                                                                    notificationLabel.text = "\(name) commented on your review of \(songName)."
                                                                                                        
                                                                                                    } else {
                                                                                                        
                                                                                                        notificationLabel.text = "\(name) commented on a review of \(songName)."
                                                                                                        
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
                        
                        
                    }
                    
                    
                }
                
            }
        }
        
        self.totalY += 70
        
    }
    
    func getNotifications(page: Int, totalY: Int) {
        
        if let dic = dictionary {
            
            self.resnateToken = dic["token"] as! String
            
            
            self.scrollView.tag = -1
            
            self.scrollView.addSubview(loadingView)
            
            self.loadingView.startAnimating()
            
            self.resnateID = dictionary!["userID"] as! String
            
            let req = Router(OAuthToken: resnateToken, userID: resnateToken)
            
            request(req.buildURLRequest("messages/", path: "/notifications/\(page)")).responseJSON { response in
                
                if let re = response.result.value {
                    
                    let notifications = JSON(re)
                    
                    if notifications.count == 0 {
                        self.loadingView.stopAnimating()
                        if self.moreThanOne == false {
                        self.noNotifs.textColor = UIColor.whiteColor()
                        self.noNotifs.textAlignment = .Center
                        self.noNotifs.font = UIFont(name: "HelveticaNeue-Light", size: 18)
                        self.noNotifs.text = "No notifications.\nShare some music or a concert review\nwith your friends!"
                        self.noNotifs.numberOfLines = 3
                        self.scrollView.addSubview(self.noNotifs)
                        }
                    } else {
                        self.moreThanOne = true
                        self.noNotifs.removeFromSuperview()
                        for (_, notification) in notifications {
                            
                            self.getNotification(notification, y: self.totalY)
                            
                        }
                        
                        self.loadingView.stopAnimating()
                        
                        self.scrollView.contentSize.height = CGFloat(self.totalY)
                        
                        self.loadingView.frame.origin.y = CGFloat(self.totalY)
                        
                        self.page += 1
                        
                        self.scrollView.tag = 0
                    }
                    
                } else {
                    if self.moreThanOne == false {
                    self.loadingView.stopAnimating()
                    self.noNotifs.textColor = UIColor.whiteColor()
                    self.noNotifs.textAlignment = .Center
                    self.noNotifs.font = UIFont(name: "HelveticaNeue-Light", size: 18)
                    self.noNotifs.text = "No notifications.\nShare some music or a concert review\nwith your friends!"
                    self.noNotifs.numberOfLines = 3
                    self.scrollView.addSubview(self.noNotifs)
                    }
                }
            }
            
            let parameters = ["token" : "\(resnateToken)", "type" : "notification"]
            
            let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://www.resnate.com/api/markAsRead/")!)
            mutableURLRequest.HTTPMethod = Method.POST.rawValue
            mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
            
            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                
                
                
                let tabArray = self.tabBarController?.tabBar.items as NSArray!
                
                if let notificationTab = tabArray.objectAtIndex(3) as? UITabBarItem {
                    
                    notificationTab.badgeValue = nil
                    
                    let application = UIApplication.sharedApplication()
                    
                    application.applicationIconBadgeNumber = 0
                    
                    let notificationNav = self.tabBarController?.viewControllers![3] as! UINavigationController
                    let notificationView = notificationNav.viewControllers[0] as! NotificationsViewController
                    
                    notificationView.notificationCount = 0
                    
                }
            }
        } else {
            if self.moreThanOne == false {
                self.noNotifs.textColor = UIColor.whiteColor()
                self.noNotifs.textAlignment = .Center
                self.noNotifs.font = UIFont(name: "HelveticaNeue-Light", size: 18)
                self.noNotifs.text = "No notifications.\nShare some music or a concert review\nwith your friends!"
                self.noNotifs.numberOfLines = 3
                self.scrollView.addSubview(self.noNotifs)
            }
            
        }
        
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.translucent = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.scrollView.delegate = self

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        self.navigationItem.title = "Notifications"
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.scrollView.addSubview(self.refreshControl)
        
        getNotifications(self.page, totalY: self.totalY)
        
    }
    
    func refresh(){
        self.scrollView.subviews.map({ $0.removeFromSuperview() })
        self.page = 1
        self.totalY = 10
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.scrollView.addSubview(self.refreshControl)
        getNotifications(self.page, totalY: self.totalY)
        self.refreshControl.endRefreshing()
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
