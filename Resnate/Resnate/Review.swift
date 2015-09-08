//
//  Review.swift
//  Resnate
//
//  Created by Amir Moosavi on 11/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    
    func profile(sender: UITapGestureRecognizer) {
        
            
            let scrollProfileViewController:ScrollProfileViewController = ScrollProfileViewController(nibName: "ScrollProfileViewController", bundle: nil)
            
            scrollProfileViewController.ID = sender.view!.tag
            
            
            self.navigationController?.pushViewController(scrollProfileViewController, animated: true)
            
            
    
    }
    
    func followers(sender: UITapGestureRecognizer) {
        
        
        let followViewController:FollowViewController = FollowViewController(nibName: "FollowViewController", bundle: nil)
        
        followViewController.ID = sender.view!.tag
        
        followViewController.type = "followers"
        
        self.navigationController?.pushViewController(followViewController, animated: true)
        
        
        
        
    }
    
    func followees(sender: UITapGestureRecognizer) {
        
        
        let followViewController:FollowViewController = FollowViewController(nibName: "FollowViewController", bundle: nil)
        
        followViewController.ID = sender.view!.tag
        
        followViewController.type = "followees"
        
        self.navigationController?.pushViewController(followViewController, animated: true)
        
        
        
        
    }
    
    
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }
    
    
    
    
    
func toModalReview(sender:UITapGestureRecognizer) {
    
    let reviewViewController:ReviewViewController = ReviewViewController(nibName: "ReviewViewController", bundle: nil)
    
    
    
    reviewViewController.ID = sender.view!.tag
    
    
    self.navigationController?.pushViewController(reviewViewController, animated: true)
    
    
    
    
}
    
    
    
    
    func writeGigReview(sender:UITapGestureRecognizer){
        
        
        
        let writeReviewViewController:WriteReviewViewController = WriteReviewViewController(nibName: "WriteReviewViewController", bundle: nil)
        
        writeReviewViewController.ID = sender.view!.tag
        
        writeReviewViewController.type = "PastGig"
        
        
        self.presentViewController(writeReviewViewController, animated: true, completion: nil)
        
    }
    
    func writeSongReview(sender:UITapGestureRecognizer){
        
        
        
        let writeReviewViewController:WriteReviewViewController = WriteReviewViewController(nibName: "WriteReviewViewController", bundle: nil)
        
        writeReviewViewController.ID = sender.view!.tag
        
        writeReviewViewController.type = "Song"
        
        
        self.presentViewController(writeReviewViewController, animated: true, completion: nil)
        
    }
    
    func deleteReview(sender:UITapGestureRecognizer){
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        if UIApplication.sharedApplication().respondsToSelector(Selector("registerUserNotificationSettings:")) {
            
            // Notifications for iOS 8
            var deleteAlert = UIAlertController(title: "Delete Review", message: "Are you sure you want to delete this review?", preferredStyle: UIAlertControllerStyle.Alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction!) in
                
                let URL = NSURL(string: "https://www.resnate.com/api/reviews/\(String(sender.view!.tag))")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                mutableURLRequest.HTTPMethod = Method.DELETE.rawValue
                mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                
                request(mutableURLRequest).responseJSON { (_, _, json, error) in
                    if json != nil {
                      
                        
                        self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                        
                        let window = UIApplication.sharedApplication().keyWindow
                        
                        if window!.rootViewController as? UITabBarController != nil {
                            var tababarController = window!.rootViewController as! UITabBarController
                            tababarController.selectedIndex = 0
                        }
                        
                        
                    }
                }
                
                
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
            
            presentViewController(deleteAlert, animated: true, completion: nil)
        }
        else {
            // Notifications for iOS < 8
            
            let alert = UIAlertView()
            alert.title = "Delete Review"
            alert.delegate = self
            alert.tag = sender.view!.tag
            alert.message = "Are you sure you want to delete this review?"
            alert.addButtonWithTitle("Cancel")
            alert.addButtonWithTitle("Delete")
            alert.show()
            
            
        }
        
    }
    
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        switch buttonIndex{
            
        case 1:
            if View.title == "Delete Review"{
                
                let URL = NSURL(string: "https://www.resnate.com/api/reviews/\(String(View.tag))")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                mutableURLRequest.HTTPMethod = Method.DELETE.rawValue
                mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                
                request(mutableURLRequest).responseJSON { (_, _, json, error) in
                    if json != nil {
                        
                        self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                        
                        let window = UIApplication.sharedApplication().keyWindow
                        
                        if window!.rootViewController as? UITabBarController != nil {
                            var tababarController = window!.rootViewController as! UITabBarController
                            tababarController.selectedIndex = 0
                        }
                        
                        
                    }
                }
                
            };
            break;
        case 0:
            NSLog("Dismiss");
            break;
        default:
            NSLog("Default");
            break;
            //Some code here..
            
        }
    }
    
    
    func editReview(sender:UITapGestureRecognizer){
        
        let writeReviewViewController:WriteReviewViewController = WriteReviewViewController(nibName: "WriteReviewViewController", bundle: nil)
        
        writeReviewViewController.ID = sender.view!.tag
        
        writeReviewViewController.type = "Review"
        
        
        self.presentViewController(writeReviewViewController, animated: true, completion: nil)
    }
    
    
}