//
//  AppDelegate.swift
//
//  Created by Malek Trabelsi on 2/12/15.
//  Copyright (c) 2015 Medigarage Studios LTD. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Fabric
import TwitterKit
import MediaPlayer


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController?
    
    let ytPlayer = VideoPlayer.sharedInstance
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Twitter.sharedInstance().startWithConsumerKey("2iTWz49EBpJWuoWLamoAvMYcn", consumerSecret: "AkR58M5tCjNQviCsynjCiCr3TdqCmtJ9Whmn6nSJNfr8hFKbE5")
        Fabric.with([Twitter.sharedInstance()])

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.window = UIWindow(frame:UIScreen.mainScreen().bounds)
        
        // Home controller
        let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
        homeVC.tabBarItem.title = "Home";
        
        homeVC.tabBarItem.image = UIImage(named: "home.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        
        homeVC.tabBarItem.selectedImage = UIImage(named: "homeSelected.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        
        
        // Notifications controller
        let notificationsVC = NotificationsViewController(nibName: "NotificationsViewController", bundle: nil)
        notificationsVC.tabBarItem.title = "Notifications"
        notificationsVC.tabBarItem.image = UIImage(named: "notification")!.imageWithRenderingMode(.AlwaysOriginal)
        notificationsVC.tabBarItem.selectedImage = UIImage(named: "notificationSelected")!.imageWithRenderingMode(.AlwaysOriginal)
        
        
        
        
        
        let inboxVC = InboxViewController(nibName: "InboxViewController", bundle: nil)
        inboxVC.tabBarItem.title = "Inbox"
        inboxVC.tabBarItem.image = UIImage(named: "envelope.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        inboxVC.tabBarItem.selectedImage = UIImage(named: "envelopeSelected.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        
        
        
        let profileVC = ScrollProfileViewController(nibName: "ScrollProfileViewController", bundle: nil)
        profileVC.tabBarItem.title = "Profile"
        
        profileVC.tabBarItem.selectedImage = UIImage(named: "userSelectedSmall.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        
        profileVC.tabBarItem.image = UIImage(named: "userSmall.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        
        
        let artistsVC = ArtistsViewController(nibName: "ArtistsViewController", bundle: nil)
        artistsVC.tabBarItem.title = "Artists"
        artistsVC.tabBarItem.selectedImage = UIImage(named: "artistsSelected.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        
        artistsVC.tabBarItem.image = UIImage(named: "artists.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        
        
        let homeNavControl = UINavigationController(rootViewController: homeVC)
        
        homeNavControl.navigationBar.barTintColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        
        let profileNavControl = UINavigationController(rootViewController: profileVC)
        
        profileNavControl.navigationBar.barTintColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        
        let inboxNavControl = UINavigationController(rootViewController: inboxVC)

        inboxNavControl.navigationBar.barTintColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        
        let artistsNavControl = UINavigationController(rootViewController: artistsVC)
        
        artistsNavControl.navigationBar.barTintColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        
        let notificationsNavControl = UINavigationController(rootViewController: notificationsVC)
        
        notificationsNavControl.navigationBar.barTintColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        
        
        self.window!.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        self.tabBarController = UITabBarController()
        self.tabBarController!.setViewControllers([homeNavControl, profileNavControl, inboxNavControl, notificationsNavControl, artistsNavControl], animated: false);
        
        self.tabBarController!.tabBar.barTintColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        
         let font: UIFont = UIFont(name: "Helvetica Neue", size: 9.5)!
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)], forState:.Selected)
        
        
        self.tabBarController?.view.addSubview(ytPlayer.videoPlayer)
        self.tabBarController?.view.addSubview(ytPlayer.playerOverlay)
        self.tabBarController?.view.addSubview(ytPlayer.videoReviewView)
        ytPlayer.videoReviewView.addSubview(ytPlayer.reviewTextView)
        ytPlayer.videoReviewView.addSubview(ytPlayer.postReview)

        UIBarButtonItem.appearance().setTitlePositionAdjustment(UIOffsetMake(0, -2.5), forBarMetrics: .Default)
        
        UINavigationBar.appearance().titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17)!,  NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)

        
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.window!.rootViewController = loginVC
        self.window!.makeKeyAndVisible()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playing", name: nil, object: nil)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let params = ["fields": "name, email, friends, likes", "limit": "1000"]
        
        var musicLikes: [String] = []
        var musicLikesString = ""
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            
            request(.GET, "https://www.resnate.com/api/userSearch/\(FBSDKAccessToken.currentAccessToken().tokenString)")
                .responseJSON { response in
                    if let re = response.result.value {
                        let json = JSON(re)
                        if let userID = json["id"].string {
                            
                            
                            FBSDKGraphRequest.init(graphPath: "/\(userID)/music", parameters: params).startWithCompletionHandler({ (connection, result, error) -> Void in
                                
                                let musicJson = JSON(result)

                                if let jsonData = musicJson["data"].array {
                                    for entry in jsonData {
                                        
                                        if let name = entry["name"].string {
                                            
                                            musicLikes.append(name)
                                        }
                                    }
                                    
                                }
                                
                                musicLikesString = musicLikes.joinWithSeparator(",#!")
                                let userToken = json["access_token"].string!
                                let userName = json["name"].string!
                                let userFirstName = json["first_name"].string!
                                
                                
                                let req = Router(OAuthToken: userToken, userID: userID)
                                request(req.buildURLRequest("users/", path: "/login")).responseJSON { response in
                                    
                                    
                                    
                                    if let re = response.result.value {
                                        
                                        let json = JSON(re)
                                        
                                        
                                        if let resnateUserID = json["id"].int {
                                            
                                            let parameters =  ["musicLikes": "\(musicLikesString)", "oauth_token": "\(FBSDKAccessToken.currentAccessToken().tokenString)", "token": "\(userToken)" ]
                                            
                                            let URL = NSURL(string: "https://www.resnate.com/api/users/update")!
                                            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                                            mutableURLRequest.HTTPMethod = Method.PUT.rawValue
                                            mutableURLRequest.setValue("Token \(userToken)", forHTTPHeaderField: "Authorization")
                                            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in

                                                
                                            }
                                            
                                            let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                                            
                                            if dictionary != nil {
                                                
                                                do {
                                                    try Locksmith.updateData(["userID": "\(resnateUserID)", "token": "\(userToken)", "name": "\(userName)", "first_name": "\(userFirstName)"], forUserAccount: "resnateAccount")
                                                } catch let error as NSError {
                                                    print("json error: \(error.localizedDescription)")
                                                }
                                                
                                                
                                                appDelegate.window?.rootViewController = appDelegate.tabBarController
                                            } else {
                                                
                                                do {
                                                    try Locksmith.saveData(["userID": "\(resnateUserID)", "token": "\(userToken)", "name": "\(userName)", "first_name": "\(userFirstName)"], forUserAccount: "resnateAccount")
                                                    let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                                                    
                                                    if dictionary != nil {
                                                        
                                                        appDelegate.window?.rootViewController = appDelegate.tabBarController
                                                        
                                                    }
                                                } catch let error as NSError {
                                                    print("json error: \(error.localizedDescription)")
                                                }
                                                
                                                
                                            }
                                            
                                        }  else {
                                            
                                            
                                            FBSDKGraphRequest.init(graphPath: "me", parameters: params).startWithCompletionHandler({ (connection, result, error) -> Void in
                                                print("3asdasdasd")
                                                if let re = result {
                                                    let json = JSON(re)
                                                    let name = json["name"].string!
                                                    var first_name = ""
                                                    if let jsonFirst = json["first_name"].string {
                                                        first_name = jsonFirst
                                                    }
                                                    var email = ""
                                                    
                                                    if let jsonEmail = json["email"].string {
                                                        email = jsonEmail
                                                    }
                                                    
                                                    let fbID = json["id"].string!
                                                    
                                                    
                                                    let parameters =  ["email":"\(email)", "uid": "\(fbID)", "name": "\(name)", "first_name": "\(first_name)", "musicLikes": "\(musicLikes)", "oauth_token": "\(FBSDKAccessToken.currentAccessToken().tokenString)" ]
                                                    
                                                    let URL = NSURL(string: "https://www.resnate.com/api/users/create")!
                                                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                                                    mutableURLRequest.HTTPMethod = Method.POST.rawValue
                                                    
                                                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                                                        
                                                        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                                                        
                                                        if dictionary != nil {
                                                            
                                                            do {
                                                                try Locksmith.updateData(["userID": "\(fbID)", "token": "\(FBSDKAccessToken.currentAccessToken().tokenString)", "name": "\(name)", "first_name": "\(first_name)"], forUserAccount: "resnateAccount")
                                                            } catch let error as NSError {
                                                                print("json error: \(error.localizedDescription)")
                                                            }
                                                            
                                                        } else {
                                                            
                                                            do {
                                                                try Locksmith.saveData(["userID": "\(fbID)", "token": "\(FBSDKAccessToken.currentAccessToken().tokenString)", "name": "\(name)", "first_name": "\(first_name)"], forUserAccount: "resnateAccount")
                                                            } catch let error as NSError {
                                                                print("json error: \(error.localizedDescription)")
                                                            }
                                                            
                                                            
                                                        }
                                                        appDelegate.window?.rootViewController = appDelegate.tabBarController
                                                        
                                                    }
                                                    
                                                }
                                                
                                                
                                            })
                                        }
                                        
                                    }
                                    
                                }
                            })
                            
                        }
                        
                    }
            }
            
            
                          
        } else {

     
            FBSDKGraphRequest.init(graphPath: "me", parameters: params).startWithCompletionHandler({ (connection, result, error) -> Void in
                print("2asdasdasd")
                if let re = result {
       
                    let json = JSON(re)
                    
                    let name = json["name"].string!
                    var first_name = ""
                    if let jsonFirst = json["first_name"].string {
                        first_name = jsonFirst
                    }
                    var email = ""
                    
                    if let jsonEmail = json["email"].string {
                        email = jsonEmail
                    }
                    
                    let fbID = json["id"].string!
                    

                    
                    FBSDKGraphRequest.init(graphPath: "/\(fbID)/music", parameters: params).startWithCompletionHandler({ (connection, result, error) -> Void in
                        
                        let json = JSON(result)
                        if let jsonData = json["data"].array {
                            for entry in jsonData {
                                if let name = entry["name"].string {
                                    musicLikes.append(name)
                                }
                            }
                            
                        }
                        
                    })
                    
                    
                    musicLikesString = musicLikes.joinWithSeparator(",#!")
                    let parameters =  ["email":"\(email)", "uid": "\(fbID)", "name": "\(name)", "first_name": "\(first_name)", "musicLikes": "\(musicLikesString)", "oauth_token": "\(FBSDKAccessToken.currentAccessToken().tokenString)" ]
                    
                    let URL = NSURL(string: "https://www.resnate.com/api/users/create")!
                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                    mutableURLRequest.HTTPMethod = Method.POST.rawValue
                    
                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                        
                        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                        
                        if dictionary != nil {
                            
                            do {
                                try Locksmith.updateData(["userID": "\(fbID)", "token": "\(FBSDKAccessToken.currentAccessToken().tokenString)", "name": "\(name)", "first_name": "\(first_name)"], forUserAccount: "resnateAccount")
                            } catch let error as NSError {
                                print("json error: \(error.localizedDescription)")
                            }
                            
                        } else {
                            
                            do {
                                try Locksmith.saveData(["userID": "\(fbID)", "token": "\(FBSDKAccessToken.currentAccessToken().tokenString)", "name": "\(name)", "first_name": "\(first_name)"], forUserAccount: "resnateAccount")
                            } catch let error as NSError {
                                print("json error: \(error.localizedDescription)")
                            }
                            
                            
                        }
                        appDelegate.window?.rootViewController = appDelegate.tabBarController
                        
                    }

                } else {
                    
                    let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                    
                    if dictionary != nil {
                        
                        do {
                            try Locksmith.updateData(["token": "error"], forUserAccount: "resnateAccount")
                        } catch let error as NSError {
                            print("json error: \(error.localizedDescription)")
                        }
                        
                    }
                    
                }
                
                
            })
        }
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func playing(){
        
        
                    if ytPlayer.videoPlayer.playerState == .Playing {
                        
                        ytPlayer.videoPlayer.getVideoBytesLoaded({ (bytesLoaded) -> () in
                            
                            if let floatLoaded = Float(bytesLoaded) {
                                
                                self.ytPlayer.videoSlider.currentBuffer = floatLoaded
                                
                            }
                            
                            
                        })
                        
                        ytPlayer.videoPlayer.getCurrentTime({ (youTubeTime) -> () in
                            
                         
                            
                            if self.ytPlayer.playerOverlay.backgroundColor == UIColor(white: 0, alpha: 0.5) {
                                
                                self.ytPlayer.playerOverlay.addSubview(self.ytPlayer.currentTime)
                                self.ytPlayer.currentTime.text = youTubeTime.youTubeTime
                                
                                let currentTime = youTubeTime.doubleTime
                                
                                
                                self.ytPlayer.videoPlayer.getDuration({ (youTubeTime) -> () in
                                    
                                    let duration = youTubeTime.doubleTime
                                    
                                    self.ytPlayer.videoSlider.currentPosition = Float(currentTime/duration)
                                   
                                })
                                
                            }
                            

                        })
                       
                    } else if ytPlayer.videoPlayer.playerState == .Paused {
                        
                        ytPlayer.fadeInOverlay()
                        print("paused")
                        
                    } else if ytPlayer.videoPlayer.playerState == .Ended {
                        
                        ytPlayer.videoPlayer.seekTo(0, seekAhead: true)
                        ytPlayer.videoPlayer.pause()
                        print("ended")
                    }
                
    }
    

    
    func rotated()
    {
        
        let width = UIScreen.mainScreen().bounds.width
        let height = UIScreen.mainScreen().bounds.height
        
        
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            

                    self.ytPlayer.hideReviewView()
                    if self.ytPlayer.videoPlayer.tag == 1 {
                        self.ytPlayer.reviewTextView.endEditing(true)
                        UIView.animateWithDuration(0.2,
                            delay: 0,
                            options: [.CurveEaseInOut, .AllowUserInteraction],
                            animations: {
                                
                                if UIDevice.currentDevice().orientation == .LandscapeLeft {
                                    self.ytPlayer.videoPlayer.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2 ))
                                    self.ytPlayer.playerOverlay.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2 ))
                                } else {
                                    self.ytPlayer.videoPlayer.transform = CGAffineTransformMakeRotation(CGFloat(3 * M_PI_2 ))
                                    self.ytPlayer.playerOverlay.transform = CGAffineTransformMakeRotation(CGFloat(3 * M_PI_2 ))
                                }
                                
                                self.ytPlayer.videoPlayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
                                self.ytPlayer.playerOverlay.frame = CGRect(x: 0, y: 0, width: width, height: height)
                                
                                    
                                if self.ytPlayer.videoPlayer.playerState == .Playing {
                                    
                                    self.ytPlayer.videoPlayer.play()
                                }
                                
                                
                                
                            },
                            completion: { finished in
                                self.ytPlayer.videoPlayer.layer.borderWidth = 0
                                
                                self.ytPlayer.videoSlider.frame = CGRect(x: 10, y: UIScreen.mainScreen().bounds.width - 65, width: UIScreen.mainScreen().bounds.height - 20, height: 30)

                                self.ytPlayer.currentTime.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.width - 35, width: 70, height: 30)
                                
                                self.ytPlayer.duration.frame = CGRect(x: UIScreen.mainScreen().bounds.height - 45, y: UIScreen.mainScreen().bounds.width - 35, width: 70, height: 30)
                                
                                    for subview in self.ytPlayer.playerOverlay.subviews {

                                        if subview.tag == -1 || subview.tag == -2 {
                                            
                                            subview.frame.origin.x = UIScreen.mainScreen().bounds.height/2 - 25
                                            subview.frame.origin.y = UIScreen.mainScreen().bounds.width/2 - 25
                                            
                                        }
                                        
                                        
                                    }
                                UIApplication.sharedApplication().statusBarHidden = true
                        })
                        
                    }
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
                        
                        if self.ytPlayer.videoPlayer.tag == 1 {
                            
                            UIView.animateWithDuration(0.2,
                                delay: 0,
                                options: [.CurveEaseInOut, .AllowUserInteraction],
                                animations: {
                                    
                                    
                                    self.ytPlayer.videoPlayer.transform = CGAffineTransformMakeRotation(CGFloat(0))
                                    self.ytPlayer.playerOverlay.transform = CGAffineTransformMakeRotation(CGFloat(0))
                                    
                                    self.ytPlayer.videoPlayer.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 170, y: UIScreen.mainScreen().bounds.height - 150, width: 160, height: 90)
                                    self.ytPlayer.playerOverlay.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 170, y: UIScreen.mainScreen().bounds.height - 150, width: 160, height: 90)
                                    
                                    self.ytPlayer.videoReviewView.frame = CGRect(x: UIScreen.mainScreen().bounds.width, y: UIScreen.mainScreen().bounds.height, width: 160, height: 90)
                                    
                                        if self.ytPlayer.videoPlayer.playerState == .Playing {
                                            
                                            self.ytPlayer.videoPlayer.play()
                                        }
                                },
                                completion: { finished in
                                    UIApplication.sharedApplication().statusBarHidden = false

                                    self.ytPlayer.videoPlayer.layer.borderWidth = 1
                                    
                                    self.ytPlayer.videoPlayer.layer.borderColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0).CGColor
                                    
                                    if self.ytPlayer.videoPlayer.frame.width > 160 {
                                        
                                        self.ytPlayer.currentTime.frame = CGRect(x: 5, y: UIScreen.mainScreen().bounds.width/1.85 - 35, width: 70, height: 30)
                                        
                                        self.ytPlayer.duration.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 45, y: UIScreen.mainScreen().bounds.width/1.85 - 35, width: 70, height: 30)
                                        
                                        self.ytPlayer.videoSlider.frame = CGRect(x: 10, y: UIScreen.mainScreen().bounds.width/1.85 - 55, width: UIScreen.mainScreen().bounds.width - 20, height: 30)
                                        
                                        
                                    } else {
                                        
                                        self.ytPlayer.currentTime.frame = CGRect(x: -UIScreen.mainScreen().bounds.height, y: -UIScreen.mainScreen().bounds.width, width: 70, height: 30)
                                        
                                        self.ytPlayer.duration.frame = CGRect(x: -UIScreen.mainScreen().bounds.height, y: -UIScreen.mainScreen().bounds.width, width: 70, height: 30)
                                        
                                        self.ytPlayer.videoSlider.frame = CGRect(x: -UIScreen.mainScreen().bounds.height, y: -UIScreen.mainScreen().bounds.width, width: UIScreen.mainScreen().bounds.width - 20, height: 30)
                                        
                                    }
                                    
                                    
                                    
                                    for subview in self.ytPlayer.playerOverlay.subviews {
                                        
                                        if subview.tag == -1 || subview.tag == -2 {
                                            
                                            subview.frame = CGRect(x: 55, y: 21, width: 50, height: 50)
                                            
                                        }

                                    }

                                    
                            })
                        
                    }
        }
        
    }
    
    
    func playerReady(videoPlayer: YouTubePlayerView) {
        
        
        
    }
    func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        
        
        
    }
    func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }


}

