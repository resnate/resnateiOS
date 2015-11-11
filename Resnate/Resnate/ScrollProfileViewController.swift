//
//  ScrollProfileViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 05/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class ScrollProfileViewController: UIViewController, VideoPlayerUIViewDelegate {
    
    var ID = 0
    
    var notificationCount = 0
    
    var resnateToken = ""
    
    var webURL = ""
    
    let ytPlayer = VideoPlayer.sharedInstance
    
    var notificationView = UILabel(frame: CGRect(x: 10, y: 250, width: 150, height: 40))
    
    var badgesCount = UILabel(frame: CGRect(x: 105, y: 14, width: 44, height: 30))
    
    @IBOutlet weak var badgesView: UIView!
    
    
    func tappedReview(sender:UITapGestureRecognizer) {
        
        let userReviewsViewController:UserReviewsViewController = UserReviewsViewController(nibName: "UserReviewsViewController", bundle: nil)
        
        userReviewsViewController.ID = sender.view!.tag
        
        
        self.navigationController?.pushViewController(userReviewsViewController, animated: true)
        
        
        
        
    }
    
    
    
    
    
    
    func tappedPast(sender:UITapGestureRecognizer) {
        
        let pastGigsViewController:PastGigsViewController = PastGigsViewController(nibName: "PastGigsViewController", bundle: nil)
        
        pastGigsViewController.ID = sender.view!.tag
        
        
        self.navigationController?.pushViewController(pastGigsViewController, animated: true)
        
        
        
        
    }
    
    
    
    func downloadImage(url:NSURL){
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.profilePic.image = UIImage(data: data!)
            }
        }
    }
    
    
    
    
    
    
    
    func tappedUpcoming(sender:UITapGestureRecognizer){
        let upcomingGigsViewController:UpcomingGigsViewController = UpcomingGigsViewController(nibName: "UpcomingGigsViewController", bundle: nil)
        
        upcomingGigsViewController.ID = sender.view!.tag
        
        
        
        self.navigationController?.pushViewController(upcomingGigsViewController, animated: true)
    }
    
    func tappedPlaylists(sender:UITapGestureRecognizer){
        
        let userPlaylistsViewController:UserPlaylistsViewController = UserPlaylistsViewController(nibName: "UserPlaylistsViewController", bundle: nil)
        
        
        userPlaylistsViewController.ID = sender.view!.tag
        
        self.navigationController?.pushViewController(userPlaylistsViewController, animated: true)
        
    }
    
    
    
    
    func returnUserData()
    {
        
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        if self.ID != Int((dictionary!["userID"] as! String))! {
            
            let followView = UILabel(frame: CGRect(x: 10, y: 250, width: 100, height: 40))
            
            followView.textAlignment = .Center
            
            followView.font = UIFont(name: "HelveticaNeue-Light", size: 18)
            
            followView.textColor = UIColor.whiteColor()
            
            let tapFollow = UITapGestureRecognizer()
            
            followView.addGestureRecognizer(tapFollow)
            
            followView.userInteractionEnabled = true
            
            followView.tag = self.ID
            
            self.scrollView.addSubview(followView)
            
            let req = Router(OAuthToken: resnateToken, userID: dictionary!["userID"] as! String)
            
            request(req.buildURLRequest("users/", path: "/followeeIDs")).responseJSON { response in
                
                let json = JSON(response.result.value!)
                
                var followees = [Int]()
                
                if let users = json.array {
                    
                    var index = 0
                    
                    for user in users {
                        
                        if let followeeID = user["id"].int {
                            
                            followees.insert(followeeID, atIndex: index)
                            
                            index += 1
                            
                        }
                        
                    }
                    
                    if followees.indexOf(self.ID) != nil {
                        
                        followView.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                        
                        followView.text = "Unfollow"
                        
                        tapFollow.addTarget(self, action: "unfollow:")
                        
                    } else {
                        
                        followView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
                        
                        followView.text = "Follow"
                        
                        tapFollow.addTarget(self, action: "follow:")
                    }
                    
                }
            }
            
        } else {
            
            self.scrollView.addSubview(self.notificationView)
            
            self.notificationView.textColor = UIColor.whiteColor()
            
            self.notificationView.textAlignment = .Center
            
            
            let profileNav = self.tabBarController?.viewControllers![1] as! UINavigationController
            
            let profileView = profileNav.viewControllers[0] as! ScrollProfileViewController
            
            
            let tapNotifications = UITapGestureRecognizer()
            tapNotifications.addTarget(self, action: "toNotifications:")
            self.notificationView.tag = Int((dictionary!["userID"] as! String))!
            self.notificationView.addGestureRecognizer(tapNotifications)
            self.notificationView.userInteractionEnabled = true
            
            
            if profileView.notificationCount > 0 {
                
                self.notificationView.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                
                if profileView.notificationCount == 1 {
                    
                    self.notificationView.text = "\(profileView.notificationCount) Notification"
                    
                } else {
                    
                    self.notificationView.text = "\(profileView.notificationCount) Notifications"
                    
                }
                
                self.notificationView.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                
                
            } else {
                
                self.notificationView.font = UIFont(name: "HelveticaNeue-Light", size: 18)
                
                self.notificationView.text = "Notifications"
                
                self.notificationView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
                
            }
            
        }
    
        let req = Router(OAuthToken: self.resnateToken, userID: String(self.ID))
        
        request(req.buildURLRequest("users/", path: "/level")).responseJSON { response in
            
            if let re = response.result.value {
                
                let json = JSON(re)
                
                if let levelText = json["level_name"].string {
                    self.miniBadge.image = UIImage(named: "\(levelText).png")
                }
                
                if let points = json["points"].string {
                    self.profilePoints.text = points
                }
                
                if let badges = json["badges"].array {
                    var x = 10 as Int
                    var i = 0
                    self.badgesCount.text = String(badges.count)
                    
                    if badges.count > 0 {
                        
                        let tapBadges = UITapGestureRecognizer()
                        tapBadges.addTarget(self, action: "toBadges:")
                        self.badgesView.addGestureRecognizer(tapBadges)
                        self.badgesView.tag = self.ID
                        self.badgesView.userInteractionEnabled = true
                        
                        let reverseBadges = badges.reverse()
                        for badge in reverseBadges {
                            if i <= 2 {
                                let imageName = "\(badge).png"
                                let image = UIImage(named: imageName)
                                let imageView = UIImageView(image: image!)
                                
                                imageView.frame = CGRect(x: x, y: 60, width: 80, height: 80)
                                self.badgesView.addSubview(imageView)
                                x += 110
                                i += 1
                            }
                        }
                        
                    }
                    
                }
                
                if let followers = json["followers"].string {
                    self.followerCount.text = followers
                    
                    let tapRec = UITapGestureRecognizer()
                    
                    
                    tapRec.addTarget(self, action: "followers:")
                    self.followerView.addGestureRecognizer(tapRec)
                    self.followerView.tag = self.ID
                    self.followerView.userInteractionEnabled = true
                }
                
                if let following = json["following"].string {
                    self.followingCount.text = following
                    
                    let tapRec = UITapGestureRecognizer()
                    
                    
                    tapRec.addTarget(self, action: "followees:")
                    self.followeeView.addGestureRecognizer(tapRec)
                    self.followeeView.tag = self.ID
                    self.followeeView.userInteractionEnabled = true
                }
                
            }

        }
        
        request(req.buildURLRequest("users/", path: "/profile")).responseJSON { response in
            
            if let re = response.result.value {
                
                let json = JSON(re)
                
                let name = json["name"].string!
                self.navigationItem.title = name
                
                self.profileName.text = name
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                
                let first_name = json["first_name"].string!
                
                if let userID = json["userID"].string {
                    let imgUrl = NSURL(string: "https://graph.facebook.com/\(userID)/picture?width=200&height=200")
                    self.downloadImage(imgUrl!)
                }
                
                
                
                
                if let review = json["review"].string {
                    
                    let reviewView = UIView(frame: CGRect(x: 0, y: 525, width: 350, height: 100))
                    self.scrollView.addSubview(reviewView)
                    
                    let reviewLabel = UILabel(frame: CGRect(x: 120, y: 0, width: 200, height: 100))
                    setSKLabelText(reviewLabel)
                    reviewView.addSubview(reviewLabel)
                    
                    reviewLabel.text = "\(first_name)'s Reviews"
                    
                    if review != "" {
                        
                        if let type = json["reviewable_type"].string {
                            
                            let tapRec = UITapGestureRecognizer()
                            
                            tapRec.addTarget(self, action: "tappedReview:")
                            reviewView.addGestureRecognizer(tapRec)
                            reviewView.tag = self.ID
                            reviewView.userInteractionEnabled = true
                            
                            if type == "PastGig" {
                                
                                request(.GET, review).responseJSON { response in
                                    
                                    var json = JSON(response.result.value!)
                                    
                                    if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                        
                                        
                                        
                                        let artistView = getArtistPic(artist)
                                        artistView.frame = CGRect(x: 10, y: 0, width: 100, height: 100)
                                        reviewView.addSubview(artistView)
                                        
                                    }
                                }
                                
                            } else if type == "Song" {
                                
                                let songImgUrl = NSURL(string: "\(review)")
                                let reviewSongImg = UIImageView(frame: CGRect(x: 10, y: 0, width: 100, height: 100))
                                self.getDataFromUrl(songImgUrl!) { data in
                                    dispatch_async(dispatch_get_main_queue()) {
                                        
                                        reviewSongImg.image = UIImage(data: data!)
                                        
                                        
                                        
                                    }
                                }
                                reviewView.addSubview(reviewSongImg)
                                
                            }
                            
                        }
                        
                        
                        
                    }
                    else {
                        
                        let imageName = "review"
                        let image = UIImage(named: imageName)
                        let imageView = UIImageView(image: image!)
                        
                        imageView.frame = CGRect(x: 10, y: 0, width: 100, height: 100)
                        reviewView.addSubview(imageView)
                        
                        
                        if self.ID == Int((dictionary!["userID"] as! String))! {
                            
                            reviewLabel.text = "You haven't written any reviews yet."
                            
                        } else {
                            reviewLabel.text = "\(first_name) has not written any reviews yet."
                        }
                    }
                    
                    
                }
                
                if json["songkickID"] != nil {
                    
                    
                    if json["songkickID"] != "" {
                        
                        if let pastGig = json["pastGig"].string {
                            request(.GET, pastGig).responseJSON { response in
                                
                                var json = JSON(response.result.value!)
                                if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                    
                                    
                                    let pastGigView = UIView(frame: CGRect(x: 0, y: 635, width: 350, height: 100))
                                    self.scrollView.addSubview(pastGigView)
                                    
                                    
                                    let artistView = getArtistPic(artist)
                                    artistView.frame = CGRect(x: 10, y: 0, width: 100, height: 100)
                                    pastGigView.addSubview(artistView)
                                    
                                    
                                    
                                    
                                    let userPastGigsLabel = UILabel(frame: CGRect(x: 120, y: 30, width: 200, height: 30))
                                    setSKLabelText(userPastGigsLabel)
                                    userPastGigsLabel.text = "Past Gigs & Reviews"
                                    pastGigView.addSubview(userPastGigsLabel)
                                    
                                    
                                    
                                    let tapRec = UITapGestureRecognizer()
                                    
                                    
                                    tapRec.addTarget(self, action: "tappedPast:")
                                    pastGigView.addGestureRecognizer(tapRec)
                                    pastGigView.tag = self.ID
                                    pastGigView.userInteractionEnabled = true
                                    
                                }
                            }
                        }
                        
                        
                        
                        if let upcomingGig = json["upcomingGig"].string {
                            request(.GET, upcomingGig).responseJSON { response in
                                
                                let upcomingGigView = UIView(frame: CGRect(x: 0, y: 745, width: 350, height: 100))
                                self.scrollView.addSubview(upcomingGigView)
                                
                                
                                
                                let upcomingGigsLabel = UILabel(frame: CGRect(x: 120, y: 0, width: 200, height: 100))
                                setSKLabelText(upcomingGigsLabel)
                                
                                upcomingGigView.userInteractionEnabled = true
                                
                                upcomingGigsLabel.numberOfLines = 2
                                upcomingGigView.addSubview(upcomingGigsLabel)
                                
                                
                                if response.result.value != nil {
                                    var json = JSON(response.result.value!)
                                    
                                    if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                        
                                        
                                        let artistView = getArtistPic(artist)
                                        artistView.frame = CGRect(x: 10, y: 0, width: 100, height: 100)
                                        upcomingGigView.addSubview(artistView)
                                        
                                        
                                        upcomingGigsLabel.text = "Upcoming Gigs"
                                        
                                        let tapRec = UITapGestureRecognizer()
                                        
                                        
                                        tapRec.addTarget(self, action: "tappedUpcoming:")
                                        upcomingGigView.tag = self.ID
                                        upcomingGigView.addGestureRecognizer(tapRec)
                                        
                                    }
                                }
                                    
                                else {
                                    
                                    
                                    if self.ID == Int((dictionary!["userID"] as! String))! {
                                        
                                        
                                        upcomingGigsLabel.text = "Visit Songkick.com to find concerts!"
                                        
                                        
                                        
                                        let songkickLogoView = UIImageView(image: UIImage(named: "songkickLogoWhite"))
                                        
                                        songkickLogoView.frame = CGRect(x: 10, y: 0, width: 100, height: 100)
                                        
                                        upcomingGigView.addSubview(songkickLogoView)
                                        
                                        let tapRec = UITapGestureRecognizer()
                                        
                                        
                                        tapRec.addTarget(self, action: "loadWeb")
                                        self.webURL = "https://www.songkick.com"
                                        upcomingGigView.addGestureRecognizer(tapRec)
                                        
                                    } else {
                                        
                                        upcomingGigsLabel.text = "Recommend a gig to \(first_name)!"
                                        
                                        
                                        
                                        let gigView = UIImageView(image: UIImage(named: "gig"))
                                        
                                        gigView.frame = CGRect(x: 10, y: 0, width: 100, height: 100)
                                        
                                        upcomingGigView.addSubview(gigView)
                                        
                                        
                                        
                                    }
                                }
                            }
                        }
                        
                    } else {
                        
                        let noSongkickView = UIView(frame: CGRect(x: 0, y: 635, width: 350, height: 220))
                        
                        self.scrollView.addSubview(noSongkickView)
                        
                        let noSongkickLabel = UILabel(frame: CGRect(x: 120, y: 60, width: 200, height: 100))
                        
                        setSKLabelText(noSongkickLabel)
                        
                        noSongkickLabel.numberOfLines = 4
                        
                        let songkickLogoView = UIImageView(image: UIImage(named: "songkickLogoWhite"))
                        
                        songkickLogoView.frame = CGRect(x: 10, y: 60, width: 100, height: 100)
                        
                        noSongkickView.addSubview(songkickLogoView)
                        
                        noSongkickView.addSubview(noSongkickLabel)
                        
                        
                        if self.ID == Int((dictionary!["userID"] as! String))! {
                            
                            noSongkickLabel.text = "Create a Songkick account to let friends know about your gigs!"
                            
                            let tapRec = UITapGestureRecognizer()
                            
                            
                            tapRec.addTarget(self, action: "loadWeb")
                            self.webURL = "https://www.songkick.com"
                            noSongkickView.addGestureRecognizer(tapRec)
                            
                            
                        }
                        else {
                            
                            noSongkickLabel.text = "\(first_name) has no Songkick account to display their gigs, tell them to sign up!"
                        }
                    }
                }
                
                
                
                
                
                if let playlist = json["playlist"].string {
                    
                    let playlistUberView = UIView(frame: CGRect(x: 0, y: 855, width: 350, height: 100))
                    self.scrollView.addSubview(playlistUberView)
                    
                    let playlistLabel = UILabel(frame: CGRect(x: 120, y: 0, width: 200, height: 100))
                    setSKLabelText(playlistLabel)
                    playlistLabel.numberOfLines = 4
                    playlistUberView.addSubview(playlistLabel)
                    
                    if playlist != "" {
                        
                        
                        let playlistUrl = NSURL(string: "\(playlist)")
                        let playlistImg = UIImageView(frame: CGRect(x: 10, y: 0, width: 100, height: 100))
                        self.getDataFromUrl(playlistUrl!) { data in
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                playlistImg.image = UIImage(data: data!)
                                
                                
                                
                            }
                        }
                        playlistUberView.addSubview(playlistImg)
                        
                        
                        
                        playlistLabel.text = "\(first_name)'s Playlists"
                        
                        
                        let tapRec = UITapGestureRecognizer()
                        
                        
                        tapRec.addTarget(self, action: "tappedPlaylists:")
                        playlistUberView.tag = self.ID
                        playlistUberView.addGestureRecognizer(tapRec)
                        playlistUberView.userInteractionEnabled = true
                        
                        
                    } else {
                        
                        let noPlaylistView = UIImageView(image: UIImage(named: "music"))
                        
                        noPlaylistView.frame = CGRect(x: 10, y: 0, width: 100, height: 100)
                        
                        playlistUberView.addSubview(noPlaylistView)
                        
                        if self.ID == Int((dictionary!["userID"] as! String))! {
                            
                            playlistLabel.text = "Tap on the Artists tab and search for music to create playlists!"
                            
                        }
                            
                        else {
                            
                            playlistLabel.text = "\(first_name) hasn't created any playlists yet, send them some songs!"
                            
                        }
                    }
                    
                }
                
            }
            
            
        }
        
        
        
        
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func loadWeb(){
        let webViewController:WebViewController = WebViewController(nibName: "WebViewController", bundle: nil)
        
        
        
        webViewController.webURL = self.webURL
        
        self.presentViewController(webViewController, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var profilePoints: UILabel!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var miniBadge: UIImageView!
    
    @IBOutlet weak var followerCount: UILabel!
    
    @IBOutlet weak var followingCount: UILabel!
    
    @IBOutlet weak var followerView: UIView!
    
    @IBOutlet weak var followeeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ytPlayer.delegate = self
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        self.scrollView.addSubview(self.badgesView)
        self.badgesView.addSubview(self.badgesCount)
        badgesCount.textColor = UIColor.whiteColor()
        badgesCount.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
    }
    
    override func viewWillAppear(animated: Bool) {
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        self.resnateToken = dictionary!["token"] as! String
        
        if self.ID == 0 {
            
            self.ID = Int((dictionary!["userID"] as! String))!
            self.returnUserData()
            
        } else {
            self.returnUserData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: 320, height:965)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func unfollow(sender: AnyObject) {
        
        let followView = UILabel(frame: CGRect(x: 10, y: 250, width: 100, height: 40))
        
        followView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        followView.text = "Follow"
        
        followView.textAlignment = .Center
        
        followView.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        
        followView.textColor = UIColor.whiteColor()
        
        let tapFollow = UITapGestureRecognizer()
        
        followView.addGestureRecognizer(tapFollow)
        
        tapFollow.addTarget(self, action: "follow:")
        
        followView.userInteractionEnabled = true
        
        followView.tag = self.ID
        
        sender.view!.removeFromSuperview()
        
        self.scrollView.addSubview(followView)
        
    }
    
    func follow(sender: AnyObject) {
        
        let parameters =  ["token": "\(self.resnateToken)", "user": sender.view!.tag ]
        
        
        
        let URL = NSURL(string: "https://www.resnate.com/api/users/follow")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters as? [String : AnyObject]).0).responseJSON { response in
            
            if let re = response.result.value {
                
                let success = JSON(re)
                
                let followView = UILabel(frame: CGRect(x: 10, y: 250, width: 100, height: 40))
                
                followView.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                
                followView.text = "Unfollow"
                
                followView.textAlignment = .Center
                
                followView.font = UIFont(name: "HelveticaNeue-Light", size: 18)
                
                followView.textColor = UIColor.whiteColor()
                
                let tapFollow = UITapGestureRecognizer()
                
                followView.addGestureRecognizer(tapFollow)
                
                tapFollow.addTarget(self, action: "unfollow:")
                
                followView.userInteractionEnabled = true
                
                followView.tag = self.ID
                
                sender.view!.removeFromSuperview()
                
                self.scrollView.addSubview(followView)
                
            }
            
        }
        
        
        
    }
    
    func toNotifications(sender: AnyObject) {
        
        let notificationsViewController = NotificationsViewController(nibName: "NotificationsViewController", bundle: nil)
        notificationsViewController.ID = self.ID
        self.navigationController?.pushViewController(notificationsViewController, animated: true)
        
    }
    
    func toBadges(sender: AnyObject) {
        
        let badgesViewController = BadgesViewController(nibName: "BadgesViewController", bundle: nil)
        badgesViewController.ID = sender.view!.tag
        self.navigationController?.pushViewController(badgesViewController, animated: true)
        
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}