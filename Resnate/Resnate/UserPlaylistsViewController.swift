//
//  UserPlaylistsViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 07/07/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class UserPlaylistsViewController: UIViewController {

    var ID = 0
    
    var songs: [AnyObject] = []
    
    var playlist: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        
    }

    
    override func viewWillAppear(animated: Bool) {
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = String(ID)
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        request(req.buildURLRequest("users/", path: "/likes")).responseJSON { response in
                
                let songs = JSON(response.result.value!)
                
                if let firstSong = songs[0].dictionary {
                    
                    let likesUberView = UIView(frame: CGRect(x: 0, y: 0, width: 350, height: 150))
                    
                    let content = firstSong["content"]!.string!
                    
                    let likesUrl = NSURL(string: "https://img.youtube.com/vi/\(content)/hqdefault.jpg")
                    let likesView = UIImageView(frame: CGRect(x: 0, y: 0, width: 133, height: 100))
                    self.getDataFromUrl(likesUrl!) { data in
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            likesView.image = UIImage(data: data!)
                            
                            
                            
                        }
                    }
                    
                    likesUberView.addSubview(likesView)
                    
                    let likesLabel = UILabel(frame: CGRect(x: 143, y: 30, width: 150, height: 30))
                    
                    setSKLabelText(likesLabel)
                    
                    likesLabel.text = "Liked"
                    
                    likesUberView.addSubview(likesLabel)
                    
                    self.userPlaylistsView.addSubview(likesUberView)
                    
                }
        }
        
        
        request(req.buildURLRequest("users/", path: "/playlists")).responseJSON { response in
                
                let playlists = JSON(response.result.value!)
                
                
                var y = 200
                
                var i = 0
                
                for (_, playlist) in playlists {
                    
                    let playlistUberView = UIView(frame: CGRect(x: 0, y: y, width: 350, height: 150))
                    
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
                                let playlistView = UIImageView(frame: CGRect(x: 0, y: 0, width: 133, height: 100))
                                self.getDataFromUrl(playlistUrl!) { data in
                                    dispatch_async(dispatch_get_main_queue()) {
                                        
                                        playlistView.image = UIImage(data: data!)
                                        
                                        
                                        
                                    }
                                }
                                
                                let playlistName = playlist["name"].string!
                                
                                
                                let playlistLabel = UILabel(frame: CGRect(x: 143, y: 30, width: 150, height: 30))
                                setSKLabelText(playlistLabel)
                                playlistLabel.text = playlistName
                                playlistUberView.addSubview(playlistLabel)
                                
                                playlistUberView.addSubview(playlistView)
                                
                                
                                let tapPlaylist = UITapGestureRecognizer()
                                
                                
                                tapPlaylist.addTarget(self, action: "playlist:")
                                playlistUberView.addGestureRecognizer(tapPlaylist)
                                playlistUberView.tag = i
                                
                                playlistUberView.userInteractionEnabled = true
                                
                            }
                            
                            i += 1
                            
                            y += 180
                            
                        } catch let error as NSError {
                            print("json error: \(error.localizedDescription)")
                        }
                        
                        
                            
                        
                        }
                    
                    
                    
                }
                
                self.userPlaylistsView.contentSize.height = CGFloat(y + 20)
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
        
        playlistTableViewController.playlist = self.playlist[sender.view!.tag]
        
        if let playlistID = self.playlist[sender.view!.tag]["id"].int {
            playlistTableViewController.playlistID = playlistID
        }
        
        self.navigationController?.pushViewController(playlistTableViewController, animated: true)
        
    }
    

}
