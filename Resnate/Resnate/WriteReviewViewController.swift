//
//  WriteReviewViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 22/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//
import Foundation
import UIKit

class WriteReviewViewController: UIViewController, UITextViewDelegate {
    
    var ID = 0
    
    var type = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        if self.type == "Review"  {
            
            let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
            
            let resnateToken = dictionary!["token"] as! String
            
            let resnateID = dictionary!["userID"] as! String
            
            let reviewID = String(ID)
            
            
            let req = Router(OAuthToken: resnateToken, userID: reviewID)
            
            request(req.buildURLRequest("reviews/", path: "")).responseJSON { (_, _, json, error) in
                if json != nil {
                    
                    let review = JSON(json!)
                    
                    
                    
                    if let content = review["content"].string {
                        self.reviewTextField.text = content
                        self.reviewTextField.becomeFirstResponder()
                        self.reviewTextField.selectedTextRange = self.reviewTextField.textRangeFromPosition(self.reviewTextField.beginningOfDocument, toPosition: self.reviewTextField.beginningOfDocument)
                        NSNotificationCenter.defaultCenter().addObserver(self,
                            selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
                        
                    }
                    
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

    @IBAction func closeModal(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func postReview(sender: AnyObject) {
        
        
            
            let (dictionary, error) = Locksmith.loadDataForUserAccount("resnateAccount", inService: "resnate")
            
            let resnateToken = dictionary!["token"] as! String
            
            let resnateID = dictionary!["userID"] as! String
            
            if type == "Review"  {
                
                
                
                let parameters =  ["content":"\(reviewTextField.text)"]
                
                let URL = NSURL(string: "https://www.resnate.com/api/reviews/\(String(ID))")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                mutableURLRequest.HTTPMethod = Method.PUT.rawValue
                mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                
                request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { (_, _, JSON, error) in
                    if JSON != nil {
                        self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                        
                        let window = UIApplication.sharedApplication().keyWindow
                        
                        if window!.rootViewController as? UITabBarController != nil {
                            var tababarController = window!.rootViewController as! UITabBarController
                            tababarController.selectedIndex = 0
                        }
                        
                    }
                }
                
                
            } else {
                
                if reviewTextField.text != "Write a review of the show to your heart's extent (as long as your heart's extent is less than 5000 characters)!" {
                
                let parameters =  ["review": ["reviewable_id": "\(String(ID))", "content":"\(reviewTextField.text)", "reviewable_type": "\(type)", "user_id": "\(resnateID)"]]
                
                
                
                let URL = NSURL(string: "https://www.resnate.com/api/reviews")!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                mutableURLRequest.HTTPMethod = Method.POST.rawValue
                mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                
                request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { (_, _, JSON, error) in
                    if JSON != nil {
                        self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                        
                        let window = UIApplication.sharedApplication().keyWindow
                        
                        if window!.rootViewController as? UITabBarController != nil {
                            var tababarController = window!.rootViewController as! UITabBarController
                            tababarController.selectedIndex = 0
                        }
                        
                    }
                }
                
            }
            
            
            
            
            
            
            
        }
        
        
        
        
    }
    
    func keyboardShown(notification: NSNotification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue()
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        var newMargin = keyboardFrame.height
        
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
        if count(updatedText) == 0 {
            
            textView.text = "Write a review of the show to your heart's extent (as long as your heart's extent is less than 5000 characters)!"
            textView.textColor = UIColor.lightGrayColor()
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if textView.textColor == UIColor.lightGrayColor() && count(text) > 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        let length = count(textView.text.utf16) + count(text.utf16) - range.length
        
        return length <= 5000
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
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
