//
//  SetlistViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 17/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class SetlistViewController: UIViewController {
    
    var ID = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Setlist"
        
        let height = UIScreen.mainScreen().bounds.height
        
        let width = UIScreen.mainScreen().bounds.width
        
        
        
        
        let pgSK = "https://api.songkick.com/api/3.0/events/\(String(ID)).json?apikey=Pxms4Lvfx5rcDIuR"
        
        request(.GET, pgSK).responseJSON { (_, _, json, _) in
            if json != nil {
                var json = JSON(json!)
                
                
                
                let location = json["resultsPage"]["results"]["event"]["venue"]["metroArea"]["displayName"].string!
                
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let date = json["resultsPage"]["results"]["event"]["start"]["date"].string!
                
                var setlistDateString = dateFormatter.dateFromString(date)
                
                let secondFormatter = NSDateFormatter()
                secondFormatter.dateFormat = "dd-MM-yyyy"
                
                
                let setlistDate = secondFormatter.stringFromDate(setlistDateString!)
                
                
                
                
                
                if let artistName = json["resultsPage"]["results"]["event"]["performance"][0]["artist"]["displayName"].string {
                    
                    
                    var setlistURL = "http://api.setlist.fm/rest/0.1/search/setlists.json"
                    
                    let parameters = [
                        "artistName": artistName,
                        "cityName": location,
                        "date": setlistDate,
                        "apikey": "ece37fb8-74e5-40e1-b04a-a0c4f23b732d"
                    ]
                    
                    
                    request(.GET, setlistURL, parameters: parameters)
                        .responseJSON { (_, _, json, error) in
                            if json != nil {
                                
                                var y = 5
                                
                                var json = JSON(json!)
                                if (json["setlists"]["setlist"].array != nil) {
                                    
                                    
                                    let show = json["setlists"]["setlist"].array
                                    
                                    
                                } else {
                                    
                                    
                                    
                                    if let result = json["setlists"]["setlist"]["sets"]["set"].array {
                                        
                                        if result.count == 1 {
                                            
                                            
                                        } else {
                                            for set in result {
                                                
                                                
                                                
                                                let indiSet =  set["song"]
                                                
                                                if let name = indiSet["@name"].string {
                                                    let setlistSong = UILabel(frame: CGRect(x: 0, y: y, width: 200, height: 30))
                                                    setlistSong.center.x = width/2
                                                    setlistSong.text = name
                                                    setlistSong.textAlignment = .Center
                                                    setlistSong.textColor = UIColor.whiteColor()
                                                    self.setlistScroll.addSubview(setlistSong)
                                                    y += 40
                                                }
                                                    
                                                else {
                                                    
                                                    let j = indiSet.count - 1
                                                    
                                                    for i in 0...j {
                                                        if let song = indiSet[i]["@name"].string {
                                                            if song != "" {
                                                                let name = song
                                                                let setlistSong = UILabel(frame: CGRect(x: 0, y: y, width: 200, height: 30))
                                                                setlistSong.center.x = width/2
                                                                setlistSong.text = name
                                                                setlistSong.textAlignment = .Center
                                                                setlistSong.textColor = UIColor.whiteColor()
                                                                self.setlistScroll.addSubview(setlistSong)
                                                                y += 40
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                    
                                                    
                                                }
                                                
                                                
                                                
                                                
                                                
                                            }
                                        }
                                        
                                    } else {
                                        
                                        if let result = json["setlists"]["setlist"]["sets"]["set"]["song"].array {
                                            
                                            for song in result {
                                                
                                                if let name = song["@name"].string {
                                                    let setlistSong = UILabel(frame: CGRect(x: 0, y: y, width: 200, height: 30))
                                                    setlistSong.center.x = width/2
                                                    setlistSong.text = name
                                                    setlistSong.textAlignment = .Center
                                                    setlistSong.textColor = UIColor.whiteColor()
                                                    self.setlistScroll.addSubview(setlistSong)
                                                    y += 40
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                let setlistView = self.setlistScroll
                                
                                setlistView.contentSize.height = CGFloat(y + 20)
                                
                                
                                
                            }
                    }
                    
                }
                
                
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var setlistScroll: UIScrollView!
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
