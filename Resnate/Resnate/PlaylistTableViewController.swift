//
//  PlaylistTableViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 25/07/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class PlaylistTableViewController: LPRTableViewController {

    
    var playlist: JSON = ""
    
    var songs: [AnyObject] = []
    
    var playlistName = ""
    
    var playlistID = 0
    
    var playlistUserID = 0
    
    var likes = false
    
    var page = 1
    
    let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return songs.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
     return 50
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateID = dictionary!["userID"] as! String
        
        let resnateToken = dictionary!["token"] as! String
        
        if self.likes == true {
            
            self.navigationItem.title = "Likes"
            
        } else {
            
            self.navigationItem.title = playlistName
            
            let playlistUserID = String(playlist["user_id"].int!)
            
            if playlistUserID != resnateID {
                
                let ifReq = Router(OAuthToken: resnateToken, userID: resnateID)
                
                request(ifReq.buildURLRequest("/", path: "/\(self.playlistID)/ifFollow")).responseJSON { response in
                    
                    if let re = response.result.value {
                        
                        let ifFollow = JSON(re)
                        
                        if let ifTrue = ifFollow["ifFollows"].bool {
                            
                            if ifTrue == true {
                                
                                let unfollowButton = UIBarButtonItem(title: "Unfollow", style: .Plain, target: self, action: "unfollowPlaylist:")
                                
                                self.navigationItem.rightBarButtonItem = unfollowButton
                                
                                unfollowButton.tag = self.playlistID
                                
                            } else {
                                
                                let followButton = UIBarButtonItem(title: "Follow", style: .Plain, target: self, action: "followPlaylist:")
                                
                                self.navigationItem.rightBarButtonItem = followButton
                                
                                followButton.tag = self.playlistID
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            } else {
                
                let b = UIBarButtonItem(title: "", style: .Plain, target: self, action: "sharePlaylist:")
                b.image = UIImage(named: "Share")!.imageWithRenderingMode(.AlwaysOriginal)
                b.tag = self.playlistID
                self.navigationItem.rightBarButtonItem = b
                
            }
            
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        cell.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        cell.selectedBackgroundView = bgColorView

        if self.songs.count >= indexPath.row
        {
        
        if let song = songs[indexPath.row] as? [String: String] {
            for (name, ytID) in song {
            
                    cell.contentView.subviews.map({ $0.removeFromSuperview() })
                    let width = UIScreen.mainScreen().bounds.width
                    
                    let titleLabel = UILabel(frame: CGRect(x: 75, y: 0, width: width - 80, height: 50))
                    
                    titleLabel.text = name
                    
                    titleLabel.textColor = UIColor.whiteColor()
                    
                    titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
                    titleLabel.numberOfLines = 2
                    
                    cell.contentView.addSubview(titleLabel)
                    
                    let imgURL = NSURL(string: "https://img.youtube.com/vi/\(ytID)/hqdefault.jpg")
                    
                    let ytImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 67, height: 50))
                    
                    let tapVideo = UITapGestureRecognizer()
                    
                    tapVideo.addTarget(self, action: "playSong:")
                    cell.tag = indexPath.row
                    cell.addGestureRecognizer(tapVideo)
                    
                    cell.userInteractionEnabled = true
                    
                    self.getDataFromUrl(imgURL!) { data in
                        dispatch_async(dispatch_get_main_queue()) {
                            ytImgView.image = UIImage(data: data!)
                        }
                    }
                    
                    cell.contentView.addSubview(ytImgView)
                    cell.frame.size.height = 50
                    
                    self.lprTableView.separatorColor = UIColor.whiteColor()
                    if cell.respondsToSelector("setSeparatorInset:") {
                        cell.separatorInset = UIEdgeInsetsZero
                    }
                    if cell.respondsToSelector("setLayoutMargins:") {
                        cell.layoutMargins = UIEdgeInsetsZero
                    }
                    if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
                        cell.preservesSuperviewLayoutMargins = false
                    }

                    
                    
                }
                
            
        }
            
           
            
            if (indexPath.row ==  self.songs.count-1) {
                if self.likes == true {
                    
                    self.page += 1
                    
                    
                    
                    let resnateID = String(self.playlistUserID)
                    
                    let req = Router(OAuthToken: resnateToken, userID: resnateID)
                    
                    request(req.buildURLRequest("users/", path: "/likes/\(self.page)")).responseJSON { response in
                        
                        let songs = JSON(response.result.value!)
                        
                        for (_, song) in songs {
                            
                            var likedSong = [String: String]()
                            
                            let name = song["name"].string!
                            
                            let content = song["content"].string!
                            
                            likedSong = [ "\(name)" : "\(content)" ]
                            
                            self.songs.append(likedSong)
                            
                        }
                        
                        if songs.count > 0 {
                            self.tableView.reloadData()
                        }

                    }
                    
                }
            }
    }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateID = dictionary!["userID"] as! String
        
        if self.likes == false {
            
            let playlistUserID = String(playlist["user_id"].int!)
            
            if playlistUserID == resnateID {
                return true
            } else {
                return false
            }

            
        } else {
            return false
        }
        
        
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateID = dictionary!["userID"] as! String
        
        if self.likes == false {
            
            let playlistUserID = String(playlist["user_id"].int!)
            
            if playlistUserID == resnateID {
                return true
            } else {
                return false
            }
            
            
        } else {
            return false
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.songs.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    // MARK: - Long Press Reorder
    
    //
    // Important: Update your data source after the user reorders a cell.
    //
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        self.songs.insert(self.songs.removeAtIndex(sourceIndexPath.row), atIndex: destinationIndexPath.row)
    }
    
    //
    // Optional: Modify the cell (visually) before dragging occurs.
    //
    //    NOTE: Any changes made here should be reverted in `tableView:cellForRowAtIndexPath:`
    //          to avoid accidentally reusing the modifications.
    //
    override func tableView(tableView: UITableView, draggingCell cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //		cell.backgroundColor = UIColor(red: 165.0/255.0, green: 228.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        return cell
    }
    
    //
    // Optional: Called within an animation block when the dragging view is about to show.
    //
    override func tableView(tableView: UITableView, showDraggingView view: UIView, atIndexPath indexPath: NSIndexPath) {
        print("The dragged cell is about to be animated!")
    }
    
    //
    // Optional: Called within an animation block when the dragging view is about to hide.
    //
    override func tableView(tableView: UITableView, hideDraggingView view: UIView, atIndexPath indexPath: NSIndexPath) {
        
        var allSongs: [Dictionary<String, String>] = []
        
        for song in self.songs {
            
            if let song = song as? [String: String] {
                allSongs.append(song)
            }
            
        }
        
        
        let data = try? NSJSONSerialization.dataWithJSONObject(allSongs, options: [])
        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        if self.likes == false {
            
            let playlistUserID = String(playlist["user_id"].int!)
            
            if playlistUserID == resnateID {
                
                if playlistUserID == resnateID && self.likes == false {
                    
                    let parameters =  ["token": "\(resnateToken)", "content": string!]
                    
                    let URL = NSURL(string: "https://www.resnate.com/api/playlists/\(self.playlistID)")!
                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                    mutableURLRequest.HTTPMethod = Method.PUT.rawValue
                    mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                    
                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                        
                    }
                    
                }
                
            }
            
            
        }
        
        
    }
    
    func playSong(sender: UITapGestureRecognizer) {
        
        let ytPlayer = VideoPlayer.sharedInstance
        
        self.tabBarController?.view.addSubview(ytPlayer.videoPlayer)
        
        let song = self.songs[sender.view!.tag] as! [String: String]
        
        for (name, ytID) in song {
            
            ytPlayer.playVid(ytID)
            
            ytPlayer.ytID = ytID
            
            ytPlayer.ytTitle = name
            
            let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
            
            let resnateToken = dictionary!["token"] as! String
            
            let req = Router(OAuthToken: resnateToken, userID: "\(ytPlayer.ytID)/\(self.playlistUserID)")
            
            request(req.buildURLRequest("songs/", path: "/findSong")).responseJSON { response in
                
                if let re = response.result.value {
                    
                    let song = JSON(re)
                    
                    if let songID = song["songID"].string {
                        
                        ytPlayer.shareID = songID
                        
                    }
                    
                }
            }
            
            
        }
        
        
        
        
    }
    
    
    
}