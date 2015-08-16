//
//  Share.swift
//  Resnate
//
//  Created by Amir Moosavi on 14/06/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import Foundation
import UIKit
import FBSDKShareKit
import TwitterKit

extension UIViewController {

func share(sender: AnyObject) {
    
    let height = UIScreen.mainScreen().bounds.height
    
    let width = UIScreen.mainScreen().bounds.width
    
    let modalView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    
    modalView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    let shareBox = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 130))
    
    shareBox.backgroundColor = UIColor.whiteColor()
    
    shareBox.center = modalView.center
    
    
    
    let cancel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 20))

    cancel.text = "Cancel"
    
    cancel.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
    
    let tapRec = UITapGestureRecognizer()
    tapRec.addTarget(self, action: "closeShare:")
    cancel.addGestureRecognizer(tapRec)
    cancel.userInteractionEnabled = true
    
    shareBox.addSubview(cancel)
    
    
    
    
    
    let share = UILabel(frame: CGRect(x: 210, y: 10, width: 50, height: 20))
    
    share.text = "Share"
    
    share.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
    
    let tapRec2 = UITapGestureRecognizer()
    tapRec2.addTarget(self, action: "closeShare:")
    share.addGestureRecognizer(tapRec2)
    share.userInteractionEnabled = true
    
    shareBox.addSubview(share)
    
    
    
    
    
    
    var myColor : UIColor = UIColor( red: 0.1, green: 0.1, blue:0.1, alpha: 0.5 )
    
    let shareRecipient = UITextField(frame: CGRect(x: 10, y: 35, width: 230, height: 20))
    
    shareRecipient.layer.borderWidth = 0.5
    shareRecipient.layer.borderColor = myColor.CGColor
    shareRecipient.font = UIFont(name: "HelveticaNeue-Light", size: 10)

    shareBox.addSubview(shareRecipient)
    
    let shareInput = UITextView(frame: CGRect(x: 10, y: 70, width: 230, height: 50))
    
    
    shareInput.layer.borderWidth = 0.5
    shareInput.layer.borderColor = myColor.CGColor
    shareInput.font = UIFont(name: "HelveticaNeue-Light", size: 10)
    shareInput.becomeFirstResponder()
    
    shareBox.addSubview(shareInput)
    
    modalView.addSubview(shareBox)
    

    
}

func closeShare(sender: AnyObject) {
 sender.view!.superview!.superview!.removeFromSuperview()
}
    
    
    
    
    func fbReview(sender: AnyObject){
        let content = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "www.resnate.com/reviews/\(sender.view!.tag)/pl")
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
    }
    
    


    func twitter(sender: AnyObject){
        let composer = TWTRComposer()
        let url = "I've written a review on @resnate! https://www.resnate.com/reviews/\(sender.view!.tag)/pl"
        composer.setText(url)
        composer.setImage(UIImage(named: "fabric"))
        
        composer.showWithCompletion { (result) -> Void in
            if (result == TWTRComposerResult.Cancelled) {
                println("Tweet composition cancelled")
            }
            else {
                println("Sending tweet!")
            }
        }
    }


}
