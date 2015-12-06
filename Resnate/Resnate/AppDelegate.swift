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
        
        
        // Settings controller
        let settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        settingsVC.tabBarItem.title = "Settings"
        settingsVC.tabBarItem.image = UIImage(named: "settings")!.imageWithRenderingMode(.AlwaysOriginal)
        settingsVC.tabBarItem.selectedImage = UIImage(named: "settingsSelected.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        
        
        
        
        
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
        
        
        let settingsNavControl = UINavigationController(rootViewController: settingsVC)
        
        settingsNavControl.navigationBar.barTintColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        
        
        self.window!.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        self.tabBarController = UITabBarController()
        self.tabBarController!.setViewControllers([homeNavControl, profileNavControl, inboxNavControl, artistsNavControl, settingsNavControl], animated: false);
        
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
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {

                
            request(.GET, "https://www.resnate.com/api/userSearch/\(FBSDKAccessToken.currentAccessToken().tokenString)")
                .responseJSON { response in
                    if let re = response.result.value {
                        let json = JSON(re)
                        let userID = json["id"].string!
                        let userToken = json["access_token"].string!
                        let userName = json["name"].string!
                        let userFirstName = json["first_name"].string!
                        
                        
                        let req = Router(OAuthToken: userToken, userID: userID)
                        request(req.buildURLRequest("users/", path: "/login")).responseJSON { response in
                            
                            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            
                            if let re = response.result.value {
                                
                                let json = JSON(re)
                                
                                
                                let resnateUserID = json["id"].int!
                                
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
                            }
                            
                        }   
                    }
            }
            
            
                          
        } else {
            let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
                        print(dictionary)
        }
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func playing(){
        
                    
                    if ytPlayer.videoPlayer.playerState == .Playing {
                        ytPlayer.videoPlayer.getCurrentTime({ (youTubeTime) -> () in
                            print(youTubeTime)
                        })
                       
                    } else if ytPlayer.videoPlayer.playerState == .Ended {
                        
                    }
                
    }
    

    
    func rotated()
    {
        
        let width = UIScreen.mainScreen().bounds.width
        let height = UIScreen.mainScreen().bounds.height
        
        
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
                    self.ytPlayer.reviewTextView.endEditing(true)
                    if self.ytPlayer.videoPlayer.tag == 1 {
                        self.ytPlayer.hideReviewView()
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
                                UIApplication.sharedApplication().statusBarHidden = true
                                
                                    for subview in self.ytPlayer.playerOverlay.subviews {
                                        
                                        if subview.tag == -1 {
                                            
                                            subview.frame.origin.x = UIScreen.mainScreen().bounds.height/2 - 25
                                            subview.frame.origin.y = UIScreen.mainScreen().bounds.width/2 - 25
                                            
                                        }
                                        
                                    }
                                
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
                                    
                                    for subview in self.ytPlayer.playerOverlay.subviews {
                                        
                                        if subview.tag == -1 {
                                            
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

