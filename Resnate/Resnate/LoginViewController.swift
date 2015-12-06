//
//  LoginViewController.swift
//  LoginTabbedAppSwift
//
//  Created by Malek Trabelsi on 2/12/15.
//  Copyright (c) 2015 Medigarage Studios LTD. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import ReachabilitySwift

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var reachability: Reachability?
    
    let noConnection = UILabel(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.height/2 - 15, width: UIScreen.mainScreen().bounds.width, height: 30))
    
    let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
            print("error is \(error)")
        }
        else if result.isCancelled {
            // Handle cancellations
        } else {
            loginView.hidden = true
        }

    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
                print("User Logged Out")
    }
    
    
    @IBOutlet weak var loginView: FBSDKLoginButton!
    
    override func viewWillAppear(animated: Bool) {
        

        
            
            if dictionary != nil {
                loginView.hidden = true
            }
            
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
            loginView.readPermissions = ["public_profile", "user_likes", "user_friends"]
            loginView.delegate = self
        
        
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            self.reachability = reachability
        } catch {
            print("Unable to create\nReachability with address")
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start\nnotifier")
            return
        }
        
        // Initial reachability check
        if let reachability = reachability {
            if reachability.isReachable() {
                print("initialReach")
            } else {
                print("noInitialReach")
                loginView.hidden = true
                
                noConnection.text = "No Internet Connection"
                noConnection.textAlignment = .Center
                noConnection.textColor = UIColor.whiteColor()
                self.view.addSubview(noConnection)
            }
        }
        
        
        
    }
    
    deinit {
        
        reachability?.stopNotifier()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            noConnection.hidden = true
            
            if dictionary != nil {
                appDelegate.window?.rootViewController = appDelegate.tabBarController
            } else {
                loginView.hidden = false
                loginView.awakeFromNib()
            }
            
        } else {
            print("unreachable2")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
