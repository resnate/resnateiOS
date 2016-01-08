//
//  UserPlaylistsViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 07/07/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class UserPlaylistsViewController: UIViewController, UIScrollViewDelegate {

    var ID = 0
    
    var songs: [AnyObject] = []
    
    var likedSongs: [AnyObject] = []
    
    var playlist: [JSON] = []
    
    var playlistNames: [String] = []
    
    var playlistDescriptions: [String] = []
    
    var followed = false
    
    var y = 200
    
    func loadPlaylists(){
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = String(ID)
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        request(req.buildURLRequest("users/", path: "/playlists/1")).responseJSON { response in
            
            let playlists = JSON(response.result.value!)
            
            var i = 0
            
            for (_, playlist) in playlists {
                
                if let name = playlist["name"].string {
                    
                    self.playlistNames.append(name)
                    
                }
                
                let playlistUberView = UIView(frame: CGRect(x: 0, y: self.y, width: 350, height: 250))
                
                self.userPlaylistsView.addSubview(playlistUberView)
                
                self.playlist.insert(playlist, atIndex: i)
                
                if let content = playlist["content"].string {
                    
                    
                    
                    let data: NSData = content.dataUsingEncoding(NSUTF8StringEncoding)!
                    
                    
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [AnyObject]
                        
                        self.songs.insert(json, atIndex: i)
                        
                        let firstSong: AnyObject = json[0]
                        let song = firstSong as! [String: String]
                        for (_, ytID) in song {
                            let playlistUrl = NSURL(string: "https://img.youtube.com/vi/\(ytID)/hqdefault.jpg")
                            let playlistView = UIImageView(frame: CGRect(x: 10, y: 0, width: 100, height: 100))
                            self.getDataFromUrl(playlistUrl!) { data in
                                dispatch_async(dispatch_get_main_queue()) {
                                    
                                    playlistView.image = UIImage(data: data!)
                                    
                                    
                                    
                                }
                            }
                            
                            let playlistName = playlist["name"].string!
                            
                            let playlistUserID = String(playlist["user_id"].int!)
                            
                            let playlistLabel = UILabel(frame: CGRect(x: 120, y: 0, width: 200, height: 60))
                            playlistLabel.numberOfLines = 2
                            setSKLabelText(playlistLabel)
                            playlistLabel.text = playlistName
                            playlistUberView.addSubview(playlistLabel)
                            
                            let addEditDescriptionLabel = UILabel(frame: CGRect(x: 120, y: 130, width: 100, height: 40))
                            addEditDescriptionLabel.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:0.9)
                            addEditDescriptionLabel.textColor = UIColor.whiteColor()
                            addEditDescriptionLabel.textAlignment = .Center
                            addEditDescriptionLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                            addEditDescriptionLabel.numberOfLines = 2
                            
                            let addEditTap = UITapGestureRecognizer()
                            addEditTap.addTarget(self, action: "addEditDescription:")
                            addEditDescriptionLabel.addGestureRecognizer(addEditTap)
                            addEditDescriptionLabel.userInteractionEnabled = true
                            addEditDescriptionLabel.tag = i
                            
                            if let description = playlist["description"].string {
                                
                                self.playlistDescriptions.append(description)
                                
                                playlistLabel.frame.origin.y = 0
                                let playlistDescriptionLabel = UILabel(frame: CGRect(x: 120, y: 60, width: 150, height: 50))
                                playlistDescriptionLabel.numberOfLines = 3
                                playlistDescriptionLabel.textColor = UIColor.whiteColor()
                                playlistDescriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
                                playlistDescriptionLabel.text = description
                                playlistUberView.addSubview(playlistDescriptionLabel)
                                
                                if playlistUserID == resnateID {
                                    
                                    addEditDescriptionLabel.text = "Edit \nDescription"
                                    playlistUberView.addSubview(addEditDescriptionLabel)
                                    
                                }
                                
                            } else {
                                
                                if playlistUserID == resnateID {
                                    
                                    self.playlistDescriptions.append("")
                                    
                                    addEditDescriptionLabel.text = "Add Description"
                                    playlistUberView.addSubview(addEditDescriptionLabel)
                                    
                                }
                                
                            }
                            
                            if let playlistID = playlist["id"].int {
                                
                                self.getFollowers(resnateToken, playlistID: playlistID, playlistUberView: playlistUberView)
                                
                            }
                            
                            
                            
                            playlistUberView.addSubview(playlistView)
                            
                            
                            let tapPlaylist = UITapGestureRecognizer()
                            
                            
                            tapPlaylist.addTarget(self, action: "playlist:")
                            playlistUberView.addGestureRecognizer(tapPlaylist)
                            playlistUberView.tag = i
                            
                            playlistUberView.userInteractionEnabled = true
                            
                        }
                        
                        i += 1
                        
                        self.y += 250
                        
                    } catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                    }
                    
                    
                    
                    
                }
                
                
                
            }
            
            self.userPlaylistsView.contentSize.height = CGFloat(self.y + 20)
        }
        
        
    }
    
    func getFollowers(resnateToken: String, playlistID: Int, playlistUberView: UIView){
        
        let followerCountLabel = UILabel(frame: CGRect(x: 10, y: 110, width: 100, height: 40))
        followerCountLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        followerCountLabel.textColor = UIColor.whiteColor()
        followerCountLabel.textAlignment = .Center
        playlistUberView.addSubview(followerCountLabel)
        
        let req = Router(OAuthToken: resnateToken, userID: String(playlistID))
        
        request(req.buildURLRequest("playlists/", path: "/followers")).responseJSON { response in
            if let re = response.result.value {
                let followers = JSON(re)
                let followersCount = followers.count
                
                if followersCount == 1 {
                    followerCountLabel.text = "1 follower"
                } else if followersCount > 1 {
                    followerCountLabel.text = "\(followersCount) followers"
                }
                
            }
        }
        
    }

    
    override func viewWillAppear(animated: Bool) {
        
        self.userPlaylistsView.subviews.map({ $0.removeFromSuperview() })
        
        self.y = 200
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = String(ID)
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        let followReq = Router(OAuthToken: resnateToken, userID: "")
        
        if self.followed == true {
            
            self.y = 0
            
            self.navigationItem.title = "Followed Playlists"
            
            request(followReq.buildURLRequest("\(resnateID)/", path: "/followedPlaylists")).responseJSON { response in
                
                if let re = response.result.value {
                    
                    let followedPlaylists = JSON(re)
                    
                    var i = 0
                    
                    for (_, playlist) in followedPlaylists {
                        
                        if let name = playlist["name"].string {
                            
                            self.playlistNames.append(name)
                            
                        }
                        
                        let playlistUberView = UIView(frame: CGRect(x: 0, y: self.y, width: 350, height: 250))
                        
                        self.userPlaylistsView.addSubview(playlistUberView)
                        
                        self.playlist.insert(playlist, atIndex: i)
                        
                        if let content = playlist["content"].string {
                            
                            let data: NSData = content.dataUsingEncoding(NSUTF8StringEncoding)!
                            
                            
                            do {
                                let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [AnyObject]
                                
                                self.songs.insert(json, atIndex: i)
                                
                                let firstSong: AnyObject = json[0]
                                let song = firstSong as! [String: String]
                                for (_, ytID) in song {
                                    let playlistUrl = NSURL(string: "https://img.youtube.com/vi/\(ytID)/hqdefault.jpg")
                                    let playlistView = UIImageView(frame: CGRect(x: 10, y: 0, width: 100, height: 100))
                                    self.getDataFromUrl(playlistUrl!) { data in
                                        dispatch_async(dispatch_get_main_queue()) {
                                            
                                            playlistView.image = UIImage(data: data!)
                                            
                                        }
                                    }
                                    
                                    let playlistName = playlist["name"].string!
                                    
                                    if let playlistID = playlist["id"].int {
                                        
                                        self.getFollowers(resnateToken, playlistID: playlistID, playlistUberView: playlistUberView)
                                        
                                    }
                                    
                                    if let playlistUserID = playlist["user_id"].int {
                                        
                                        let userReq = Router(OAuthToken: resnateToken, userID: String(playlistUserID))
                                        
                                        request(userReq.buildURLRequest("users/", path: "/profile")).responseJSON { response in
                                            
                                            if let re = response.result.value {
                                                
                                                let user = JSON(re)
                                                
                                                let playlistLabel = UILabel(frame: CGRect(x: 120, y: 0, width: 200, height: 100))
                                                playlistLabel.numberOfLines = 2
                                                setSKLabelText(playlistLabel)
                                                let userName = user["name"].string!
                                                playlistLabel.text = "\(playlistName) by \(userName)"
                                                playlistUberView.addSubview(playlistLabel)
                                                
                                            }
                                        }
                                        
                                    }
                                    
                                    playlistUberView.addSubview(playlistView)
                                    
                                    
                                    let tapPlaylist = UITapGestureRecognizer()
                                    
                                    
                                    tapPlaylist.addTarget(self, action: "playlist:")
                                    playlistUberView.addGestureRecognizer(tapPlaylist)
                                    playlistUberView.tag = i
                                    
                                    playlistUberView.userInteractionEnabled = true
                                    
                                }
                                
                                i += 1
                                
                                self.y += 250
                                
                            } catch let error as NSError {
                                print("json error: \(error.localizedDescription)")
                            }
                            
                            
                            
                            
                        }
                        
                        
                        
                    }
                    
                    self.userPlaylistsView.contentSize.height = CGFloat(self.y + 20)
                    
                }
            }
            
            
        } else {
            
            self.navigationItem.title = "Playlists"
            
            self.likedSongs = []
            
            request(req.buildURLRequest("users/", path: "/likes/1")).responseJSON { response in
                
                let songs = JSON(response.result.value!)
                
                for (_, song) in songs {
                    
                    var likedSong = [String: String]()
                    
                    let name = song["name"].string!
                    
                    let content = song["content"].string!
                    
                    likedSong = [ "\(name)" : "\(content)" ]
                    
                    self.likedSongs.append(likedSong)
                    
                }
                
                if let firstSong = songs[0].dictionary {
                    
                    let likesUberView = UIView(frame: CGRect(x: 0, y: 0, width: 350, height: 150))
                    
                    let content = firstSong["content"]!.string!
                    
                    let likesUrl = NSURL(string: "https://img.youtube.com/vi/\(content)/hqdefault.jpg")
                    let likesView = UIImageView(frame: CGRect(x: 10, y: 0, width: 100, height: 100))
                    self.getDataFromUrl(likesUrl!) { data in
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            likesView.image = UIImage(data: data!)
                            
                        }
                    }
                    
                    likesUberView.addSubview(likesView)
                    
                    let likesLabel = UILabel(frame: CGRect(x: 120, y: 30, width: 150, height: 30))
                    
                    setSKLabelText(likesLabel)
                    
                    likesLabel.text = "Liked"
                    
                    likesUberView.addSubview(likesLabel)
                    
                    self.userPlaylistsView.addSubview(likesUberView)
                    
                    let tapLikes = UITapGestureRecognizer()
                    
                    
                    tapLikes.addTarget(self, action: "likes:")
                    likesUberView.addGestureRecognizer(tapLikes)
                    likesUberView.tag = self.ID
                    likesUberView.userInteractionEnabled = true
                    
                }
            }
            
            
            
            request(followReq.buildURLRequest("\(resnateID)/", path: "/firstFollowedPlaylist")).responseJSON { response in
                
                if let re = response.result.value {
                    
                    let firstFollowedPlaylist = JSON(re)
                    
                    if let content = firstFollowedPlaylist["content"].string {
                        
                        let playlistUberView = UIView(frame: CGRect(x: 0, y: self.y, width: 350, height: 250))
                        
                        let data: NSData = content.dataUsingEncoding(NSUTF8StringEncoding)!
                        
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [AnyObject]
                            
                            let firstSong: AnyObject = json[0]
                            let song = firstSong as! [String: String]
                            for (_, ytID) in song {
                                let playlistUrl = NSURL(string: "https://img.youtube.com/vi/\(ytID)/hqdefault.jpg")
                                let playlistView = UIImageView(frame: CGRect(x: 10, y: 0, width: 100, height: 100))
                                self.getDataFromUrl(playlistUrl!) { data in
                                    dispatch_async(dispatch_get_main_queue()) {
                                        
                                        playlistView.image = UIImage(data: data!)
                                        
                                    }
                                }
                                
                                let playlistLabel = UILabel(frame: CGRect(x: 120, y: 0, width: 200, height: 60))
                                playlistLabel.numberOfLines = 2
                                setSKLabelText(playlistLabel)
                                playlistLabel.text = "Followed Playlists"
                                playlistUberView.addSubview(playlistLabel)
                                
                                playlistUberView.addSubview(playlistView)
                                
                                
                                let tapFollowedPlaylists = UITapGestureRecognizer()
                                
                                
                                tapFollowedPlaylists.addTarget(self, action: "toFollowedPlaylists")
                                playlistUberView.addGestureRecognizer(tapFollowedPlaylists)
                                playlistUberView.tag = Int(resnateID)!
                                
                                playlistUberView.userInteractionEnabled = true
                                
                                self.userPlaylistsView.addSubview(playlistUberView)
                                
                            }
                            
                            self.y += 180
                            
                            self.loadPlaylists()
                            
                        } catch let error as NSError {
                            print("json error: \(error.localizedDescription)")
                        }
                        
                    } else {
                        
                        self.loadPlaylists()
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet weak var userPlaylistsView: UIScrollView!
    
    func playlist(sender: UITapGestureRecognizer){
        
        let playlistTableViewController:PlaylistTableViewController = PlaylistTableViewController(nibName: nil, bundle: nil)
        
        playlistTableViewController.songs = self.songs[sender.view!.tag] as! [AnyObject]
        
        playlistTableViewController.likes = false
        
        playlistTableViewController.playlist = self.playlist[sender.view!.tag]
        
        playlistTableViewController.playlistName = self.playlistNames[sender.view!.tag]
        
        if let playlistID = self.playlist[sender.view!.tag]["id"].int {
            playlistTableViewController.playlistID = playlistID
            playlistTableViewController.playlistUserID = self.ID
        }
        
        self.navigationController?.pushViewController(playlistTableViewController, animated: true)
        
    }
    
    func likes(sender: UITapGestureRecognizer){
        
        let playlistTableViewController:PlaylistTableViewController = PlaylistTableViewController(nibName: nil, bundle: nil)
        
        playlistTableViewController.songs = self.likedSongs
        
        playlistTableViewController.likes = true
       
        playlistTableViewController.playlistUserID = self.ID
        
        self.navigationController?.pushViewController(playlistTableViewController, animated: true)
        
    }
    
    func toFollowedPlaylists(){
        
        let userPlaylistsViewController:UserPlaylistsViewController = UserPlaylistsViewController(nibName: "UserPlaylistsViewController", bundle: nil)
        
        userPlaylistsViewController.ID = self.ID
        
        userPlaylistsViewController.followed = true
        
        self.navigationController?.pushViewController(userPlaylistsViewController, animated: true)
        
    }
    
    func addEditDescription(sender: UITapGestureRecognizer){
        
        let writePlaylistDescriptionViewController = WritePlaylistDescriptionViewController(nibName: "WritePlaylistDescriptionViewController", bundle: nil)
        
        if let playlistID = self.playlist[sender.view!.tag]["id"].int {
            writePlaylistDescriptionViewController.ID = playlistID
            let playlistDescription = self.playlistDescriptions[sender.view!.tag]
            writePlaylistDescriptionViewController.playlistDescription = playlistDescription
            self.navigationController?.pushViewController(writePlaylistDescriptionViewController, animated: true)
        }
        
    }
    

}
