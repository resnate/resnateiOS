//
//  HomeViewController.swift

import UIKit
import Pusher
import ReachabilitySwift

class HomeViewController: UIViewController, VideoPlayerUIViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, PTPusherDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var homeScroll: UIScrollView!
    
    let noConnection = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 30))
    
    var reachability: Reachability?
    
    var client = PTPusher()
    
    var dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
    
    var followees: [Int] = []
    
    var users: [User] = []
    
    var autoUsers = [User]()
    
    var removedUsers = [User]()
    
    var msgCount = 0
    
    var page = 1
    
    var autocompleteTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height))
    
    lazy var searchUsersBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width - 30, 20))
    
    let ytPlayer = VideoPlayer.sharedInstance
    
    
    let width = Int(UIScreen.mainScreen().bounds.width)
    
    let imgWidth = Int(UIScreen.mainScreen().bounds.width) - 20
    
    let imgHeight = Int(Double(UIScreen.mainScreen().bounds.width - 20) / 1.33)
    

    var songs: [AnyObject] = []
    
    var songIDs: [Int] = []
    
    
    var playlistSongs: [AnyObject] = []
    
    var playlist: [JSON] = []
    
    var playlistNames: [String] = []
    
    var playlistUserIDs: [Int] = []
    
    var playlistCount = 0
    
    
    
    
    func feedToPlaylist(sender: AnyObject){
        
        let playlistTableViewController:PlaylistTableViewController = PlaylistTableViewController(nibName: nil, bundle: nil)
        
        playlistTableViewController.songs = self.playlistSongs[sender.view!.tag] as! [AnyObject]
        
        playlistTableViewController.likes = false
        
        playlistTableViewController.playlist = self.playlist[sender.view!.tag]
        
        playlistTableViewController.playlistName = self.playlistNames[sender.view!.tag]
        
        if let playlistID = self.playlist[sender.view!.tag]["id"].int {
            playlistTableViewController.playlistID = playlistID
            playlistTableViewController.playlistUserID = self.playlistUserIDs[sender.view!.tag]
        }
        
        self.navigationController?.pushViewController(playlistTableViewController, animated: true)
        
    }
    
    func getPlaylistInfo(req: Router, activityView: UIView){
        
        request(req.buildURLRequest("playlists/", path: "")).responseJSON { response in
            
            if let re = response.result.value {
                
                let playlist = JSON(re)
                
                self.playlist.append(playlist)
                
                if let playlistName = playlist["name"].string {
                    
                    let playlistNameLabel = UILabel(frame: CGRect(x: 80, y: 13.5, width: 240, height: 30))
                    
                    playlistNameLabel.text = playlistName
                    
                    self.playlistNames.append(playlistName)
                    
                    playlistNameLabel.textColor = UIColor.whiteColor()
                    playlistNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                    playlistNameLabel.numberOfLines = 2
                    
                    activityView.addSubview(playlistNameLabel)
                    
                }
                
                if let playlistContent = playlist["content"].string {
                    
                    let playlistID = playlist["id"].int!
                    
                    let playlistUserID = playlist["user_id"].int!
                    
                    self.playlistUserIDs.append(playlistUserID)
                    
                    let activityPlaylistImg = UIImageView(frame: CGRect(x: 10, y: 125, width: self.imgWidth, height: self.imgHeight))
                    
                    activityView.addSubview(activityPlaylistImg)
                    
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
                                    
                                    activityPlaylistImg.image = UIImage(data: data!)
                                    
                                    let tapPlaylist = UITapGestureRecognizer()
                                    tapPlaylist.addTarget(self, action: "feedToPlaylist:")
                                    activityPlaylistImg.addGestureRecognizer(tapPlaylist)
                                    activityPlaylistImg.tag = self.playlistCount
                                    
                                    self.playlistCount += 1
                                    activityPlaylistImg.userInteractionEnabled = true
                                    
                                }
                            }
                        }
                    }  catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    func getSongInfo(songID: Int, view: UIView, token: String, currentUserID: String, likerID: String)  {
        
        let req = Router(OAuthToken: token, userID: String(songID))
        
        request(req.buildURLRequest("songs/", path: "")).responseJSON { response in
            
                let song = JSON(response.result.value!)
            
                if let songID = song["id"].int {
                    
                    self.songIDs.insert(songID, atIndex: self.songIDs.count)
                    
                    if let songName = song["name"].string {
                        
                        if let songContent = song["content"].string {
                            
                                let likeSong = UIImageView(frame: CGRect(x: self.width/4 - 15, y: self.imgWidth + 120, width: 30, height: 30))
                                
                                view.addSubview(likeSong)
                                
                                let tapLike = UITapGestureRecognizer()
                                
                                
                                likeSong.tag = songID
                                
                                likeSong.addGestureRecognizer(tapLike)
                                
                                likeSong.userInteractionEnabled = true
                                
                                if currentUserID == likerID {
                                    
                                    likeSong.image = UIImage(named: "liked")
                                    tapLike.addTarget(self, action: "unlikeSong:")
                                    
                                } else {
                                    
                                    let req = Router(OAuthToken: token, userID: currentUserID)
                                    
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
                                    
                                    
                                    
                                }
                                

                            
                            
                            
                            let shareSong = UIImageView(frame: CGRect(x: self.width/4 * 3 - 15, y: self.imgWidth + 120, width: 30, height: 30))
                            
                            shareSong.image = UIImage(named: "Share")
                            
                            view.addSubview(shareSong)
                            
                            let tapShare = UITapGestureRecognizer()
                            
                            tapShare.addTarget(self, action: "shareSong:")
                            shareSong.tag = self.songs.count
                            
                            shareSong.addGestureRecognizer(tapShare)
                            
                            shareSong.userInteractionEnabled = true
                            
                            let ytSong = [songName: songContent]
                            
                            
                            
                            let songNameLabel = UILabel(frame: CGRect(x: 80, y: 13.5, width: 240, height: 30))
                            
                            songNameLabel.text = songName
                            
                            songNameLabel.textColor = UIColor.whiteColor()
                            songNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                            songNameLabel.numberOfLines = 2
                            
                            view.addSubview(songNameLabel)
                            
                            let activitysongImg = UIImageView(frame: CGRect(x: 10, y: 125, width: self.imgWidth, height: self.imgHeight))
                            
                            
                            
                            let tapVideo = UITapGestureRecognizer()
                            
                            tapVideo.addTarget(self, action: "playSong:")
                            activitysongImg.tag = self.songs.count
                            
                            activitysongImg.addGestureRecognizer(tapVideo)
                            
                            activitysongImg.userInteractionEnabled = true
                            
                            view.addSubview(activitysongImg)
                            
                            
                            let songImgUrl = NSURL(string: "https://img.youtube.com/vi/\(songContent)/hqdefault.jpg")
                            
                            self.getDataFromUrl(songImgUrl!) { data in
                                dispatch_async(dispatch_get_main_queue()) {
                                    
                                    activitysongImg.image = UIImage(data: data!)
                                    
                                    
                                    
                                }
                            }
                            
                            self.songs.insert(ytSong, atIndex: self.songs.count)
                            
                            
                            
                        }
                        
                    }
                    
                }
            }
        
    }
    
    

    
    
    
    
    func getActivity(y: Int, activity: JSON) -> (y: Int, activityView: UIView) {
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        let activityView = UIView(frame: CGRect(x: 0, y: y, width: self.width, height: self.imgWidth + 200))
            
        if let type = activity["trackable_type"].string {
                
            let commentImgView = UIImageView(frame: CGRect(x: self.width/2 - 15, y: self.imgWidth + 120, width: 30, height: 30))
                
            let commentsAndLikesLabel = UILabel(frame: CGRect(x: 10, y: self.imgWidth + 80, width: 300, height: 20))
                
            let verbLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 14))
            verbLabel.textColor = UIColor.whiteColor()
            verbLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                
            
                
                
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
            if let date = activity["created_at"].string {
                    
                    let timeAgoLabel = UILabel(frame: CGRect(x: 80, y: 45, width: 150, height: 14))
                    timeAgoLabel.textColor = UIColor.whiteColor()
                    timeAgoLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                
                if let activityDateString = dateFormatter.dateFromString(date) {
                    timeAgoLabel.text = timeAgoSinceDate(activityDateString, numericDates: true)
                } else {
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                    let activityDateString = dateFormatter.dateFromString(date)
                    timeAgoLabel.text = timeAgoSinceDate(activityDateString!, numericDates: true)
                }
                
                    activityView.addSubview(timeAgoLabel)
                    
                }
                
            if let ownerID: Int = activity["owner_id"].int {
                    
                    let req = Router(OAuthToken: resnateToken, userID: String(ownerID))
                    
                    request(req.buildURLRequest("users/", path: "")).responseJSON { response in
                        if let re = response.result.value {
                            
                            let user = JSON(re)
                            
                            if let userName = user["name"].string {
                                
                                if let userImageID = user["uid"].string {
                                    
                                    if let userID = user["id"].int {
                                        
                                        let userNameLabel = UILabel(frame: CGRect(x: 80, y: 0, width: 190, height: 14))
                                        
                                        userNameLabel.text = userName
                                        userNameLabel.textColor = UIColor.whiteColor()
                                        userNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                        
                                        userNameLabel.sizeToFit()
                                        
                                        
                                        let tapRecProfile = UITapGestureRecognizer()
                                        tapRecProfile.addTarget(self, action: "profile:")
                                        
                                        userNameLabel.tag = userID
                                        userNameLabel.addGestureRecognizer(tapRecProfile)
                                        userNameLabel.userInteractionEnabled = true
                                        
                                        
                                        verbLabel.frame.origin.x = userNameLabel.frame.width + 85
                                        
                                        verbLabel.sizeToFit()
                                        
                                        activityView.addSubview(userNameLabel)
                                        
                                        activityView.addSubview(verbLabel)
                                        
                                        let activityUserImg = UIImageView(frame: CGRect(x: 10, y: 0, width: 60, height: 60))
                                        
                                        let userImgUrl = NSURL(string: "https://graph.facebook.com/\(userImageID)/picture?width=200&height=200")
                                        
                                        self.getDataFromUrl(userImgUrl!) { data in
                                            dispatch_async(dispatch_get_main_queue()) {
                                                activityUserImg.image = UIImage(data: data!)
                                                
                                                activityView.addSubview(activityUserImg)
                                                
                                                let tapRecProfile = UITapGestureRecognizer()
                                                tapRecProfile.addTarget(self, action: "profile:")
                                                
                                                activityUserImg.tag = userID
                                                activityUserImg.addGestureRecognizer(tapRecProfile)
                                                activityUserImg.userInteractionEnabled = true
                                                
                                            }
                                        }
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                }
                
                
                
                
                
                
                if type == "Song" {
                    
                    
                    
                    verbLabel.text = "listened to"
                    
                    if let songID = activity["trackable_id"].int {
                        
                        self.getSongInfo(songID, view: activityView, token: resnateToken, currentUserID: resnateID, likerID: "")
                        
                        
                    }
                    
                    
                } else if type == "Socialization::ActiveRecordStores::Like" {
                    
                    verbLabel.text = "liked"
                    
                    if let likeID = activity["trackable_id"].int {
                        
                        let req = Router(OAuthToken: resnateToken, userID: String(likeID))
                        
                        request(req.buildURLRequest("likes/", path: "")).responseJSON { response in
                            if let re = response.result.value {
                                
                                var like = JSON(re)
                                
                                if let likeable_type = like["likeable_type"].string {
                                    
                                    if let likeable_id = like["likeable_id"].int {
                                        
                                        if let liker_id = like["liker_id"].int {
                                            
                                            if likeable_type == "Song" {
                                                
                                                self.getSongInfo(likeable_id, view: activityView, token: resnateToken, currentUserID: resnateID, likerID: String(liker_id))
                                                
                                            } else if likeable_type == "Gig" {
                                                
                                                self.getGigInfo(likeable_id, view: activityView, token: resnateToken, currentUserID: resnateID, likerID: String(liker_id))
                                                
                                            } else if likeable_type == "Review" {
                                                
                                                self.getReviewInfo(likeable_id, activityView: activityView, resnateToken: resnateToken, like: true, verbLabel: verbLabel)
                                                
                                            }
                                            
                                        }
                                        
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                        
                        
                    }
                    
                } else if type == "Socialization::ActiveRecordStores::Follow" {
                    
                    verbLabel.text = "followed"
                    
                    if let trackableID = activity["trackable_id"].int {
                        
                        let followReq = Router(OAuthToken: resnateToken, userID: String(trackableID))
                        
                        request(followReq.buildURLRequest("follows/", path: "")).responseJSON { response in
                            if let re = response.result.value {
                                
                                let followable = JSON(re)
                                
                                let followeeNameLabel = UILabel(frame: CGRect(x: 80, y: 13.5, width: 240, height: 30))
                                followeeNameLabel.textColor = UIColor.whiteColor()
                                followeeNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                followeeNameLabel.numberOfLines = 2
                                
                                activityView.addSubview(followeeNameLabel)
                                
                                if let followable_id = followable["followable_id"].int {
                                    
                                    if let followable_type = followable["followable_type"].string {
                                        
                                        if followable_type == "User" {
                                            
                                            let userReq = Router(OAuthToken: resnateToken, userID: String(followable_id))
                                            
                                            request(userReq.buildURLRequest("users/", path: "")).responseJSON { response in
                                                
                                                if let re = response.result.value {
                                                    
                                                    let user = JSON(re)
                                                    
                                                    if let uid = user["uid"].string {
                                                        
                                                        let imgUrl = NSURL(string: "https://graph.facebook.com/\(uid)/picture?width=500&height=500")
                                                        
                                                        self.getDataFromUrl(imgUrl!) { data in
                                                            dispatch_async(dispatch_get_main_queue()) {
                                                                
                                                                let userImageView = UIImageView(frame: CGRect(x: 10, y: 70, width: self.imgWidth, height: self.imgWidth))
                                                                userImageView.image = UIImage(data: data!)
                                                                activityView.addSubview(userImageView)
                                                                
                                                                let tapRecProfile = UITapGestureRecognizer()
                                                                tapRecProfile.addTarget(self, action: "profile:")
                                                                
                                                                userImageView.tag = followable_id
                                                                userImageView.addGestureRecognizer(tapRecProfile)
                                                                userImageView.userInteractionEnabled = true
                                                                
                                                            }
                                                        }
                                                        
                                                        
                                                        
                                                    }
                                                    
                                                    if let name = user["name"].string {
                                                        
                                                        followeeNameLabel.text = name
                                                        let tapRecProfile = UITapGestureRecognizer()
                                                        tapRecProfile.addTarget(self, action: "profile:")
                                                        
                                                        followeeNameLabel.tag = followable_id
                                                        followeeNameLabel.addGestureRecognizer(tapRecProfile)
                                                        followeeNameLabel.userInteractionEnabled = true
                                                        
                                                    }
                                                    
                                                }
                                            }
                                            
                                        } else if followable_type == "Playlist" {
                                            
                                            let followedPlaylistReq = Router(OAuthToken: resnateToken, userID: String(followable_id))
                                            
                                            self.getPlaylistInfo(followedPlaylistReq, activityView: activityView)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                    
                } else if type == "Review" {
                    
                    verbLabel.text = "wrote a review for"
                    
                    if let reviewID = activity["trackable_id"].int {
                        
                        self.getReviewInfo(reviewID, activityView: activityView, resnateToken: resnateToken, like: false, verbLabel: verbLabel)
                        
                    }
                    
                } else if type == "Gig" {
                    
                    verbLabel.text = "is going to"
                    
                    
                    if let gigID = activity["trackable_id"].int {
                        
                        self.getGigInfo(gigID, view: activityView, token: resnateToken, currentUserID: resnateID, likerID: "")
                        
                    }
                    
                    
                } else if type == "Playlist" {
                    
                    verbLabel.text = "created a playlist"
                    
                    if let playlistID = activity["trackable_id"].int {
                        
                        let req = Router(OAuthToken: resnateToken, userID: String(playlistID))
                        
                        self.getPlaylistInfo(req, activityView: activityView)
                        
                    }
                    
                }else if type == "User" {
                    
                    if let userID = activity["trackable_id"].int {
                        
                        let req = Router(OAuthToken: resnateToken, userID: String(userID))
                        
                        request(req.buildURLRequest("users/", path: "/level")).responseJSON { response in
                            
                            let json = JSON(response.result.value!)
                            
                            if let badgeName = json["level_name"].string {
                                
                                let badgeView = UIImageView(frame: CGRect(x: 10, y: 70, width: self.imgWidth, height: self.imgWidth))
                                
                                activityView.addSubview(badgeView)
                                
                                badgeView.image = UIImage(named: badgeName)
                                
                                let badgeNameLabel = UILabel(frame: CGRect(x: 80, y: 13.5, width: 240, height: 30))
                                
                                badgeNameLabel.text = "New badge: \(badgeName)"
                                
                                badgeNameLabel.textColor = UIColor.whiteColor()
                                badgeNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                badgeNameLabel.numberOfLines = 2
                                
                                activityView.addSubview(badgeNameLabel)
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                }
                
                
                
                
                
                commentImgView.image = UIImage(named: "comment")
                
                
                
                if let activityID = activity["id"].int {
                    
                    if type != "Socialization::ActiveRecordStores::Follow" && type != "User" {
                        
                        commentImgView.tag = activityID
                        
                        let toLikesAndCommentsImg = UITapGestureRecognizer()
                        toLikesAndCommentsImg.addTarget(self, action: "toActivity:")
                        commentImgView.addGestureRecognizer(toLikesAndCommentsImg)
                        commentImgView.userInteractionEnabled = true
                        
                        activityView.addSubview(commentImgView)
                        
                        
                        let req = Router(OAuthToken: resnateToken, userID: String(activityID))
                        
                        request(req.buildURLRequest("activity/", path: "/comments/count")).responseJSON { response in
                            if let re = response.result.value {
                                
                                let counts = JSON(re)
                                
                                if let commentsCount = counts["commentsCount"].int {
                                    
                                    if let likesCount = counts["likesCount"].int {
                                        
                                        
                                        
                                        if commentsCount == 1 && likesCount == 0 {
                                            
                                            commentsAndLikesLabel.text = "\(commentsCount) comment"
                                            
                                        } else if commentsCount > 1 && likesCount == 0 {
                                            
                                            commentsAndLikesLabel.text = "\(commentsCount) comments"
                                            
                                        } else if commentsCount > 1 && likesCount == 1 {
                                            
                                            commentsAndLikesLabel.text = "\(commentsCount) comments \(likesCount) like"
                                            
                                        }  else if commentsCount > 1 && likesCount > 1 {
                                            
                                            commentsAndLikesLabel.text = "\(commentsCount) comments \(likesCount) likes"
                                            
                                        }   else if commentsCount == 1 && likesCount > 1 {
                                            
                                            commentsAndLikesLabel.text = "\(commentsCount) comment \(likesCount) likes"
                                            
                                        }    else if commentsCount == 0 && likesCount > 1 {
                                            
                                            commentsAndLikesLabel.text = "\(likesCount) likes"
                                            
                                        }    else if commentsCount == 0 && likesCount == 1 {
                                            
                                            commentsAndLikesLabel.text = "\(likesCount) like"
                                            
                                        }
                                        
                                        commentsAndLikesLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                                        
                                        commentsAndLikesLabel.textColor = UIColor.whiteColor()
                                        
                                        commentsAndLikesLabel.tag = activityID
                                        
                                        let toLikesAndComments = UITapGestureRecognizer()
                                        toLikesAndComments.addTarget(self, action: "toActivity:")
                                        commentsAndLikesLabel.addGestureRecognizer(toLikesAndComments)
                                        commentsAndLikesLabel.userInteractionEnabled = true
                                        
                                        activityView.addSubview(commentsAndLikesLabel)
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                    
                    
                }
                
                
            
                return (Int(commentsAndLikesLabel.frame.origin.y) + 200, activityView)
                
            }
            
        return (y, activityView)
        
    }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        noConnection.textAlignment = .Center
        noConnection.textColor = UIColor.whiteColor()
        noConnection.backgroundColor = UIColor.redColor()
        
        
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
        
        /* Initial reachability check
        if let reachability = reachability {
            if reachability.isReachable() {
                print("initialReach")
            } else {
                print("noInitialReach")
            }
        }*/
        
       self.dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        let tabArray = self.tabBarController?.tabBar.items as NSArray!
        
        let inboxTab = tabArray.objectAtIndex(2) as! UITabBarItem
        
        let notificationsTab = tabArray.objectAtIndex(3) as! UITabBarItem
        
        let notificationNav = self.tabBarController?.viewControllers![3] as! UINavigationController
        
        let notificationView = notificationNav.viewControllers[0] as! NotificationsViewController
        
        let tokenReq = Router(OAuthToken: resnateToken, userID: resnateToken)
        
        
        
        request(tokenReq.buildURLRequest("/", path: "/unread")).responseJSON { response in
            
            if let re = response.result.value {

                let points = JSON(re)
                
                if let unreadMessages = points["unreadMessages"].string {
                    
                    if Int(unreadMessages) > 0 {
                        
                        inboxTab.badgeValue = unreadMessages
                        
                        self.repositionBadge(3)
                        
                    }
                    
                }
                
                if let newPoints = points["newPoints"].string {
                    
                    if Int(newPoints) > 0 {
                        
                        notificationsTab.badgeValue = newPoints
                        notificationView.notificationCount = Int(newPoints)!
                        
                        self.repositionBadge(4)
                    }
                    
                }
                
            }
        }
        
        
        
        let inboxNav = self.tabBarController?.viewControllers![2] as! UINavigationController
        
        let inboxView = inboxNav.viewControllers[0] as! InboxViewController
        
        
        
        let newMessageAlert = UILabel(frame: CGRect(x: self.width/2 - 75, y: 80, width: 150, height: 40))
        
        newMessageAlert.backgroundColor = UIColor(red:0.9, green:0.07, blue:0.29, alpha:1.0)
        
        newMessageAlert.alpha = 0.0
        
        newMessageAlert.textColor = UIColor.whiteColor()
        
        newMessageAlert.font = UIFont(name: "HelveticaNeue", size: 18)
        
        newMessageAlert.textAlignment = .Center
        
        self.client = PTPusher(key: "18f25224620c76b2aa21", delegate: self, encrypted: true)
        
        self.client.connect()
        
        let inboxChannel = self.client.subscribeToChannelNamed("messages")
        
        inboxChannel.bindToEventNamed("inbox", handleWithBlock: { channelEvent in
            
            if let newMessage = channelEvent.data.objectForKey("message") {
                
                request(tokenReq.buildURLRequest("/", path: "/lastMsg")).responseJSON { response in
                    
                    if let re = response.result.value {
                        
                        let conversations = JSON(re)
                    
                        if String(newMessage) == resnateID {
                            
                            for (_, conversation) in conversations {
                                    
                                if let message = conversation["message"].dictionary {
                                        
                                    let subject = message["subject"]!.string!
                                        
                                    let index = subject.startIndex.advancedBy(1)
                                    
                                    if subject[index] == "#" {
                                            
                                        if inboxView.inboxScroll != nil {
                                            
                                        for view in inboxView.inboxScroll.subviews {
                                            view.frame.origin.y += 250
                                        }
                                            
                                        inboxView.loadMessage(conversation, y: 10)
                                            
                                        inboxView.msgCount += 1
                                            
                                        inboxTab.badgeValue = String(inboxView.msgCount)
                                            
                                        self.repositionBadge(3)
                                            
                                        inboxView.inboxScroll.contentSize.height += 250
                                            
                                        if self.tabBarController?.selectedIndex == 2 {
                                                
                                            let delay = 2.5 * Double(NSEC_PER_SEC)
                                            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                            dispatch_after(time, dispatch_get_main_queue()) {
                                                    
                                                let parameters = ["token" : "\(resnateToken)", "type" : "message"]
                                                    
                                                let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://www.resnate.com/api/markAsRead/")!)
                                                mutableURLRequest.HTTPMethod = Method.POST.rawValue
                                                mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                                                    
                                                request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                                                        
                                                    inboxView.msgCount = 0
                                                    inboxTab.badgeValue = nil
                                                        
                                                }
                                            }
                                                
                                        }
                                            
                                        newMessageAlert.text = "New Message"
                                            
                                        inboxView.view.addSubview(newMessageAlert)
                                            
                                        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                                
                                            newMessageAlert.alpha = 1.0
                                                
                                            }, completion: {
                                                (finished: Bool) -> Void in
                                                    
                                                UIView.animateWithDuration(0.75, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                                        
                                                    newMessageAlert.alpha = 0.0
                                                        
                                                    }, completion: nil )
                                        })

                                            
                                        } else {
                                            
                                            self.msgCount += 1
                                            
                                            inboxTab.badgeValue = String(self.msgCount)
                                            
                                            self.repositionBadge(3)
                                            
                                        }
                                        
                                    } else {
                                        
                                        notificationView.notificationCount += 1
                                        notificationsTab.badgeValue = String(notificationView.notificationCount)
                                        self.repositionBadge(4)
                                        
                                        if notificationView.scrollView != nil {
                                            
                                            for view in notificationView.scrollView.subviews {
                                                view.frame.origin.y += 70
                                            }
                                            
                                            notificationView.getNotification(conversation, y: 10)

                                            if self.tabBarController?.selectedIndex == 3 {
                                                
                                                let delay = 2.5 * Double(NSEC_PER_SEC)
                                                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                                dispatch_after(time, dispatch_get_main_queue()) {
                                                    
                                                    let parameters = ["token" : "\(resnateToken)", "type" : "notification"]
                                                    
                                                    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://www.resnate.com/api/markAsRead/")!)
                                                    mutableURLRequest.HTTPMethod = Method.POST.rawValue
                                                    mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                                                    
                                                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters ).0).responseJSON { response in
                                                        
                                                        notificationView.notificationCount = 0
                                                        notificationsTab.badgeValue = nil
                                                        
                                                    }
                                                }
                                                
                                            }
                                            
                                            newMessageAlert.text = "New Notification"
                                            
                                            notificationView.view.addSubview(newMessageAlert)
                                            
                                            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                                
                                                newMessageAlert.alpha = 1.0
                                                
                                                }, completion: {
                                                    (finished: Bool) -> Void in
                                                    
                                                    UIView.animateWithDuration(0.75, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                                        
                                                        newMessageAlert.alpha = 0.0
                                                        
                                                        }, completion: nil )
                                            })

                                            
                                        }
                                        
                                    }
                                    
                            }
                        
                        }
                            
                    } else {
                            
                        // if sender is current user
                        
                        if let sender = channelEvent.data.objectForKey("sender") {
                            
                            if String(sender) == resnateID && inboxView.inboxScroll != nil {
                                        
                                        for view in inboxView.inboxScroll.subviews {
                                            view.frame.origin.y += 250
                                        }
                                        
                                        for (_, conversation) in conversations {
                                            
                                            
                                            inboxView.loadMessage(conversation, y: 10)
                                            
                                        }
                                
                                        inboxView.inboxScroll.contentSize.height += 250
                                
                                }
                            
                            }
                        
                        }
                    }
                
                }

             }
        })
        
        let feedChannel = self.client.subscribeToChannelNamed("activities")
        
        feedChannel.bindToEventNamed("feed", handleWithBlock: { channelEvent in
            if let newFeedEntry = channelEvent.data.objectForKey("message") {
                
                let entry = newFeedEntry.componentsSeparatedByString(",")
                
                let activityID = entry[0]
                
                let req = Router(OAuthToken: resnateToken, userID: activityID)
                
                request(req.buildURLRequest("/", path: "/activities")).responseJSON { response in
                    if let re = response.result.value {
                        
                        let activity = JSON(re)
                        
                        if let owner = activity["owner_id"].int {
                            
                            if self.followees.indexOf(owner) != nil || String(owner) == resnateID {
                                
                                newMessageAlert.frame.origin.y = 10
                                
                                newMessageAlert.text = "New Activity"
                                
                                self.view.addSubview(newMessageAlert)
                                
                                UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                    
                                    newMessageAlert.alpha = 1.0
                                    
                                    }, completion: {
                                        (finished: Bool) -> Void in
                                        
                                        UIView.animateWithDuration(1.0, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                            
                                            newMessageAlert.alpha = 0.0
                                            
                                            }, completion: nil )
                                })
                                
                                let getActivity = self.getActivity(10, activity: activity)
                                
                                for view in self.homeScroll.subviews {
                                    view.frame.origin.y += CGFloat(getActivity.y)
                                }
                                
                                self.homeScroll.addSubview(getActivity.activityView)
                                
                                self.homeScroll.contentSize.height = self.homeScroll.contentSize.height + CGFloat(getActivity.y) + 20
                                
                            }
                            
                        }
                        
                    }
                }
                
                
            }
        })
        
        ytPlayer.delegate = self
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        
        request(req.buildURLRequest("users/", path: "/followees")).responseJSON { response in
            if let re = response.result.value {
                
                let users = JSON(re)
                
                for (index, user) in users {
                    
                    if let userID = user["id"].int {
                        
                        self.followees.insert(userID, atIndex: Int(index)!)
                        
                    }
                    
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
        
        request(req.buildURLRequest("/activities/", path: "/index/\(page)")).responseJSON { response in
            if let re = response.result.value {
                
                let activities = JSON(re)
                
                var y = 10
               
                
                for (_, activity) in activities  {
                    
                    let getActivity = self.getActivity(y, activity: activity)
                    
                    y += getActivity.y
                    
                    self.homeScroll.addSubview(getActivity.activityView)
                    
                }
                
                self.homeScroll.contentSize.height = CGFloat(y + 20)
                
                self.page += 1
                
                
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
        
        self.homeScroll.delegate = self
        
        
        
        let userReq = Router(OAuthToken: resnateToken, userID: resnateID)
        
        request(userReq.buildURLRequest("users/", path: "/profile")).responseJSON { response in
            
            if let re = response.result.value {
                
                let user = JSON(re)
                
                let userDefaults = NSUserDefaults.standardUserDefaults()
                
                if user["songkickID"] != nil && user["songkickID"] != "" {
                    
                    let songkickID = user["songkickID"].string!
                    
                    userDefaults.setObject(songkickID, forKey: "songkick_id")
                    
                    let upcomingGigsLink = "https://api.songkick.com/api/3.0/users/\(songkickID)/calendar.json?reason=attendance&apikey=Pxms4Lvfx5rcDIuR&"
                    
                    request(.GET, upcomingGigsLink).responseJSON { response in
                        
                        if let re = response.result.value {
                            
                            let json = JSON(re)
                            
                            if let totalEntries = json["resultsPage"]["totalEntries"].int {
                                
                                var totalPages = 1
                                
                                if totalEntries > 50 {
                                    
                                    totalPages = totalEntries % 50
                                    
                                }
                                    
                                    for i in 1...totalPages {
                                        
                                        let pageUrl = "https://api.songkick.com/api/3.0/users/\(songkickID)/calendar.json?reason=attendance&apikey=Pxms4Lvfx5rcDIuR&page=\(i)"
                                        
                                        request(.GET, pageUrl).responseJSON { response in
                                            
                                            if let re = response.result.value {
                                                
                                                let json = JSON(re)
                                                
                                                
                                                if let gigs = json["resultsPage"]["results"]["calendarEntry"].array {
                                                    
                                                    var allGigs: [Dictionary<String, String>] = []
                                                    var allGigsIDs: [Int] = []
                                                    var uGInts: [Int] = []
                                                    
                                                    if let databaseUpcomingGigs = user["previousUpcomingGigs"].array {
                                                        for uG in databaseUpcomingGigs {
                                                            if let uGInt = uG.int {
                                                                uGInts.append(uGInt)
                                                            }
                                                        }
                                                    }
                                                    
                                                    for gig in gigs {
                                                        
                                                        if let gigID = gig["event"]["id"].int {
                                                            
                                                            if let date = gig["event"]["start"]["date"].string {
                                                                
                                                                allGigsIDs.append(gigID)
                                                                
                                                                if uGInts.indexOf(gigID) == nil {
                                                                    
                                                                    allGigs.append([ "songkick_id" : "\(gigID)", "gig_date" : "\(date)" ])
                                                                    
                                                                }
                                                                
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    if allGigs.count > 0 {
                                                        
                                                        let data = try? NSJSONSerialization.dataWithJSONObject(allGigs, options: [])
                                                        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                                        
                                                        let parameters =  ["token": "\(resnateToken)", "multiGigs": string!]
                                                        
                                                        let URL = NSURL(string: "https://www.resnate.com/api/apiMultipleCreate/")!
                                                        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                                                        mutableURLRequest.HTTPMethod = Method.POST.rawValue
                                                        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                                                        
                                                        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    for previousGig in uGInts {
                                                        
                                                        if allGigsIDs.indexOf(previousGig) == nil {
                                                            
                                                            let parameters =  ["songkick_id": "\(previousGig)"]
                                                            
                                                            let URL = NSURL(string: "https://www.resnate.com/api/gigUndo/")!
                                                            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                                                            mutableURLRequest.HTTPMethod = Method.POST.rawValue
                                                            mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                                                            
                                                            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                                                                
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
                    
                    
                    let pastGigsLink = "https://api.songkick.com/api/3.0/users/\(songkickID)/gigography.json?apikey=Pxms4Lvfx5rcDIuR"
                    
                    request(.GET, pastGigsLink).responseJSON { response in
                        
                        if let re = response.result.value {
                            
                            let json = JSON(re)
                            
                            if let totalEntries = json["resultsPage"]["totalEntries"].int {
                                    
                                    let totalPages = totalEntries % 50
                                    
                                    for i in 1...totalPages {
                                        
                                        let pageUrl = "https://api.songkick.com/api/3.0/users/\(songkickID)/gigography.json?apikey=Pxms4Lvfx5rcDIuR&page=\(i)"
                                        
                                        request(.GET, pageUrl).responseJSON { response in
                                            
                                            if let re = response.result.value {
                                                
                                                let json = JSON(re)
                                                
                                                if let pastGigs = json["resultsPage"]["results"]["event"].array {
                                                    
                                                    var allPastGigs: [Dictionary<String, String>] = []
                                                    var allPastGigsIDs: [Int] = []
                                                    var pGInts: [Int] = []
                                                    
                                                    if let databasePastGigs = user["previousPastGigs"].array {
                                                        for pG in databasePastGigs {
                                                            if let pGInt = pG.int {
                                                                pGInts.append(pGInt)
                                                            }
                                                        }
                                                    }
                                                    
                                                    for pastGig in pastGigs {
                                                        
                                                        if let pastGigID = pastGig["id"].int {
                                                            
                                                            if pGInts.indexOf(pastGigID) == -1 {
                                                                
                                                                if let date = pastGig["start"]["date"].string {
                                                                    
                                                                    allPastGigs.append([ "songkick_id" : "\(pastGigID)", "gig_date" : "\(date)" ])
                                                                    allPastGigsIDs.append(pastGigID)
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    if allPastGigs.count > 0 {
                                                        
                                                        let data = try? NSJSONSerialization.dataWithJSONObject(allPastGigs, options: [])
                                                        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                                        
                                                        let parameters =  ["token": "\(resnateToken)", "multiGigs": string!]
                                                        
                                                        let URL = NSURL(string: "https://www.resnate.com/api/apiPastMultipleCreate/")!
                                                        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                                                        mutableURLRequest.HTTPMethod = Method.POST.rawValue
                                                        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                                                        
                                                        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                        }
                                        
                                    }
                                    
                            }
                            
                        }
                    }

                    
                } else {
                    
                    let songkickID = userDefaults.stringForKey("songkick_id")
                    
                    let parameters =  ["token": "\(resnateToken)", "songkickID": "\(songkickID)"]
                    
                    let URL = NSURL(string: "https://www.resnate.com/api/users/\(resnateID)")!
                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                    mutableURLRequest.HTTPMethod = Method.PUT.rawValue
                    mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                    
                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                        
                    }
                    
                }
                
            }
            
            
        }
        
        
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
    
    func shareSong(sender: AnyObject) {
        
        let song = self.songs[sender.view!.tag] as! [String: String]
        
        let songID = self.songIDs[sender.view!.tag]
        
        for (name, ytID) in song {
            
            ytPlayer.ytID = ytID
            
            ytPlayer.ytTitle = name
            
            ytPlayer.shareID = "\(songID)"
            
            share("Song", shareID: "\(songID)")
            
            
        }
        
        
        
    }
    
    
    
    func likeSong(sender: AnyObject) {
        
        if reachability!.isReachable() {
        
            let resnateToken = dictionary!["token"] as! String
        
            let parameters =  ["likeable_id" : sender.view!.tag, "likeable_type" : "Song", "token": "\(resnateToken)"]
        
        let likedSong = UIImageView(frame: CGRect(x: self.width/4 - 15, y: self.imgWidth + 120, width: 30, height: 30))
        
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
    
    func unlikeSong(sender: AnyObject) {
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["likeable_id" : sender.view!.tag, "likeable_type" : "Song", "token": "\(resnateToken)"]
        
        let unlikedSong = UIImageView(frame: CGRect(x: self.width/4 - 15, y: self.imgWidth + 120, width: 30, height: 30))
        
        sender.view!.superview?.addSubview(unlikedSong)
        
        let tapLike = UITapGestureRecognizer()
        
        
        unlikedSong.tag = sender.view!.tag
        
        unlikedSong.addGestureRecognizer(tapLike)
        
        unlikedSong.userInteractionEnabled = true
        
        unlikedSong.image = UIImage(named: "likeWhite")
        tapLike.addTarget(self, action: "likeSong:")
        
        sender.view!.removeFromSuperview()
        
        let URL = NSURL(string: "https://www.resnate.com/api/likes/")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.DELETE.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters as? [String : AnyObject]).0).responseJSON { response in

        }
    }
    
    func likeGig(sender: AnyObject) {
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["likeable_id" : sender.view!.tag, "likeable_type" : "Gig", "token": "\(resnateToken)"]
        
        let likeGig = UIImageView(frame: CGRect(x: self.width/4 - 15, y: self.imgWidth + 120, width: 30, height: 30))
        
        sender.view!.superview?.addSubview(likeGig)
        
        let tapLike = UITapGestureRecognizer()
        
        
        likeGig.tag = sender.view!.tag
        
        likeGig.addGestureRecognizer(tapLike)
        
        likeGig.userInteractionEnabled = true
        
        likeGig.image = UIImage(named: "liked")
        tapLike.addTarget(self, action: "unlikeGig:")
        
        sender.view!.removeFromSuperview()
        
        let URL = NSURL(string: "https://www.resnate.com/api/likes/")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters as? [String : AnyObject]).0).responseJSON { response in
        }
        
        
        
        
    }
    
    func unlikeGig(sender: AnyObject) {
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["likeable_id" : sender.view!.tag, "likeable_type" : "Gig", "token": "\(resnateToken)"]
        
        let unlikedGig = UIImageView(frame: CGRect(x: self.width/4 - 15, y: self.imgWidth + 120, width: 30, height: 30))
        
        sender.view!.superview?.addSubview(unlikedGig)
        
        let tapLikeGig = UITapGestureRecognizer()
        
        
        unlikedGig.tag = sender.view!.tag
        
        unlikedGig.addGestureRecognizer(tapLikeGig)
        
        unlikedGig.userInteractionEnabled = true
        
        unlikedGig.image = UIImage(named: "likeWhite")
        tapLikeGig.addTarget(self, action: "likeSong:")
        
        sender.view!.removeFromSuperview()
        
        let URL = NSURL(string: "https://www.resnate.com/api/likes/")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.DELETE.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters as? [String : AnyObject]).0).responseJSON { response in
            
        }
    }
    
    
    
    func repositionBadge(tab: Int){
        
        for badgeView in self.tabBarController!.tabBar.subviews[tab].subviews {
            
            if NSStringFromClass(badgeView.classForCoder) == "_UIBadgeView" {
                badgeView.layer.transform = CATransform3DIdentity
                badgeView.layer.transform = CATransform3DMakeTranslation(-17.0, 1.0, 1.0)
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) && scrollView.contentSize.height > 1) {
            
            let resnateToken = dictionary!["token"] as! String
            
            let resnateID = dictionary!["userID"] as! String
            
            let req = Router(OAuthToken: resnateToken, userID: resnateID)
            
            request(req.buildURLRequest("/activities/", path: "/index/\(page)")).responseJSON { response in
                if let re = response.result.value {
                    
                    let loadingView = UIActivityIndicatorView(frame: CGRect(x: Int(self.homeScroll.frame.width/2 - 25), y: Int(self.homeScroll.contentSize.height - 70), width: 50, height: 50))
                    
                    self.homeScroll.addSubview(loadingView)
                    
                    loadingView.startAnimating()
                    
                    
                    
                    let activities = JSON(re)
                    
                    var y = Int(self.homeScroll.contentSize.height + 10)
                    
                    
                    for (_, activity) in activities  {
                        
                        let getActivity = self.getActivity(y, activity: activity)
                        
                        y += getActivity.y
                        
                        self.homeScroll.addSubview(getActivity.activityView)
                        
                    }
                    
                    let delay = 0.3 * Double(NSEC_PER_SEC)
                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        loadingView.stopAnimating()
                    }
                    
                    self.homeScroll.contentSize.height = CGFloat(y + 20)
                    
                    self.page += 1
                    
                    
                }
            }
        }
    }
    
    func getReviewInfo(reviewID: Int, activityView: UIView, resnateToken: String, like: Bool, verbLabel: UILabel) {
        
        let shareReview = UIImageView(frame: CGRect(x: self.width/4 * 3 - 15, y: self.imgWidth + 120, width: 30, height: 30))
        
        shareReview.image = UIImage(named: "Share")
        
        activityView.addSubview(shareReview)
        
        let tapShareReview = UITapGestureRecognizer()
        
        shareReview.tag = reviewID
        
        shareReview.addGestureRecognizer(tapShareReview)
        
        shareReview.userInteractionEnabled = true
        
        let req = Router(OAuthToken: resnateToken, userID: String(reviewID))
        
        request(req.buildURLRequest("reviews/", path: "")).responseJSON { response in
            if let re = response.result.value {
                
                let review = JSON(re)
                
                if let reviewType = review["reviewable_type"].string {
                    
                    if let reviewContent = review["content"].string {
                        
                        if let reviewableID = review["reviewable_id"].int {
                            
                            let req = Router(OAuthToken: resnateToken, userID: String(reviewableID))
                            
                            let tapReview = UITapGestureRecognizer()
                            
                            tapReview.addTarget(self, action: "toReview:")
                            
                            let reviewNameLabel = UILabel(frame: CGRect(x: 80, y: 13.5, width: 240, height: 30))
                            
                            reviewNameLabel.textColor = UIColor.whiteColor()
                            reviewNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                            reviewNameLabel.numberOfLines = 2
                            
                            activityView.addSubview(reviewNameLabel)
                            
                            if reviewType == "PastGig" {
                                
                                tapShareReview.addTarget(self, action: "shareReview:")
                                
                                request(req.buildURLRequest("past_gigs/", path: "")).responseJSON { response in
                                    if let re = response.result.value {
                                        
                                        let pastGig = JSON(re)
                                        
                                        if let songkickID = pastGig["songkick_id"].int {
                                            
                                            let pgSK = "https://api.songkick.com/api/3.0/events/\(String(songkickID)).json?apikey=Pxms4Lvfx5rcDIuR"
                                            
                                            request(.GET, pgSK).responseJSON { response in
                                                if let re = response.result.value {
                                                    var json = JSON(re)
                                                    
                                                    if let artist = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["id"].int {
                                                        
                                                        let artistView = getArtistPic(artist)
                                                        artistView.frame = CGRect(x: 10, y: 70, width: self.imgWidth, height: self.imgWidth)
                                                        activityView.addSubview(artistView)
                                                        artistView.tag = reviewID
                                                        
                                                        artistView.addGestureRecognizer(tapReview)
                                                        artistView.userInteractionEnabled = true
                                                        
                                                        let reviewPreview = UIView(frame: CGRect(x: 0, y: 0, width: self.imgWidth, height: self.imgWidth))
                                                        
                                                        artistView.addSubview(reviewPreview)
                                                        
                                                        reviewPreview.backgroundColor = UIColor(white: 0, alpha: 0.6)
                                                        
                                                        let reviewPreviewText = UILabel(frame: CGRect(x: 20, y: 20, width: self.imgWidth - 40, height: self.imgWidth - 40))
                                                        
                                                        reviewPreview.addSubview(reviewPreviewText)
                                                        
                                                        reviewPreviewText.textColor = UIColor.whiteColor()
                                                        
                                                        reviewPreviewText.text = reviewContent
                                                        reviewPreviewText.textAlignment = .Center
                                                        reviewPreviewText.numberOfLines = 10
                                                        reviewPreviewText.font = UIFont(name: "HelveticaNeue-Italic", size: 14)
                                                        
                                                    }
                                                    
                                                    if let gigName = json["resultsPage"]["results"]["event"]["displayName"].string {
                                                        
                                                        reviewNameLabel.text = gigName
                                                        
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
                                        
                                        if let songName = song["name"].string {
                                            
                                            reviewNameLabel.text = songName
                                            
                                            if let songContent = song["content"].string {
                                                
                                                let activitysongImg = UIImageView(frame: CGRect(x: 10, y: 125, width: self.imgWidth, height: self.imgHeight))
                                                
                                                activityView.addSubview(activitysongImg)
                                                
                                                activitysongImg.addGestureRecognizer(tapReview)
                                                
                                                activitysongImg.tag = reviewID
                                                
                                                activitysongImg.userInteractionEnabled = true
                                                
                                                
                                                let songImgUrl = NSURL(string: "https://img.youtube.com/vi/\(songContent)/hqdefault.jpg")
                                                
                                                self.getDataFromUrl(songImgUrl!) { data in
                                                    dispatch_async(dispatch_get_main_queue()) {
                                                        
                                                        activitysongImg.image = UIImage(data: data!)
                                                        
                                                        
                                                        
                                                    }
                                                }
                                                
                                                let reviewPreview = UIView(frame: CGRect(x: 0, y: 0, width: self.imgWidth, height: self.imgHeight))
                                                
                                                activitysongImg.addSubview(reviewPreview)
                                                
                                                reviewPreview.backgroundColor = UIColor(white: 0, alpha: 0.6)
                                                
                                                let reviewPreviewText = UILabel(frame: CGRect(x: 20, y: 20, width: self.imgWidth - 40, height: self.imgHeight - 40))
                                                
                                                reviewPreview.addSubview(reviewPreviewText)
                                                
                                                reviewPreviewText.textColor = UIColor.whiteColor()
                                                
                                                reviewPreviewText.text = reviewContent
                                                reviewPreviewText.textAlignment = .Center
                                                reviewPreviewText.numberOfLines = 10
                                                reviewPreviewText.font = UIFont(name: "HelveticaNeue-Italic", size: 14)
                                                
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
