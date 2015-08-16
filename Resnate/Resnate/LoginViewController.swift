//
//  LoginViewController.swift
//  LoginTabbedAppSwift
//
//  Created by Malek Trabelsi on 2/12/15.
//  Copyright (c) 2015 Medigarage Studios LTD. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
            println("error is \(error)")
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            request(.GET, "https://www.resnate.com/api/userSearch/\(FBSDKAccessToken.currentAccessToken().tokenString)")
                .responseJSON { (_, _, JSON, error) in
                    if JSON != nil {
                        let userID = JSON!["id"] as! String
                        let userToken = JSON!["access_token"] as! String
                        let userName = JSON!["name"] as! String
                        let userFirstName = JSON!["first_name"] as! String
                        
                        println(userID)
                        
                        let req = Router(OAuthToken: userToken, userID: userID)
                        request(req.buildURLRequest("users/", path: "")).responseJSON { (_, _, JSON, errorMsg) in
                            if JSON != nil {
                                
                                let resnateUserID = JSON!["id"] as! Int
                                
                                let error = Locksmith.saveData(["userID": "\(resnateUserID)", "token": "\(userToken)", "name": "\(userName)", "first_name": "\(userFirstName)"],forUserAccount: "resnateAccount", inService: "resnate")
                            }
                                
                            else {
                                println(errorMsg)
                            }
                        }
                        
                        
                    } else {
                        println(error)
                    }
            }
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = self.navigationController
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
    
    @IBOutlet weak var loginView: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        loginView.readPermissions = ["public_profile", "user_likes", "user_friends"]
        loginView.delegate = self
        
        
        
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
