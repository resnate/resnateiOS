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
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(sender: AnyObject) {
        self.songs.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Table View
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
        
        var bgColorView = UIView()
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
    }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
        
        let resnateID = dictionary!["userID"] as! String
        
        let playlistUserID = String(playlist["user_id"].int!)
        
        if playlistUserID == resnateID {
            return true
        } else {
            return false
        }
        
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
        
        let resnateID = dictionary!["userID"] as! String
        
        let playlistUserID = String(playlist["user_id"].int!)
        
        if playlistUserID == resnateID {
            return true
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
        println("The dragged cell is about to be animated!")
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
        
        
        let data = NSJSONSerialization.dataWithJSONObject(allSongs, options: nil, error: nil)
        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
        println(string)
        
        
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        let playlistUserID = String(playlist["user_id"].int!)
        
        if playlistUserID == resnateID {
            
            let parameters =  ["content": string!]
            
            let URL = NSURL(string: "https://www.resnate.com/api/playlists/\(self.playlistID)")!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
            mutableURLRequest.HTTPMethod = Method.PUT.rawValue
            mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
            
            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { (_, _, JSON, error) in
                if JSON != nil {
                    println(JSON)
                }
            }
            
        }
        
        
    }
    
    func playSong(sender: UITapGestureRecognizer) {
        
        let ytPlayer = VideoPlayer.sharedInstance
        
        self.tabBarController?.view.addSubview(ytPlayer.videoPlayer)
        
        let song = self.songs[sender.view!.tag] as! [String: String]
        
        for (name, ytID) in song {
            
            ytPlayer.playVid(ytID, tag: sender.view!.tag)
            
            ytPlayer.ytID = ytID
            
            ytPlayer.ytTitle = name
            
            
        }
        
       
        self.tabBarController?.view.addSubview(ytPlayer.playerControls)
        
        
        
    }
    
    
    
}