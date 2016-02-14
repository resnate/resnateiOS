//
//  WriteReviewViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 22/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//
import Foundation
import UIKit
import ReachabilitySwift

class WriteReviewViewController: UIViewController, UITextViewDelegate {
    
    var ID = 0
    
    var type = ""
    
    let noConnection = UILabel(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.width - 100, width: UIScreen.mainScreen().bounds.width, height: 30))
    
    var reachability: Reachability?


    override func viewDidLoad() {
        
        super.viewDidLoad()
        print(self.ID)
        noConnection.text = "No Internet Connection"
        noConnection.textAlignment = .Center
        noConnection.textColor = UIColor.whiteColor()
        noConnection.backgroundColor = UIColor.redColor()
        
        let postButton = UIBarButtonItem(title: "Post", style: .Plain, target: self, action: "postReview")
        
        self.navigationItem.rightBarButtonItem = postButton
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            self.reachability = reachability
        } catch {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        
        
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
        
        // Initial reachability check
        if let reachability = reachability {
            if reachability.isReachable() {
                
            } else {
                noConnection.tag = -72
                self.view.addSubview(noConnection)
                self.navigationItem.rightBarButtonItem?.tag = -53
            }
        }

        
        
       
        
        if self.type == "Review"  {
            
            let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
            
            let resnateToken = dictionary!["token"] as! String
            
            let reviewID = String(ID)
            
            
            let req = Router(OAuthToken: resnateToken, userID: reviewID)
            
            request(req.buildURLRequest("reviews/", path: "")).responseJSON { response in
                let review = JSON(response.result.value!)
                    
                    
                    
                    if let content = review["content"].string {
                        self.reviewTextField.text = content
                        self.reviewTextField.becomeFirstResponder()
                        self.reviewTextField.selectedTextRange = self.reviewTextField.textRangeFromPosition(self.reviewTextField.beginningOfDocument, toPosition: self.reviewTextField.beginningOfDocument)
                        NSNotificationCenter.defaultCenter().addObserver(self,
                            selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
                        
                    }
                    
                
            }
            
        }
        
        else {
            
            reviewTextField.text = "Write a review of the show to your heart's extent (as long as your heart's extent is less than 5000 characters)!"
            reviewTextField.textColor = UIColor.lightGrayColor()
            
            reviewTextField.becomeFirstResponder()
            
            reviewTextField.selectedTextRange = reviewTextField.textRangeFromPosition(reviewTextField.beginningOfDocument, toPosition: reviewTextField.beginningOfDocument)
            
            reviewTextField.delegate = self
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBOutlet weak var reviewTextField: UITextView!
    
    func postReview() {
        
            
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
            
        let resnateToken = dictionary!["token"] as! String
        
        if self.navigationItem.rightBarButtonItem?.tag != -53 {
            
            if type == "Review"  {
                
                
                
                let parameters =  ["token": "\(resnateToken)", "content":"\(reviewTextField.text)"]
                
                let URL = NSURL(string: "https://www.resnate.com/api/reviews/\(String(ID))")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                mutableURLRequest.HTTPMethod = Method.PUT.rawValue
                mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                
                request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                    
                    self.navigationController?.popViewControllerAnimated(true)
                    
                    let window = UIApplication.sharedApplication().keyWindow
                    
                    if window!.rootViewController as? UITabBarController != nil {
                        let tababarController = window!.rootViewController as! UITabBarController
                        tababarController.selectedIndex = 0
                    }
                    
                }
                
                
            } else {
                
                if reviewTextField.text != "Write a review of the show to your heart's extent (as long as your heart's extent is less than 5000 characters)!" {
                    
                    let parameters =  ["token": "\(resnateToken)", "review": ["reviewable_id": "\(String(ID))", "content":"\(reviewTextField.text)", "reviewable_type": "\(type)" ]]
                    
                    
                    
                    let URL = NSURL(string: "https://www.resnate.com/api/reviews")!
                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                    mutableURLRequest.HTTPMethod = Method.POST.rawValue
                    mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                    
                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters as? [String : AnyObject]).0).responseJSON { response in
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                        let window = UIApplication.sharedApplication().keyWindow
                        
                        if window!.rootViewController as? UITabBarController != nil {
                            let tababarController = window!.rootViewController as! UITabBarController
                            tababarController.selectedIndex = 0
                        }
                        
                    }
                    
                }
                
                
                
                
                
                
                
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
            
            self.navigationItem.rightBarButtonItem?.tag = 0
            
            for view in self.view.subviews {
                if view.tag == -72 {
                    view.removeFromSuperview()
                }
            }
        } else {
            print("NO ")
            noConnection.tag = -72
            self.view.addSubview(noConnection)
            self.navigationItem.rightBarButtonItem?.tag = -53
        }
    }
    
    func keyboardShown(notification: NSNotification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        let newMargin = keyboardFrame.height
        
        let verticalConstraint = NSLayoutConstraint(item: self.reviewTextField, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -1 * newMargin)
        
        self.view.addConstraint(verticalConstraint)
       
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.characters.count == 0 {
            
            textView.text = "Write a review of the show to your heart's extent (as long as your heart's extent is less than 5000 characters)!"
            textView.textColor = UIColor.lightGrayColor()
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if textView.textColor == UIColor.lightGrayColor() && text.characters.count > 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        
        
        let length = textView.text.utf16.count + text.utf16.count - range.length
        
        return length <= 5000
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
    }
    
    

}
