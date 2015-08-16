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
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = String(ID)
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        request(req.buildURLRequest("users/", path: "/likes")).responseJSON { (_, _, json, error) in
            if json != nil {
                
                let songs = JSON(json!)
                
                if let firstSong = songs[0].dictionary {
                    
                    let likesUberView = UIView(frame: CGRect(x: 0, y: 0, width: 350, height: 150))
                    
                    let content = firstSong["content"]!.string!
                    
                    let likesView = getYTPic("https://img.youtube.com/vi/\(content)/hqdefault.jpg")
                    
                    likesView.frame = CGRect(x: 0, y: 0, width: 133, height: 100)
                    
                    likesUberView.addSubview(likesView)
                    
                    var likesLabel = UILabel(frame: CGRect(x: 143, y: 30, width: 150, height: 30))
                    
                    setSKLabelText(likesLabel)
                    
                    likesLabel.text = "Liked"
                    
                    likesUberView.addSubview(likesLabel)
                    
                    self.userPlaylistsView.addSubview(likesUberView)
                    
                }
                
                
                
            }
        }
        
        
        request(req.buildURLRequest("users/", path: "/playlists")).responseJSON { (_, _, json, error) in
            if json != nil {
                
                let playlists = JSON(json!)
                
                
                var y = 200
                
                var i = 0
                
                for (index, playlist) in playlists {
                    
                    let playlistUberView = UIView(frame: CGRect(x: 0, y: y, width: 350, height: 150))
                    
                    self.userPlaylistsView.addSubview(playlistUberView)
                    
                    self.playlist.insert(playlist, atIndex: i)
                    
                    if let content = playlist["content"].string {
                        
                        
                        
                        var data: NSData = content.dataUsingEncoding(NSUTF8StringEncoding)!
                        
                        var jsonError: NSError?
                        
                        
                        
                        if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? [AnyObject]
                        {
                            
                            self.songs.insert(json, atIndex: i)
                            
                            let firstSong: AnyObject = json[0]
                            let song = firstSong as! [String: String]
                            for (name, ytID) in song {
                                let playlistView = getYTPic("https://img.youtube.com/vi/\(ytID)/hqdefault.jpg")
                                playlistView.frame = CGRect(x: 0, y: 0, width: 133, height: 100)
                                
                                let playlistName = playlist["name"].string!
                                
                                
                                var playlistLabel = UILabel(frame: CGRect(x: 143, y: 30, width: 150, height: 30))
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
                            
                            
                            
                        } else {
                            println(error)
                        }
                        
                    }
                    
                    i += 1
                    
                    y += 180
                    
                }
                
                self.userPlaylistsView.contentSize.height = CGFloat(y + 20)
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
        
        playlistTableViewController.playlist = self.playlist[sender.view!.tag]
        
        if let playlistID = self.playlist[sender.view!.tag]["id"].int {
            playlistTableViewController.playlistID = playlistID
        }
        
        self.navigationController?.pushViewController(playlistTableViewController, animated: true)
        
    }
    

}
