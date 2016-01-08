//
//  WritePlaylistDescriptionViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 04/12/2015.
//  Copyright © 2015 Resnate. All rights reserved.
//

import UIKit
import ReachabilitySwift

class WritePlaylistDescriptionViewController: UIViewController, UITextViewDelegate {
    
    var ID = 0
    
    var playlistDescription = ""
    
    let noConnection = UILabel(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.width - 100, width: UIScreen.mainScreen().bounds.width, height: 30))
    
    var reachability: Reachability?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        noConnection.text = "No Internet Connection"
        noConnection.textAlignment = .Center
        noConnection.textColor = UIColor.whiteColor()
        noConnection.backgroundColor = UIColor.redColor()
        
        let updateButton = UIBarButtonItem(title: "Update", style: .Plain, target: self, action: "updateDescription")
        
        self.navigationItem.rightBarButtonItem = updateButton
        
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
        
        playlistTextField.becomeFirstResponder()
        
        
        
        playlistTextField.delegate = self
        
        if self.playlistDescription == ""  {
            
            playlistTextField.text = "Write a short description of this playlist."
            playlistTextField.selectedTextRange = playlistTextField.textRangeFromPosition(playlistTextField.beginningOfDocument, toPosition: playlistTextField.beginningOfDocument)
            playlistTextField.textColor = UIColor.lightGrayColor()
            
            
            
        } else {
            
            playlistTextField.text = self.playlistDescription
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBOutlet weak var playlistTextField: UITextView!
    
    func updateDescription() {
        
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        if self.navigationItem.rightBarButtonItem?.tag != -53 {
                
                if playlistTextField.text != "Write a short description of this playlist." {
                    
                    let parameters =  ["token": "\(resnateToken)", "description":"\(playlistTextField.text)" ]
                    
                    
                    
                    let URL = NSURL(string: "https://www.resnate.com/api/playlists/\(self.ID)")!
                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                    mutableURLRequest.HTTPMethod = Method.PUT.rawValue
                    mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                    
                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters ).0).responseJSON { response in
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                        let window = UIApplication.sharedApplication().keyWindow
                        
                        if window!.rootViewController as? UITabBarController != nil {
                            let tababarController = window!.rootViewController as! UITabBarController
                            tababarController.selectedIndex = 1
                        }
                        
                        print(JSON(response.result.value!))
                        
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
        
        let verticalConstraint = NSLayoutConstraint(item: self.playlistTextField, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -1 * newMargin)
        
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
            
            textView.text = "Write a short description of this playlist."
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
