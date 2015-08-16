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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var tabBarController: UITabBarController?
    
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
        let peopleVC = PeopleViewController(nibName: "PeopleViewController", bundle: nil)
        peopleVC.tabBarItem.title = "People"
        peopleVC.tabBarItem.image = UIImage(named: "people.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        peopleVC.tabBarItem.selectedImage = UIImage(named: "peopleSelected.pdf")!.imageWithRenderingMode(.AlwaysOriginal)
        
        
        
        
        
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
        
        
        
        let navControl = UINavigationController(rootViewController: profileVC)
        
        navControl.navigationBar.barTintColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        
        
        self.window!.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        self.tabBarController = UITabBarController()
        self.tabBarController!.setViewControllers([homeVC, navControl, inboxVC, artistsVC, peopleVC], animated: false);
        
        self.tabBarController!.tabBar.barTintColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        
        
        let font: UIFont = UIFont(name: "Helvetica Neue", size: 9.5)!
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:0.9, green:0.0, blue:0.29, alpha:1.0)], forState:.Selected)
        
        
        
        
        
        
        
        UITabBarItem.appearance().setTitlePositionAdjustment(UIOffsetMake(0, -2.5))
        
        UINavigationBar.appearance().titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17)!,  NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        
        
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.window!.rootViewController = loginVC
        self.window!.makeKeyAndVisible()
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject?) -> Bool {
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
            // User is already logged in, do work such as go to next view controller.
            
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = appDelegate.tabBarController
        }
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

