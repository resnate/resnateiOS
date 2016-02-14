//
//  InboxViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 01/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit
import ReachabilitySwift

class InboxViewController: UIViewController, UIScrollViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var reachability: Reachability?
    
    let noConnection = UILabel(frame: CGRect(x: 0, y: 64, width: UIScreen.mainScreen().bounds.width, height: 30))
    
    let width = Int(UIScreen.mainScreen().bounds.width)
    
    let ytPlayer = VideoPlayer.sharedInstance
    
    var songs: [AnyObject] = []
    
    var songIDs: [Int] = []
    
    var playlist: [JSON] = []
    
    var playlistSongs: [AnyObject] = []
    
    var playlistCount = 0
    
    var msgCount = 0
    
    var page = 1
    
    var dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
    
    var autocompleteTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height))
    
    lazy var searchUsersBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width - 30, 20))
    
    var users: [User] = []
    
    var autoUsers = [User]()
    
    var removedUsers = [User]()
    
    let noConvos = UILabel(frame: CGRect(x: Int(UIScreen.mainScreen().bounds.width)/2 - 150, y: 140, width: 300, height: 67))
    
    @IBOutlet weak var inboxScroll: UIScrollView!
    
    func loadMessage(conversation: JSON, y: Int){
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        let convoView = UIView(frame: CGRect(x: 0, y: y, width: self.width, height: 240))
        convoView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:0.5)
        self.inboxScroll.addSubview(convoView)
        
        let likeSong = UIImageView(frame: CGRect(x: 125, y: 200, width: 30, height: 30))
        
        
        let tapLike = UITapGestureRecognizer()
        tapLike.addTarget(self, action: "likeSong:")
        likeSong.addGestureRecognizer(tapLike)
        likeSong.userInteractionEnabled = true
        
        let likeGig = UIImageView(frame: CGRect(x: 125, y: 200, width: 30, height: 30))
        
        
        let tapGigLike = UITapGestureRecognizer()
        tapGigLike.addTarget(self, action: "likeGig:")
        likeGig.addGestureRecognizer(tapGigLike)
        likeGig.userInteractionEnabled = true
        
        let share = UIImageView(frame: CGRect(x: 175, y: 200, width: 30, height: 30))
        share.image = UIImage(named: "Share")
        convoView.addSubview(share)
        
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
                                                
                                                if let songID = song["id"].int {
                                                    
                                                    self.songIDs.insert(songID, atIndex: self.songIDs.count)
                                                    
                                                    likeSong.tag = songID
                                                    
                                                    let shareSongTap = UITapGestureRecognizer()
                                                    shareSongTap.addTarget(self, action: "shareSingleSong:")
                                                    share.addGestureRecognizer(shareSongTap)
                                                    share.tag = songID
                                                    share.userInteractionEnabled = true
                                                    
                                                    if sender != Int(resnateID) {
                                                        
                                                        convoView.addSubview(likeSong)
                                                        
                                                        let req = Router(OAuthToken: resnateToken, userID: resnateID)
                                                        
                                                        request(req.buildURLRequest("likes/ifLike/Song/", path: "/\(songID)")).responseJSON { response in
                                                            if let re = response.result.value {
                                                                
                                                                let json = JSON(re)
                                                                
                                                                if let count = json["count"].int {
                                                                    
                                                                    if count > 0 {
                                                                        
                                                                        likeSong.image = UIImage(named: "liked")
                                                                        tapLike.addTarget(self, action: "unlikeSong:")
                                                                        
                                                                    }
                                                                        
                                                                    else {
                                                                        
                                                                        likeSong.image = UIImage(named: "likeWhite")
                                                                        tapLike.addTarget(self, action: "likeSong:")
                                                                    }
                                                                    
                                                                    
                                                                }
                                                                
                                                                
                                                            }
                                                        }
                                                        
                                                    } else {
                                                        
                                                        share.frame.origin.x = 125
                                                        
                                                    }

                                                }
                                                
                                                if let songContent = song["content"].string {
                                                    
                                                    let songName = song["name"].string!
                                                    
                                                    subjectLabel.text = songName
                                                    
                                                    let inboxSongImg = UIImageView(frame: CGRect(x: 10, y: 130, width: 100, height: 100))
                                                    
                                                    let songImgUrl = NSURL(string: "https://img.youtube.com/vi/\(songContent)/hqdefault.jpg")
                                                    
                                                    self.getDataFromUrl(songImgUrl!) { data in
                                                        dispatch_async(dispatch_get_main_queue()) {
                                                            
                                                            inboxSongImg.image = UIImage(data: data!)
                                                            
                                                            let ytSong = [songName: songContent]
                                                            
                                                            inboxSongImg.tag = self.songs.count
                                                            
                                                            self.songs.insert(ytSong, atIndex: self.songs.count)
                                                            
                                                            let tapVideo = UITapGestureRecognizer()
                                                            
                                                            tapVideo.addTarget(self, action: "playSong:")
                                                            
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
                                                        
                                                        
                                                    } else {
                                                        
                                                        let title = subject.componentsSeparatedByString("#")[1]
                                                        
                                                        let req = Router(OAuthToken: resnateToken, userID: title)
                                                        
                                                        request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
                                                            
                                                            var song = JSON(response.result.value!)
                                                            
                                                            if let songID = song["id"].int {
                                                                
                                                                likeSong.tag = songID
                                                                
                                                                if sender != Int(resnateID) {
                                                                    
                                                                    convoView.addSubview(likeSong)
                                                                    
                                                                    let req = Router(OAuthToken: resnateToken, userID: resnateID)
                                                                    
                                                                    request(req.buildURLRequest("likes/ifLike/Song/", path: "/\(songID)")).responseJSON { response in
                                                                        if let re = response.result.value {
                                                                            
                                                                            let json = JSON(re)
                                                                            
                                                                            if let count = json["count"].int {
                                                                                
                                                                                if count > 0 {
                                                                                    
                                                                                    likeSong.image = UIImage(named: "liked")
                                                                                    tapLike.addTarget(self, action: "unlikeSong:")
                                                                                    
                                                                                }
                                                                                    
                                                                                else {
                                                                                    
                                                                                    likeSong.image = UIImage(named: "likeWhite")
                                                                                    tapLike.addTarget(self, action: "likeSong:")
                                                                                }
                                                                                
                                                                                
                                                                            }
                                                                            
                                                                            
                                                                        }
                                                                    }
                                                                    
                                                                } else {
                                                                    
                                                                    share.frame.origin.x = 125
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                            if let songContent = song["content"].string {
                                                                
                                                                let songName = song["name"].string!
                                                                
                                                                subjectLabel.text = "a review of \(songName)"
                                                                
                                                                let inboxSongImg = UIImageView(frame: CGRect(x: 10, y: 130, width: 100, height: 100))
                                                                
                                                                let songImgUrl = NSURL(string: "https://img.youtube.com/vi/\(songContent)/hqdefault.jpg")
                                                                
                                                                self.getDataFromUrl(songImgUrl!) { data in
                                                                    dispatch_async(dispatch_get_main_queue()) {
                                                                        
                                                                        inboxSongImg.image = UIImage(data: data!)
                                                                        
                                                                        let tapVideo = UITapGestureRecognizer()
                                                                        
                                                                        tapVideo.addTarget(self, action: "toReview:")
                                                                        
                                                                        inboxSongImg.tag = Int(reviewID)!
                                                                        
                                                                        inboxSongImg.addGestureRecognizer(tapVideo)
                                                                        
                                                                        inboxSongImg.userInteractionEnabled = true
                                                                        
                                                                        convoView.addSubview(inboxSongImg)
                                                                        
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                            }
                                        } else if subject[subject.startIndex] == "G" {
                                            
                                            let gigID = subject.componentsSeparatedByString("#")[1]
                                            
                                            let req = Router(OAuthToken: resnateToken, userID: gigID)
                                            
                                            let shareGigTap = UITapGestureRecognizer()
                                            shareGigTap.addTarget(self, action: "shareGig:")
                                            share.addGestureRecognizer(shareGigTap)
                                            share.tag = Int(gigID)!
                                            share.userInteractionEnabled = true
                                            
                                            request(req.buildURLRequest("gigs/", path: "")).responseJSON { response in
                                                
                                                var gig = JSON(response.result.value!)
                                                
                                                if let gigID = gig["id"].int {
                                                    
                                                    likeGig.tag = gigID
                                                    
                                                    if sender != Int(resnateID) {
                                                        
                                                        convoView.addSubview(likeGig)
                                                        
                                                        let req = Router(OAuthToken: resnateToken, userID: resnateID)
                                                        
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
                                                        
                                                    } else {
                                                        
                                                        share.frame.origin.x = 125
                                                        
                                                    }
                                                    
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
                                            
                                            
                                        }  else if subject[subject.startIndex] == "P" {
                                            
                                            share.hidden = true
                                            
                                            let playlistID = subject.componentsSeparatedByString("#")[1]
                                            
                                            let req = Router(OAuthToken: resnateToken, userID: playlistID)
                                            
                                            request(req.buildURLRequest("playlists/", path: "")).responseJSON { response in
                                                
                                                var playlist = JSON(response.result.value!)
                                                
                                                self.playlist.append(playlist)
                                                
                                                if let playlistContent = playlist["content"].string {
                                                    
                                                    let playlistName = playlist["name"].string!
                                                    
                                                    subjectLabel.text = "the playlist \(playlistName)"
                                                    
                                                    let inboxPlaylistImg = UIImageView(frame: CGRect(x: 10, y: 130, width: 100, height: 100))
                                                    
                                                    let data: NSData = playlistContent.dataUsingEncoding(NSUTF8StringEncoding)!
                                                    
                                                    do {
                                                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [AnyObject]
                                                        
                                                        self.playlistSongs.append(json)
                                                        
                                                        let firstSong: AnyObject = json[0]
                                                        let song = firstSong as! [String: String]
                                                        for (_, ytID) in song {
                                                            let playlistUrl = NSURL(string: "https://img.youtube.com/vi/\(ytID)/hqdefault.jpg")
                                                            self.getDataFromUrl(playlistUrl!) { data in
                                                                dispatch_async(dispatch_get_main_queue()) {
                                                                    
                                                                    inboxPlaylistImg.image = UIImage(data: data!)
                                                                    
                                                                    let tapPlaylist = UITapGestureRecognizer()
                                                                    
                                                                    tapPlaylist.addTarget(self, action: "toPlaylist:")
                                                                    
                                                                    inboxPlaylistImg.tag = self.playlistCount
                                                                    
                                                                    self.playlistCount += 1
                                                                    
                                                                    inboxPlaylistImg.addGestureRecognizer(tapPlaylist)
                                                                    
                                                                    inboxPlaylistImg.userInteractionEnabled = true
                                                                    
                                                                    convoView.addSubview(inboxPlaylistImg)
                                                                    
                                                                }
                                                            }
                                                        }
                                                    } catch let error as NSError {
                                                        print("json error: \(error.localizedDescription)")
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
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters = ["token" : "\(resnateToken)", "type" : "message"]
        
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://www.resnate.com/api/markAsRead/")!)
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
            
            self.msgCount = 0
            
            let tabArray = self.tabBarController?.tabBar.items as NSArray!
            
            let inboxTab = tabArray.objectAtIndex(2) as! UITabBarItem
            
            inboxTab.badgeValue = nil
            
            
            
        }
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            self.reachability = reachability
        } catch {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        
        
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
        
        self.inboxScroll.subviews.map({ $0.removeFromSuperview() })
        
        noConnection.textAlignment = .Center
        noConnection.textColor = UIColor.whiteColor()
        noConnection.backgroundColor = UIColor.redColor()
        
        self.inboxScroll.delegate = self
        
        self.dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: resnateToken)
        
        request(req.buildURLRequest("messages/", path: "/index/\(page)")).responseJSON { response in
            
            if let re = response.result.value {
                
                let conversations = JSON(re)
                
                if conversations.first == nil {
                    
                    self.noConvos.textColor = UIColor.whiteColor()
                    self.noConvos.textAlignment = .Center
                    self.noConvos.font = UIFont(name: "HelveticaNeue-Light", size: 18)
                    self.noConvos.text = "No messages.\nShare some music or a concert review\nwith your friends!"
                    self.noConvos.numberOfLines = 3
                    self.inboxScroll.addSubview(self.noConvos)
                    
                } else {
                    self.noConvos.removeFromSuperview()
                    var y = 10
                    
                    for (index, conversation) in conversations {
                        self.loadMessage(conversation, y: y)
                        
                        y += 250
                        
                    }
                    
                    self.inboxScroll.contentSize.height = CGFloat(y)
                    
                    self.page += 1
                }
                
            }
            
        }
        
        request(req.buildURLRequest("search/", path: "")).responseJSON { response in
            if let re = response.result.value {
                
                let userResults = JSON(re)
                
                for (_, user) in userResults {
                    let name = user["name"].string!
                    let id = user["id"].int!
                    let uid = user["uid"].string!
                    let result = User(name: name, id: id, uid: uid)
                    if result.id != Int(resnateID) {
                        self.users.append(result)
                    }
                    
                }
                
                
            }
        }
        
        searchUsersBar.placeholder = "Search For People"
        
        self.view.addSubview(autocompleteTableView)
        
        searchUsersBar.delegate = self
        
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        
        autocompleteTableView.scrollEnabled = true
        autocompleteTableView.registerClass(AutoUser.self as AnyClass, forCellReuseIdentifier: "AutoUser")
        autocompleteTableView.hidden = true
        
        
        self.navigationController!.navigationBar.translucent = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        let leftNavBarButton = UIBarButtonItem(customView:searchUsersBar)
        
        self.navigationItem.leftBarButtonItem = leftNavBarButton
    }
    
    deinit {
        
        reachability?.stopNotifier()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            for view in self.view.subviews {
                if view.tag == -72 {
                    view.removeFromSuperview()
                }
            }
        } else {
            noConnection.text = "No Internet Connection"
            noConnection.tag = -72
            self.view.addSubview(noConnection)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func playSong(sender: AnyObject) {
        
        self.tabBarController?.view.addSubview(ytPlayer.videoPlayer)
        
        let song = self.songs[sender.view!.tag] as! [String: String]
        
        let songID = self.songIDs[sender.view!.tag]
        
        for (name, ytID) in song {
            
            ytPlayer.ytID = ytID
            
            ytPlayer.ytTitle = name
            
            ytPlayer.shareID = "\(songID)"
            
            ytPlayer.playVid(ytID)
            
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) && scrollView.contentSize.height > 1 && scrollView.tag != -1) {
            
            self.inboxScroll.contentSize.height += 10
            
            let loadingView = UIActivityIndicatorView(frame: CGRect(x: self.width/2 - 25, y: Int(self.inboxScroll.contentSize.height - 30), width: 50, height: 50))
            
            
            
            self.inboxScroll.tag = -1
            
            let resnateToken = dictionary!["token"] as! String
            
            let req = Router(OAuthToken: resnateToken, userID: resnateToken)
            
            request(req.buildURLRequest("messages/", path: "/index/\(page)")).responseJSON { response in
                
                if let re = response.result.value {
                    
                    let conversations = JSON(re)
                    
                    var y = Int(self.inboxScroll.contentSize.height)
                    
                    if conversations.count > 0 {
                        
                        self.inboxScroll.addSubview(loadingView)
                        
                        loadingView.startAnimating()
                        
                    }
                    
                    for (_, conversation) in conversations {
                        
                        self.loadMessage(conversation, y: y)
                        
                        y += 250
                        
                    }
                    
                    self.inboxScroll.contentSize.height = CGFloat(y)
                    
                    self.page += 1
                    
                }
                
                loadingView.stopAnimating()
                
                self.inboxScroll.tag = 0
                
            }
        }
    }
    
    func likeSong(sender: AnyObject) {
        
        if reachability!.isReachable() {
            
            let resnateToken = dictionary!["token"] as! String
            
            let parameters =  ["likeable_id" : sender.view!.tag, "likeable_type" : "Song", "token": "\(resnateToken)"]
            
            let likedSong = UIImageView(frame: CGRect(x: 125, y: 200, width: 30, height: 30))
            
            sender.view!.superview?.addSubview(likedSong)
            
            let tapUnlike = UITapGestureRecognizer()
            
            
            likedSong.tag = sender.view!.tag
            
            likedSong.addGestureRecognizer(tapUnlike)
            
            likedSong.userInteractionEnabled = true
            
            likedSong.image = UIImage(named: "liked")
            tapUnlike.addTarget(self, action: "unlikeSong:")
            
            sender.view!.removeFromSuperview()
            
            let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://www.resnate.com/api/likes/")!)
            mutableURLRequest.HTTPMethod = Method.POST.rawValue
            mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
            
            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters as? [String : AnyObject]).0).responseJSON { response in
                print(response)
                
            }
            
            
        } else {
            UIView.animateWithDuration(2.0, animations: {
                self.noConnection.text = "Cannot Like without Internet Connection"
                self.noConnection.alpha = 0.0
                }, completion: {
                    (finished: Bool) -> Void in
                    self.noConnection.alpha = 1.0
                    self.noConnection.text = "No Internet Connection"
            })
            
        }
        
    }
    
    func likeGig(sender: AnyObject) {
        
        if reachability!.isReachable() {
            
            let resnateToken = dictionary!["token"] as! String
            
            let parameters =  ["likeable_id" : sender.view!.tag, "likeable_type" : "Gig", "token": "\(resnateToken)"]
            
            let likedGig = UIImageView(frame: CGRect(x: 125, y: 200, width: 30, height: 30))
            
            sender.view!.superview?.addSubview(likedGig)
            
            let tapUnlikeGig = UITapGestureRecognizer()
            
            
            likedGig.tag = sender.view!.tag
            
            likedGig.addGestureRecognizer(tapUnlikeGig)
            
            likedGig.userInteractionEnabled = true
            
            likedGig.image = UIImage(named: "liked")
            tapUnlikeGig.addTarget(self, action: "unlikeGig:")
            
            sender.view!.removeFromSuperview()
            
            let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://www.resnate.com/api/likes/")!)
            mutableURLRequest.HTTPMethod = Method.POST.rawValue
            mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
            
            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters as? [String : AnyObject]).0).responseJSON { response in
                print(response)
                
            }
            
            
        } else {
            UIView.animateWithDuration(2.0, animations: {
                self.noConnection.text = "Cannot Like without Internet Connection"
                self.noConnection.alpha = 0.0
                }, completion: {
                    (finished: Bool) -> Void in
                    self.noConnection.alpha = 1.0
                    self.noConnection.text = "No Internet Connection"
            })
            
        }
        
    }
    
    func unlikeGig(sender: AnyObject) {
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["likeable_id" : sender.view!.tag, "likeable_type" : "Gig", "token": "\(resnateToken)"]
        
        let unlikedGig = UIImageView(frame: CGRect(x: 125, y: 200, width: 30, height: 30))
        
        sender.view!.superview?.addSubview(unlikedGig)
        
        let tapLikeGig = UITapGestureRecognizer()
        
        
        unlikedGig.tag = sender.view!.tag
        
        unlikedGig.addGestureRecognizer(tapLikeGig)
        
        unlikedGig.userInteractionEnabled = true
        
        unlikedGig.image = UIImage(named: "likeWhite")
        tapLikeGig.addTarget(self, action: "likeGig:")
        
        sender.view!.removeFromSuperview()
        
        let URL = NSURL(string: "https://www.resnate.com/api/likes/")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.DELETE.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters as? [String : AnyObject]).0).responseJSON { response in
            
        }
    }
    
    func toPlaylist(sender: AnyObject){
        
        let playlistTableViewController:PlaylistTableViewController = PlaylistTableViewController(nibName: nil, bundle: nil)
        
        playlistTableViewController.songs = self.playlistSongs[sender.view!.tag] as! [AnyObject]
        
        playlistTableViewController.likes = false
        
        playlistTableViewController.playlist = self.playlist[sender.view!.tag]
        
        if let playlistName = self.playlist[sender.view!.tag]["name"].string {
            
            playlistTableViewController.playlistName = playlistName
            
        }
        
        if let playlistID = self.playlist[sender.view!.tag]["id"].int {
            playlistTableViewController.playlistID = playlistID
        }
        
        if let playlistUserID = self.playlist[sender.view!.tag]["user_id"].int {
            playlistTableViewController.playlistUserID = playlistUserID
        }
        
        self.navigationController?.pushViewController(playlistTableViewController, animated: true)
        
    }
    
    
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        autoUsers.removeAll(keepCapacity: false)
        
        for user in users
        {
            
            let myString: NSString! = user.name as NSString
            
            let substringRange: NSRange! = myString.rangeOfString(substring, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if (substringRange.location == 0)
            {
                autoUsers.append(user)
            }
        }
        autoUsers.sortInPlace() { $0.name < $1.name }
        autocompleteTableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoUsers.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AutoUser", forIndexPath: indexPath)
        let index = indexPath.row as Int
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        cell.selectedBackgroundView = bgColorView
        
        cell.contentView.subviews.map({ $0.removeFromSuperview() })
        
        let label = UILabel(frame: CGRect(x: 40, y: 0, width: 270, height: 45))
        
        label.text = autoUsers[index].name
        
        let imgURL = NSURL(string: "https://graph.facebook.com/\(autoUsers[index].uid)/picture?width=200&height=200")
        
        let userImgView = UIImageView(frame: CGRect(x: 5, y: 7.5, width: 30, height: 30))
        
        self.getDataFromUrl(imgURL!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                userImgView.image = UIImage(data: data!)
            }
        }
        
        cell.contentView.addSubview(label)
        
        cell.contentView.addSubview(userImgView)
        
        
        cell.tag = autoUsers[index].id
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count != 0 {
            autocompleteTableView.hidden = false
            searchAutocompleteEntriesWithSubstring(searchText)
        } else {
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.autocompleteTableView.hidden = true
                self.searchUsersBar.endEditing(true)
            }
            
        }
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        autocompleteTableView.hidden = true
        
        searchUsersBar.text = nil
        
        searchUsersBar.endEditing(true)
        
        let scrollProfileViewController:ScrollProfileViewController = ScrollProfileViewController(nibName: "ScrollProfileViewController", bundle: nil)
        
        scrollProfileViewController.ID = selectedCell.tag
        
        
        self.navigationController?.pushViewController(scrollProfileViewController, animated: true)
        
    }

}
