//
//  ArtistsViewController.swift
//
//  Created by Amir Moosavi on 15/05/2015.
//  Copyright (c) 2015 Medigarage Studios LTD. All rights reserved.
//

import UIKit
import CoreTelephony

class ArtistsViewController: UIViewController, UISearchBarDelegate, YouTubePlayerDelegate, VideoPlayerUIViewDelegate, UIScrollViewDelegate {
    
    var webURL = ""
    
    var moreGigs = ""
    
    var amazonURLs: [AnyObject] = []
    
    var country = ""
    
    var moreAmazonURL = ""
    
    var ytURLs: [AnyObject] = []
    
    var ytTitles: [AnyObject] = []
    
    let width = UIScreen.mainScreen().bounds.width
    
    let height = UIScreen.mainScreen().bounds.height
    
    let ytPlayer = VideoPlayer.sharedInstance
    
    let allGigsView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 300))
    
    lazy var searchArtistBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width - 30, 20))
    
    var y = 0
    
    var i = 0
    
    var allSongsView = UIView(frame: CGRect(x: 0, y: 550, width: UIScreen.mainScreen().bounds.width, height: 50))
    
    var userSearch = ""
    
    var nextPageToken = ""
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.artistView.delegate = self
        
        searchArtistBar.placeholder = "Search Artists"
        
        self.navigationController!.navigationBar.translucent = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        let leftNavBarButton = UIBarButtonItem(customView:searchArtistBar)
        
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
        self.artistView.addSubview(self.allGigsView)
        
        searchArtistBar.delegate = self
        ytPlayer.delegate = self
        let networkInfo = CTTelephonyNetworkInfo()
        
        if let carrier = networkInfo.subscriberCellularProvider {
            self.country = carrier.mobileCountryCode!
        }
        
        let searchLabel = UILabel(frame: CGRect(x: 100, y: 20, width: width - 200 , height: 200))
        
        searchLabel.text = "Search for Music, Gigs & Merch"
        
        searchLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22)
        
        searchLabel.textColor = UIColor.whiteColor()
        
        searchLabel.numberOfLines = 3
        
        searchLabel.textAlignment = .Center
        
        self.allGigsView.addSubview(searchLabel)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var artistView: UIScrollView!
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                searchBar.resignFirstResponder()
            }
            
        }
        
    }
    
    func loadSongs(userSearch: String){
        
        let ytSearch = "https://www.googleapis.com/youtube/v3/search?part=snippet&videoCategoryId=10&q=\(userSearch)&type=video&maxResults=50&order=relevance&sortorder=descending&&pageToken=\(self.nextPageToken)&key=AIzaSyCa2qY9zSZWCKyX6HftBDvSSszkjJQSd8Y"
        
        request(.GET, ytSearch).responseJSON { response in
            let results = JSON(response.result.value!)
            
            if let songs = results["items"].array {
                
                
                for song in songs {
                    
                    let songView = UIView(frame: CGRect(x: 0, y: self.y, width: Int(self.width), height: 50))
                    
                    songView.backgroundColor = UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)
                    
                    
                    
                    if let videoID = song["id"]["videoId"].string {
                        
                        self.ytURLs.insert(videoID, atIndex: self.i)
                        
                        let tapVideo = UITapGestureRecognizer()
                        
                        tapVideo.addTarget(self, action: "playSong:")
                        songView.tag = self.i
                        songView.addGestureRecognizer(tapVideo)
                        
                        songView.userInteractionEnabled = true
                        
                        
                        let imgURL = NSURL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")
                        
                        let ytImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 67, height: 50))
                        
                        self.getDataFromUrl(imgURL!) { data in
                            dispatch_async(dispatch_get_main_queue()) {
                                ytImgView.image = UIImage(data: data!)
                            }
                        }
                        
                        songView.addSubview(ytImgView)
                        
                        if let title = song["snippet"]["title"].string {
                            
                            self.ytTitles.insert(title, atIndex: self.i)
                            
                            let titleLabel = UILabel(frame: CGRect(x: 75, y: 5, width: self.width - 80, height: 40))
                            
                            titleLabel.text = title
                            
                            titleLabel.textColor = UIColor.whiteColor()
                            
                            titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
                            titleLabel.numberOfLines = 2
                            
                            songView.addSubview(titleLabel)
                        }
                        
                    }
                    
                    self.y += 60
                    
                    self.allSongsView.addSubview(songView)
                    
                    self.i += 1
                    
                    self.allSongsView.frame.size.height = CGFloat(self.y)
                    
                }
                
                self.artistView.contentSize.height = CGFloat(self.y + 550)
                
                if let pageToken = results["nextPageToken"].string {
                    
                    self.nextPageToken = pageToken
                    
                } else {
                    
                    self.nextPageToken = ""
                    
                }
                
            }
        }
        
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        self.allGigsView.subviews.map({ $0.removeFromSuperview() })
        
        self.artistView.subviews.map({ $0.removeFromSuperview() })
        
        self.artistView.addSubview(self.allSongsView)
        
        self.artistView.addSubview(self.allGigsView)
        
        self.userSearch = searchArtistBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        self.y = 0
        
        self.i = 0
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: String(resnateID))
        
        let amazonView = UIView(frame: CGRect(x: 0, y: 300, width: self.width, height: 120))
        
        amazonView.backgroundColor = UIColor.whiteColor()
        
        self.artistView.addSubview(amazonView)
        
        request(req.buildURLRequest("AmazonStore/", path: "/\(userSearch)")).responseJSON { response in
            
            if let re = response.result.value {
                
                let results = JSON(re)
                
                var x = 10

                let thirdWidth = Int(self.width/3)
                
                let moreMerchView = UIView(frame: CGRect(x: 0, y: 430, width: self.width, height: 30))
                
                let moreMerch = UILabel(frame: CGRect(x: 10, y: 0, width: self.width, height: 30))
                
                moreMerch.text = "Find more merch at"
                
                setSKLabelText(moreMerch)
                
                moreMerchView.addSubview(moreMerch)
                
                let amazonImgView = UIImageView(frame: CGRect(x: 183, y: 11, width: 70, height: 20))
                
                let amazonImg = UIImage(named: "amazon")
                
                amazonImgView.image = amazonImg
                
                moreMerchView.addSubview(amazonImgView)
                
                let tapRec = UITapGestureRecognizer()
                
                if self.country == "234" {
                    self.moreAmazonURL = "https://www.amazon.co.uk/s/ref=sr_nr_n_8?rh=n%3A83450031%2Ck%3A&keywords=\(self.userSearch)"
                    
                } else if self.country == "340" {
                    self.moreAmazonURL = "https://www.amazon.fr/s/ref=sr_nr_n_8?url=search-alias%3Dclothing&field-keywords=\(self.userSearch)"
                    
                } else {
                    self.moreAmazonURL = "https://www.amazon.com/s/ref=sr_nr_n_8?url=search-alias%3Dapparel&field-keywords=\(self.userSearch)"
                }
                
                tapRec.addTarget(self, action: "moreAmazon")
                moreMerchView.addGestureRecognizer(tapRec)
                
                moreMerchView.userInteractionEnabled = true
                
                self.artistView.addSubview(moreMerchView)
                
                for (index, result) in results {
                    
                    if let imageURL = result["image"].string {
                        
                        let amazonURL = result["link"].string!
                        
                        self.amazonURLs.insert(amazonURL, atIndex: Int(index)!)
                        
                        let imageNSURL = NSURL(string: imageURL)
                        let data = NSData(contentsOfURL: imageNSURL!)
                        let merchImg = UIImage(data: data!)
                        let merchImgView = UIImageView(image: merchImg!)
                        
                        merchImgView.frame = CGRect(x: x, y: 10, width: 100 , height: 100)
                        
                        let tapRec = UITapGestureRecognizer()
                        
                        
                        tapRec.addTarget(self, action: "amazon:")
                        merchImgView.tag = Int(index)!
                        merchImgView.addGestureRecognizer(tapRec)
                        
                        merchImgView.userInteractionEnabled = true
                        
                        
                        amazonView.addSubview(merchImgView)
                        
                        x += thirdWidth
                        
                        
                    } else {
                        
                        let noMerchView = UILabel(frame: CGRect(x: 0, y: 20, width: 180, height: 75))
                        
                        noMerchView.center.x = self.width/2
                        
                        noMerchView.textAlignment = .Center
                        
                        noMerchView.text = "No Merch Available"
                        
                        noMerchView.font = UIFont(name: "HelveticaNeue-Light", size: 20)
                        
                        amazonView.addSubview(noMerchView)
                        
                    }
                    
                }
                
            } else {
                
                let noMerchView = UILabel(frame: CGRect(x: 0, y: 20, width: 180, height: 75))
                
                noMerchView.center.x = self.width/2
                
                noMerchView.textAlignment = .Center
                
                noMerchView.text = "No Merch Available"
                
                noMerchView.font = UIFont(name: "HelveticaNeue-Light", size: 20)
                
                amazonView.addSubview(noMerchView)
                
            }

        }
        
        request(req.buildURLRequest("", path: "/\(userSearch)/friendsWhoLike")).responseJSON { response in
            
            if let re = response.result.value {
                
                let friends = JSON(re)
                
                var x = 10
                
                for (_, friend) in friends {
                    
                    if CGFloat(x + 60) < UIScreen.mainScreen().bounds.width {
                        
                        if let image_id = friend["uid"].string {
                            
                            let imgUrl = NSURL(string: "https://graph.facebook.com/\(image_id)/picture?width=500&height=500")
                            
                            self.getDataFromUrl(imgUrl!) { data in
                                dispatch_async(dispatch_get_main_queue()) {
                                    
                                    let userImageView = UIImageView(frame: CGRect(x: x, y: 480, width: 50, height: 50))
                                    userImageView.image = UIImage(data: data!)
                                    self.artistView.addSubview(userImageView)
                                    
                                    x += 60
                                    
                                    let tapRecProfile = UITapGestureRecognizer()
                                    tapRecProfile.addTarget(self, action: "profile:")
                                    
                                    if let user_id = friend["id"].int {
                                        
                                        userImageView.tag = user_id
                                        userImageView.addGestureRecognizer(tapRecProfile)
                                        userImageView.userInteractionEnabled = true
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                    
                }
                
            }
            
        }

        let url="https://api.songkick.com/api/3.0/search/artists.json?query=\(userSearch)&apikey=Pxms4Lvfx5rcDIuR"
        
        let moreGigsView = UIView(frame: CGRect(x: 0, y: 250, width: width, height: 30))
        
        let moreGigs = UILabel(frame: CGRect(x: 10, y: 0, width: width, height: 30))
        
        moreGigs.text = "Find more concerts at"
        
        setSKLabelText(moreGigs)
        
        moreGigsView.addSubview(moreGigs)
        
        let songkickImgView = UIImageView(frame: CGRect(x: 203, y: 5.5, width: 90, height: 25))
        
        let songkickImg = UIImage(named: "songkick")
        
        songkickImgView.image = songkickImg
        
        moreGigsView.addSubview(songkickImgView)
        
        artistView.addSubview(moreGigsView)
        
        request(.GET, url).responseJSON { response in
            
            if let re = response.result.value {
                
                let json = JSON(re)
                
                if let totalEntries = json["resultsPage"]["totalEntries"].int {
                    
                    if totalEntries != 0 {
                        
                        
                        if let artists = json["resultsPage"]["results"]["artist"].array {
                            
                            let artist = artists[0]["displayName"].string!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                            
                            let id = artists[0]["id"].int!
                            
                            let tapRec = UITapGestureRecognizer()
                            
                            
                            tapRec.addTarget(self, action: "artistURL:")
                            moreGigsView.tag = id
                            moreGigsView.addGestureRecognizer(tapRec)
                            
                            let url="https://api.songkick.com/api/3.0/events.json?apikey=Pxms4Lvfx5rcDIuR&artist_name=\(artist)&location=clientip"
                            
                            request(.GET, url).responseJSON { response in
                                
                                let json = JSON(response.result.value!)
                                
                                if let totalEntries = json["resultsPage"]["totalEntries"].int {
                                    
                                    if totalEntries != 0 {
                                        
                                        if let events = json["resultsPage"]["results"]["event"].array {
                                            
                                            var y = 10
                                            
                                            var j = 0
                                            
                                            if totalEntries < 3 {
                                                j = totalEntries - 1
                                            } else {
                                                j = 2
                                            }
                                            
                                            for i in 0...j {
                                                
                                                let gigView = UIView(frame: CGRect(x: 0, y: y, width: 350, height: 60))
                                                
                                                let gigMonth = UILabel(frame: CGRect(x: 10, y: 0, width: 50, height: 20))
                                                
                                                gigMonth.backgroundColor = UIColor.redColor()
                                                
                                                let date = events[i]["start"]["date"].string!
                                                
                                                let day = returnDayAndMonth(date).day
                                                
                                                let month = returnDayAndMonth(date).month
                                                
                                                let dayLabel = UILabel(frame: CGRect(x: 10, y: 20, width: 40, height: 35))
                                                
                                                dayLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                                                
                                                dayLabel.textAlignment = .Center
                                                
                                                dayLabel.text = day
                                                dayLabel.backgroundColor = UIColor.whiteColor()
                                                
                                                let monthLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 40, height: 22))
                                                monthLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
                                                monthLabel.backgroundColor = UIColor.redColor()
                                                monthLabel.text = month as String
                                                monthLabel.textColor = UIColor.whiteColor()
                                                monthLabel.textAlignment = .Center
                                                
                                                gigView.addSubview(dayLabel)
                                                gigView.addSubview(monthLabel)
                                                
                                                
                                                
                                                let gigName = events[i]["displayName"].string!
                                                
                                                let gigNameLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 250, height: 60))
                                                gigNameLabel.text = gigName
                                                gigNameLabel.textColor = UIColor.whiteColor()
                                                gigNameLabel.lineBreakMode = .ByTruncatingTail
                                                gigNameLabel.numberOfLines = 0
                                                
                                                gigNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                                gigNameLabel.sizeToFit()
                                                
                                                gigView.addSubview(gigNameLabel)
                                                
                                                let tapRec = UITapGestureRecognizer()
                                                
                                                
                                                tapRec.addTarget(self, action: "setURL:")
                                                gigView.tag = events[i]["id"].int!
                                                gigView.addGestureRecognizer(tapRec)
                                                
                                                self.allGigsView.addSubview(gigView)
                                                
                                                
                                                y += 80
                                                
                                            }
                                        }
                                        
                                        
                                        
                                    } else {
                                        
                                        let artist_url="https://api.songkick.com/api/3.0/artists/\(id)/calendar.json?apikey=Pxms4Lvfx5rcDIuR"
                                        
                                        request(.GET, artist_url).responseJSON { response in
                                            
                                            let json = JSON(response.result.value!)
                                            
                                            if let totalEntries = json["resultsPage"]["totalEntries"].int {
                                                
                                                if totalEntries != 0 {
                                                    
                                                    if let events = json["resultsPage"]["results"]["event"].array {
                                                        
                                                        var y = 10
                                                        
                                                        var j = 0
                                                        
                                                        if totalEntries < 3 {
                                                            j = totalEntries - 1
                                                        } else {
                                                            j = 2
                                                        }
                                                        
                                                        for i in 0...j {
                                                            
                                                            let gigView = UIView(frame: CGRect(x: 0, y: y, width: 350, height: 60))
                                                            
                                                            let gigMonth = UILabel(frame: CGRect(x: 10, y: 0, width: 50, height: 20))
                                                            
                                                            gigMonth.backgroundColor = UIColor.redColor()
                                                            
                                                            let date = events[i]["start"]["date"].string!
                                                            
                                                            let day = returnDayAndMonth(date).day
                                                            
                                                            let month = returnDayAndMonth(date).month
                                                            
                                                            let dayLabel = UILabel(frame: CGRect(x: 10, y: 20, width: 40, height: 35))
                                                            
                                                            dayLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                                                            
                                                            dayLabel.textAlignment = .Center
                                                            
                                                            dayLabel.text = day
                                                            dayLabel.backgroundColor = UIColor.whiteColor()
                                                            
                                                            let monthLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 40, height: 22))
                                                            monthLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
                                                            monthLabel.backgroundColor = UIColor.redColor()
                                                            monthLabel.text = month as String
                                                            monthLabel.textColor = UIColor.whiteColor()
                                                            monthLabel.textAlignment = .Center
                                                            
                                                            gigView.addSubview(dayLabel)
                                                            gigView.addSubview(monthLabel)
                                                            
                                                            
                                                            
                                                            let gigName = events[i]["displayName"].string!
                                                            
                                                            let gigNameLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 250, height: 60))
                                                            gigNameLabel.text = gigName
                                                            gigNameLabel.textColor = UIColor.whiteColor()
                                                            gigNameLabel.lineBreakMode = .ByTruncatingTail
                                                            gigNameLabel.numberOfLines = 0
                                                            
                                                            gigNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                                                            gigNameLabel.sizeToFit()
                                                            
                                                            gigView.addSubview(gigNameLabel)
                                                            
                                                            let tapRec = UITapGestureRecognizer()
                                                            
                                                            
                                                            tapRec.addTarget(self, action: "setURL:")
                                                            gigView.tag = events[i]["id"].int!
                                                            gigView.addGestureRecognizer(tapRec)
                                                            
                                                            self.allGigsView.addSubview(gigView)
                                                            
                                                            
                                                            y += 80
                                                            
                                                        }
                                                    }
                                                    
                                                } else {
                                                    
                                                    let noGigsView = UILabel(frame: CGRect(x: 0, y: 75, width: self.width, height: 100))
                                                    
                                                    noGigsView.center.x = self.width/2
                                                    
                                                    noGigsView.text = "No Gigs Announced"
                                                    
                                                    setSKLabelText(noGigsView)
                                                    
                                                    noGigsView.textAlignment = .Center
                                                    
                                                    self.allGigsView.addSubview(noGigsView)
                                                    
                                                }
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                }
                                
                            }
                            
                        }
                        
                    } else {
                        let noGigsView = UILabel(frame: CGRect(x: 0, y: 75, width: self.width, height: 100))
                        
                        noGigsView.center.x = self.width/2
                        
                        noGigsView.text = "No Gigs Announced"
                        
                        setSKLabelText(noGigsView)
                        
                        noGigsView.textAlignment = .Center
                        
                        self.allGigsView.addSubview(noGigsView)
                        
                        self.webURL = "http://www.songkick.com"
                        
                        let tapRec = UITapGestureRecognizer()
                        
                        
                        tapRec.addTarget(self, action: "loadWeb")
                        moreGigsView.addGestureRecognizer(tapRec)
                    }
                    
                }
                
                
            }
            
        }
        
        self.artistView.setContentOffset(CGPointMake(0, -self.artistView.contentInset.top), animated: true)
        
        self.allSongsView.subviews.map({ $0.removeFromSuperview() })
        
        self.nextPageToken = ""
        
        self.loadSongs(self.userSearch)
        
    }
    
    func setURL(sender: UITapGestureRecognizer) {
        
        self.webURL = "https://www.songkick.com/concerts/\(String(sender.view!.tag))"
        
        loadWeb()
        
    }
    
    func artistURL(sender: UITapGestureRecognizer) {
        
        self.webURL = "https://www.songkick.com/artists/\(String(sender.view!.tag))"
        loadWeb()
        
    }
    
    func amazon(sender: UITapGestureRecognizer) {
        
        let webViewController:WebViewController = WebViewController(nibName: "WebViewController", bundle: nil)
        
        
        
        webViewController.webURL = self.amazonURLs[sender.view!.tag] as! String
        
        self.presentViewController(webViewController, animated: true, completion: nil)
        
    }
    
    func moreAmazon(){
        
        let webViewController:WebViewController = WebViewController(nibName: "WebViewController", bundle: nil)
        
        
        
        webViewController.webURL = self.moreAmazonURL
        
        self.presentViewController(webViewController, animated: true, completion: nil)
        
    }
    
    func loadWeb(){
        let webViewController:WebViewController = WebViewController(nibName: "WebViewController", bundle: nil)
        
        
        
        webViewController.webURL = self.webURL
        
        self.presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func playSong(sender: UITapGestureRecognizer) {
        
        
        
        
        ytPlayer.ytID = self.ytURLs[sender.view!.tag] as! String
        
        ytPlayer.ytTitle = self.ytTitles[sender.view!.tag] as! String
        
        ytPlayer.playVid(self.ytURLs[sender.view!.tag] as! String)
        
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: "\(ytPlayer.ytID)/\(resnateID)")
        
        request(req.buildURLRequest("songs/", path: "/findSong")).responseJSON { response in
            
            if let re = response.result.value {
                
                let song = JSON(re)
                
                if let songID = song["songID"].string {
                    
                    self.ytPlayer.shareID = songID
                    
                }
                
            }
        }
        
        
        
        
    }
    
    
    
    
    func playerReady(videoPlayer: YouTubePlayerView) {
       
        
        
    }
    func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        
    
        
    }
    func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        print("decel")
        
        if self.nextPageToken != "" {
            
            if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) && scrollView.contentSize.height > 1 && scrollView.tag != -1) {
                
                self.artistView.contentSize.height += 10
                
                let loadingView = UIActivityIndicatorView(frame: CGRect(x: Int(self.artistView.frame.width/2 - 25), y: Int(self.artistView.contentSize.height - 30), width: 50, height: 50))
                
                self.artistView.addSubview(loadingView)
                
                loadingView.startAnimating()
                
                self.artistView.tag = -1
                
                loadSongs(self.userSearch)
                
                self.artistView.tag = 0
                
                let delay = 0.3 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    loadingView.stopAnimating()
                }
                
            }
            
        }
        
    }
    
    


}
