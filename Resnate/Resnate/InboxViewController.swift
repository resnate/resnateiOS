//
//  InboxViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 01/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController {
    
    let width = Int(UIScreen.mainScreen().bounds.width)
    
    let ytPlayer = VideoPlayer.sharedInstance
    
    var songs: [AnyObject] = []
    
    @IBOutlet weak var inboxScroll: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.inboxScroll.subviews.map({ $0.removeFromSuperview() })
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: resnateToken)
        
        request(req.buildURLRequest("messages/", path: "/index")).responseJSON { response in
            
                let conversations = JSON(response.result.value!)
                
                var y = 10
                
                for (index, conversation) in conversations {
                    
                    self.songs.insert(["": ""], atIndex: Int(index)!)
                    
                    let convoView = UIView(frame: CGRect(x: 0, y: y, width: self.width, height: 240))
                    convoView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:0.5)
                    self.inboxScroll.addSubview(convoView)
                    
                    if let message = conversation["message"].dictionary {
                        
                        let subject = message["subject"]!.string!
                        
                        let time = message["created_at"]!.string!
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                            
                        let activityDateString = dateFormatter.dateFromString(time)
                            
                        let timeAgoLabel = UILabel(frame: CGRect(x: 10, y: 105, width: 150, height: 14))
                        timeAgoLabel.textColor = UIColor.whiteColor()
                        timeAgoLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                        timeAgoLabel.text = timeAgoSinceDate(activityDateString!, numericDates: true)
                        convoView.addSubview(timeAgoLabel)
                        
                        let likeSong = UIImageView(frame: CGRect(x: 125, y: 200, width: 30, height: 30))
                        likeSong.image = UIImage(named: "likeWhite")
                        convoView.addSubview(likeSong)
                        
                        let share = UIImageView(frame: CGRect(x: 175, y: 200, width: 30, height: 30))
                        share.image = UIImage(named: "Share")
                        convoView.addSubview(share)
                        
                        if let body = message["body"]!.string {
                            let bodyLabel = UILabel(frame: CGRect(x: 120, y: 130, width: 200, height: 60))
                            bodyLabel.text = body
                            bodyLabel.textColor = UIColor.whiteColor()
                            bodyLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                            bodyLabel.numberOfLines = 0
                            convoView.addSubview(bodyLabel)
                        }
                        
                        if let sender = message["sender_id"]!.int {
                            
                            if let participants = conversation["participants"].array {
                                
                                var x = 10
                                
                                var i = 0
                                
                                for participant in participants {
                                    
                                    if let name = participant["name"].string {
                                        
                                        
                                        if let uid = participant["uid"].string {
                                            
                                            let inboxUserImg = UIImageView(frame: CGRect(x: x, y: 10, width: 40, height: 40))
                                            
                                            let userImgUrl = NSURL(string: "https://graph.facebook.com/\(uid)/picture?width=200&height=200")
                                            
                                            let tapRecProfile = UITapGestureRecognizer()
                                            tapRecProfile.addTarget(self, action: "profile:")
                                            
                                            
                                            inboxUserImg.addGestureRecognizer(tapRecProfile)
                                            inboxUserImg.userInteractionEnabled = true
                                            
                                            
                                            
                                            if let id = participant["id"].int {
                                                
                                                inboxUserImg.tag = id
                                                
                                                if sender == id {
                                                    
                                                    inboxUserImg.frame.origin.x = 10
                                                    let senderName = UILabel(frame: CGRect(x: 10, y: 60, width: 30, height: 15))
                                                    senderName.text = "\(name) shared"
                                                    senderName.textColor = UIColor.whiteColor()
                                                    senderName.font = UIFont(name: "HelveticaNeue", size: 12)
                                                    senderName.sizeToFit()
                                                    convoView.addSubview(senderName)
                                                    
                                                    let subjectLabel = UILabel(frame: CGRect(x: 10, y: 75, width: 300, height: 30))
                                                    subjectLabel.textColor = UIColor.whiteColor()
                                                    subjectLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                                                    convoView.addSubview(subjectLabel)
                                                    
                                                    if subject[subject.startIndex] == "S" {
                                                        
                                                        let title = subject.componentsSeparatedByString("#")[1]
                                                        
                                                        let req = Router(OAuthToken: resnateToken, userID: title)
                                                        
                                                        request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
                                                            
                                                            var song = JSON(response.result.value!)
                                                            
                                                            if let songContent = song["content"].string {
                                                                
                                                                let songName = song["name"].string!
                                                                
                                                                subjectLabel.text = songName
                                                                
                                                                let inboxSongImg = UIImageView(frame: CGRect(x: 10, y: 130, width: 100, height: 100))
                                                                
                                                                let songImgUrl = NSURL(string: "https://img.youtube.com/vi/\(songContent)/hqdefault.jpg")
                                                                
                                                                self.getDataFromUrl(songImgUrl!) { data in
                                                                    dispatch_async(dispatch_get_main_queue()) {
                                                                        
                                                                        inboxSongImg.image = UIImage(data: data!)
                                                                        
                                                                        let ytSong = [songName: songContent]
                                                                        
                                                                        self.songs.removeAtIndex(Int(index)!)
                                                                        
                                                                        self.songs.insert(ytSong, atIndex: Int(index)!)
                                                                        
                                                                        let tapVideo = UITapGestureRecognizer()
                                                                        
                                                                        tapVideo.addTarget(self, action: "playSong:")
                                                                        
                                                                        inboxSongImg.tag = Int(index)!
                                                                        
                                                                        inboxSongImg.addGestureRecognizer(tapVideo)
                                                                        
                                                                        inboxSongImg.userInteractionEnabled = true
                                                                        
                                                                        convoView.addSubview(inboxSongImg)
                                                                        
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }
                                                        
                                                    } else if subject[subject.startIndex] == "R" {
                                                        
                                                        let reviewID = subject.componentsSeparatedByString("#")[1]
                                                        
                                                        let shareReviewTap = UITapGestureRecognizer()
                                                        shareReviewTap.addTarget(self, action: "shareReview:")
                                                        share.addGestureRecognizer(shareReviewTap)
                                                        share.tag = Int(reviewID)!
                                                        share.userInteractionEnabled = true
                                                        
                                                        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                                                        
                                                        let resnateToken = dictionary!["token"] as! String
                                                        
                                                        let req = Router(OAuthToken: resnateToken, userID: reviewID)
                                                        
                                                        request(req.buildURLRequest("reviews/", path: "")).responseJSON { response in
                                                                
                                                                var review = JSON(response.result.value!)
                                                                
                                                                if let type = review["reviewable_type"].string {
                                                                    
                                                                    if type == "PastGig" {
                                                                        
                                                                        let pastGigID = String(stringInterpolationSegment: review["reviewable_id"])
                                                                        
                                                                        let req = Router(OAuthToken: resnateToken, userID: pastGigID)
                                                                        
                                                                        request(req.buildURLRequest("past_gigs/", path: "")).responseJSON { response in
                                                                                
                                                                                let pastGig = JSON(response.result.value!)
                                                                                
                                                                                if let skID = pastGig["songkick_id"].int {
                                                                                    
                                                                                    let artistLink = "https://api.songkick.com/api/3.0/events/" + String(skID) + ".json?apikey=Pxms4Lvfx5rcDIuR"
                                                                                    
                                                                                    request(.GET, artistLink).responseJSON { response in
                                                                                            
                                                                                            var json = JSON(response.result.value!)
                                                                                            if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                                                                                
                                                                                                let artistView = getHugeArtistPic(artist)
                                                                                                artistView.frame = CGRect(x: 10, y: 130, width: 100, height: 100)
                                                                                                convoView.addSubview(artistView)
                                                                                            }
                                                                                            
                                                                                            if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                                                                                subjectLabel.text = "a review of \(gigName)"
                                                                                                subjectLabel.numberOfLines = 2
                                                                                                
                                                                                                subjectLabel.lineBreakMode = .ByTruncatingTail
                                                                                                

                                                                                            }
                                                                                            
                                                                                    }
                                                                                }
                                                                            
                                                                        }
                                                                        
                                                                        
                                                                    }
                                                                    
                                                                }
                                                            }
                                                        } else if subject[subject.startIndex] == "G" {
                                                        
                                                            let gigID = subject.componentsSeparatedByString("#")[1]
                                                        
                                                            let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                                                        
                                                            let resnateToken = dictionary!["token"] as! String
                                                        
                                                            let req = Router(OAuthToken: resnateToken, userID: gigID)
                                                        
                                                            let shareGigTap = UITapGestureRecognizer()
                                                            shareGigTap.addTarget(self, action: "shareGig:")
                                                            share.addGestureRecognizer(shareGigTap)
                                                            share.tag = Int(gigID)!
                                                            share.userInteractionEnabled = true
                                                        
                                                            request(req.buildURLRequest("gigs/", path: "")).responseJSON { response in
                                                                
                                                                var gig = JSON(response.result.value!)
                                                                
                                                                let songkickID = gig["songkick_id"].int!
                                                                
                                                                let artistLink = "https://api.songkick.com/api/3.0/events/\(songkickID).json?apikey=Pxms4Lvfx5rcDIuR"
                                                                
                                                                request(.GET, artistLink).responseJSON { response in
                                                                    
                                                                    var json = JSON(response.result.value!)
                                                                    if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                                                        
                                                                        let artistView = getHugeArtistPic(artist)
                                                                        artistView.frame = CGRect(x: 10, y: 130, width: 100, height: 100)
                                                                        convoView.addSubview(artistView)
                                                                        
                                                                        let songkickTap = UITapGestureRecognizer()
                                                                        songkickTap.addTarget(self, action: "loadGig:")
                                                                        artistView.tag = songkickID
                                                                        
                                                                        artistView.addGestureRecognizer(songkickTap)
                                                                        artistView.userInteractionEnabled = true
                                                                        
                                                                    }
                                                                    
                                                                    if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                                                        
                                                                        subjectLabel.text = gigName
                                                                        subjectLabel.numberOfLines = 2
                                                                        
                                                                        let songkickTap = UITapGestureRecognizer()
                                                                        songkickTap.addTarget(self, action: "loadGig:")
                                                                        subjectLabel.tag = songkickID
                                                                        
                                                                        subjectLabel.addGestureRecognizer(songkickTap)
                                                                        subjectLabel.userInteractionEnabled = true
                                                                        
                                                                        subjectLabel.lineBreakMode = .ByTruncatingTail
                                                                        
                                                                    }
                                                                    
                                                                }
                                                                
                                                            }
                                                        
                                                        
                                                        }
                                                    
                                                } else {
                                                    
                                                    inboxUserImg.frame.origin.x += 50
                                                    x += 50
                                                    i += 1
                                                    
                                                }
                                                
                                                
                                                
                                                
                                                self.getDataFromUrl(userImgUrl!) { data in
                                                    dispatch_async(dispatch_get_main_queue()) {
                                                        inboxUserImg.image = UIImage(data: data!)
                                                        
                                                        convoView.addSubview(inboxUserImg)
                                                        
                                                        
                                                    }
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                }
                                
                            }
                            
                        }

                        
                        
                        
                    }
                    
                    y += 250
                    
                    self.inboxScroll.contentSize.height = CGFloat(y)
                    
                }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func playSong(sender: AnyObject) {
        
        self.tabBarController?.view.addSubview(ytPlayer.videoPlayer)
        
        let song = self.songs[sender.view!!.tag] as! [String: String]
        
        for (name, ytID) in song {
            
            ytPlayer.ytID = ytID
            
            ytPlayer.ytTitle = name
            
            ytPlayer.shareID = "\(ytID),\(name)"
            
            ytPlayer.playVid(ytID)
            
        }
        
        
        self.tabBarController?.view.addSubview(ytPlayer.playerControls)
        
        
        
    }

}
