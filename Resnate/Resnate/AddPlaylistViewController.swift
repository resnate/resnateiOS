//
//  AddPlaylistViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 18/11/2015.
//  Copyright © 2015 Resnate. All rights reserved.
//

import UIKit

class AddPlaylistViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var close: UIImageView!
    
    @IBOutlet weak var createNew: UITextField!
    
    @IBOutlet weak var playlistsScroll: UIScrollView!
    
    var song = [String: String]()
    
    var songs: [AnyObject] = []
    
    var playlistIDs = [Int]()
    
    let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.createNew.delegate = self
        
        self.createNew.returnKeyType = .Done

        let tapClose = UITapGestureRecognizer()
        
        tapClose.addTarget(self, action: "closeModal")
        
        close.userInteractionEnabled = true
        
        self.close.addGestureRecognizer(tapClose)
        
        self.createNew.frame.size.width = UIScreen.mainScreen().bounds.width
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        request(req.buildURLRequest("users/", path: "/playlists/1")).responseJSON { response in
            
            let playlists = JSON(response.result.value!)
            
            
            var y = 70
            
            for (i, playlist) in playlists {
                
                let playlistUberView = UIView(frame: CGRect(x: 0, y: y, width: Int(UIScreen.mainScreen().bounds.width), height: 50))
                
                playlistUberView.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                let tapThisPlaylist = UITapGestureRecognizer()
                tapThisPlaylist.addTarget(self, action: "addToThisPlaylist:")
                playlistUberView.addGestureRecognizer(tapThisPlaylist)
                playlistUberView.tag = Int(i)!
                
                if let id = playlist["id"].int {
                    
                    self.playlistIDs.append(id)
                    
                }
                
                self.playlistsScroll.addSubview(playlistUberView)
                
                if let content = playlist["content"].string {
                    
                    let data: NSData = content.dataUsingEncoding(NSUTF8StringEncoding)!
                    
                    
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [AnyObject]
                        
                        self.songs.insert(json, atIndex: Int(i)!)
                        
                        
                        let firstSong: AnyObject = json[0]
                        let song = firstSong as! [String: String]
                        for (_, ytID) in song {
                            let playlistUrl = NSURL(string: "https://img.youtube.com/vi/\(ytID)/hqdefault.jpg")
                            let playlistView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                            self.getDataFromUrl(playlistUrl!) { data in
                                dispatch_async(dispatch_get_main_queue()) {
                                    
                                    playlistView.image = UIImage(data: data!)
                                    
                                    
                                    
                                }
                            }
                            
                            let playlistName = playlist["name"].string!
                            
                            
                            let playlistLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 150, height: 50))
                            setSKLabelText(playlistLabel)
                            playlistLabel.text = playlistName
                            playlistUberView.addSubview(playlistLabel)
                            
                            playlistUberView.addSubview(playlistView)
                            
                            
                            
                            playlistUberView.userInteractionEnabled = true
                            
                        }
                        
                        y += 70
                        
                    } catch let error as NSError {
                        print("json error: \(error.localizedDescription)")
                    }
                    
                    
                    
                    
                }
                
                
                
            }
            
            self.playlistsScroll.contentSize.height = CGFloat(y + 20)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addToThisPlaylist(sender: AnyObject){
        
        var allSongs: [Dictionary<String, String>] = []
        
        for song in self.songs[sender.view!.tag] as! [AnyObject] {
            
            if let song = song as? [String: String] {
                allSongs.append(song)
            }
            
        }
        
        allSongs.append(self.song)
        
        
        let data = try? NSJSONSerialization.dataWithJSONObject(allSongs, options: [])
        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        let resnateToken = dictionary!["token"] as! String
        
        let playlistID = self.playlistIDs[sender.view!.tag]
        
        let parameters =  ["token": "\(resnateToken)", "content": string!]
        
        let URL = NSURL(string: "https://www.resnate.com/api/playlists/\(playlistID)")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
        mutableURLRequest.HTTPMethod = Method.PUT.rawValue
        mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
        
        request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
            
            sender.view!.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
            
            self.closeModal()
            
        }
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.text?.characters.count > 0 && textField.text?.characters.count < 200 {
            
            var songArray: [AnyObject] = []
            
            songArray.append(self.song)
            
            let data = try? NSJSONSerialization.dataWithJSONObject(songArray, options: [])
            let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            let resnateID = dictionary!["userID"] as! String
            
            let resnateToken = dictionary!["token"] as! String
            
            let playlistName = textField.text
            
            let parameters =  ["user_id": resnateID, "content": string!, "token": resnateToken, "name": playlistName! ]
            
            
            
            let URL = NSURL(string: "https://www.resnate.com/api/playlists")!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
            mutableURLRequest.HTTPMethod = Method.POST.rawValue
            mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
            
            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                
                if let re = response.result.value {
                    
                    let playlist = JSON(re)
                    
                    print(playlist)
                    
                    self.closeModal()
                    
                }
                
            }
            
        }
        return true
    }
    

}
