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
    
    var resnateToken = ""
    
    var webURL = ""
    
    let ytPlayer = VideoPlayer.sharedInstance
    
    
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
        
        
        
        
        
        
        let req = Router(OAuthToken: self.resnateToken, userID: String(self.ID))
        
        
        
        request(req.buildURLRequest("users/", path: "/level")).responseJSON { response in

                var json = JSON(response.result.value!)
                if let levelText = json["level_name"].string {
                    self.miniBadge.image = UIImage(named: "\(levelText).png")
                }
                
                if let points = json["points"].string {
                    self.profilePoints.text = points
                }
                
                if let badges = json["badges"].array {
                    var x = 10 as Int
                    for badge in badges {
                        let imageName = "\(badge).png"
                        let image = UIImage(named: imageName)
                        let imageView = UIImageView(image: image!)
                        
                        imageView.frame = CGRect(x: x, y: 305, width: 80, height: 80)
                        self.scrollView.addSubview(imageView)
                        x += 110
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
        
        request(req.buildURLRequest("users/", path: "/profile")).responseJSON { response in
            
                let json = JSON(response.result.value!)
                
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
                    
                    let reviewView = UIView(frame: CGRect(x: 0, y: 480, width: 350, height: 100))
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
                        
                        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                        
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
                                        
                                        
                                        let pastGigView = UIView(frame: CGRect(x: 0, y: 600, width: 350, height: 100))
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
                                
                                let upcomingGigView = UIView(frame: CGRect(x: 0, y: 720, width: 350, height: 100))
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
                                    
                                    let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                                    
                                    
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
                        
                        let noSongkickView = UIView(frame: CGRect(x: 0, y: 600, width: 350, height: 220))
                        
                        self.scrollView.addSubview(noSongkickView)
                        
                        let noSongkickLabel = UILabel(frame: CGRect(x: 120, y: 60, width: 200, height: 100))
                        
                        setSKLabelText(noSongkickLabel)
                        
                        noSongkickLabel.numberOfLines = 4
                        
                        let songkickLogoView = UIImageView(image: UIImage(named: "songkickLogoWhite"))
                        
                        songkickLogoView.frame = CGRect(x: 10, y: 60, width: 100, height: 100)
                        
                        noSongkickView.addSubview(songkickLogoView)
                        
                        noSongkickView.addSubview(noSongkickLabel)
                        
                        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                        
                        
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
                    
                    let playlistUberView = UIView(frame: CGRect(x: 0, y: 840, width: 350, height: 100))
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
                        
                        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                        
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
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func refreshView(refresh: UIRefreshControl){
        delay(0.4) {
            self.returnUserData()
            refresh.endRefreshing()
        }
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: "refreshView:", forControlEvents: .ValueChanged)
        self.scrollView.insertSubview(refreshControl, atIndex: 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
        
        
        
        
        
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
        scrollView.contentSize = CGSize(width: 320, height:950)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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