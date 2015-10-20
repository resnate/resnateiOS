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
    
    
    func profile(sender: AnyObject) {
        
            
            let scrollProfileViewController:ScrollProfileViewController = ScrollProfileViewController(nibName: "ScrollProfileViewController", bundle: nil)
            
            scrollProfileViewController.ID = sender.view!!.tag
            
            
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
            completion(data: NSData(data: data!))
            }.resume()
    }
    
    
    
    
    
func toReview(sender:AnyObject) {
    
    let reviewViewController:ReviewViewController = ReviewViewController(nibName: "ReviewViewController", bundle: nil)
    
    
    
    reviewViewController.ID = sender.view!!.tag
    
    
    self.navigationController?.pushViewController(reviewViewController, animated: true)
    
    
    
    
}
    
    func toSetlist(sender: AnyObject) {
        
        let setlistViewController:SetlistViewController = SetlistViewController(nibName: "SetlistViewController", bundle: nil)
        
        setlistViewController.ID = sender.view!!.tag
        
        self.navigationController?.pushViewController(setlistViewController, animated: true)
        
    }
    
    
    
    
    func writeGigReview(sender:UITapGestureRecognizer){
        
        
        
        let writeReviewViewController:WriteReviewViewController = WriteReviewViewController(nibName: "WriteReviewViewController", bundle: nil)
        
        writeReviewViewController.ID = sender.view!.tag
        
        writeReviewViewController.type = "PastGig"
        
        
        self.navigationController?.pushViewController(writeReviewViewController, animated: true)
        
    }
    
    func writeSongReview(sender:UITapGestureRecognizer){
        
        
        
        let writeReviewViewController:WriteReviewViewController = WriteReviewViewController(nibName: "WriteReviewViewController", bundle: nil)
        
        writeReviewViewController.ID = sender.view!.tag
        
        writeReviewViewController.type = "Song"
        
        
        self.presentViewController(writeReviewViewController, animated: true, completion: nil)
        
    }
    
    func deleteReview(sender:UITapGestureRecognizer){
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let parameters =  ["token": "\(resnateToken)"]
        
        
        if UIApplication.sharedApplication().respondsToSelector(Selector("registerUserNotificationSettings:")) {
            
            // Notifications for iOS 8
            if #available(iOS 8.0, *) {
                let deleteAlert = UIAlertController(title: "Delete Review", message: "Are you sure you want to delete this review?", preferredStyle: UIAlertControllerStyle.Alert)
                
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction) in
                    
                    let URL = NSURL(string: "https://www.resnate.com/api/reviews/\(String(sender.view!.tag))")!
                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                    mutableURLRequest.HTTPMethod = Method.POST.rawValue
                    mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                    
                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                            self.navigationController?.popViewControllerAnimated(true)
                            
                            let window = UIApplication.sharedApplication().keyWindow
                            
                            if window!.rootViewController as? UITabBarController != nil {
                                let tababarController = window!.rootViewController as! UITabBarController
                                tababarController.selectedIndex = 0
                            }
                    }
                    
                    
                }))
                
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
                
                presentViewController(deleteAlert, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
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
        
    }
    
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        switch buttonIndex{
            
        case 1:
            if View.title == "Delete Review"{
                
                let parameters =  ["token": "\(resnateToken)"]
                
                let URL = NSURL(string: "https://www.resnate.com/api/reviews/\(String(View.tag))")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                mutableURLRequest.HTTPMethod = Method.DELETE.rawValue
                mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                
                request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in

                        self.navigationController?.popViewControllerAnimated(true)
                        
                        let window = UIApplication.sharedApplication().keyWindow
                        
                        if window!.rootViewController as? UITabBarController != nil {
                            let tababarController = window!.rootViewController as! UITabBarController
                            tababarController.selectedIndex = 0
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
        
        
        self.navigationController?.pushViewController(writeReviewViewController, animated: true)
    }
    
    func loadGig(sender: AnyObject){
        let webViewController:WebViewController = WebViewController(nibName: "WebViewController", bundle: nil)
        
        webViewController.webURL = "https://www.songkick.com/concerts/\(sender.view!!.tag)"
        
        self.presentViewController(webViewController, animated: true, completion: nil)
    }
    
    
}