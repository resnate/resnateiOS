//
//  WebViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 06/07/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var webURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let url = NSURL (string: webURL);
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
        
        self.webView.delegate = self
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateButtons() {
        
        let backTap = UITapGestureRecognizer()
        backTap.addTarget(self, action: "back")
        
        let forwardTap = UITapGestureRecognizer()
        forwardTap.addTarget(self, action: "forward")
        
        if webView.canGoForward {
            self.forwardArrow.alpha = 1
            
            forwardArrow.addGestureRecognizer(forwardTap)
            forwardArrow.userInteractionEnabled = true
        }
            
        if webView.canGoBack {
            self.backArrow.alpha = 1
            
            backArrow.addGestureRecognizer(backTap)
            backArrow.userInteractionEnabled = true
        }
        
        if webView.canGoBack == false {
            self.backArrow.alpha = 0.5
            backArrow.removeGestureRecognizer(backTap)
        }
        
        if webView.canGoForward == false {
            self.forwardArrow.alpha = 0.5
            forwardArrow.removeGestureRecognizer(forwardTap)
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.updateButtons()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.updateButtons()
    }
    

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var backArrow: UIImageView!
    
    @IBOutlet weak var forwardArrow: UIImageView!
    
    
    
    
    @IBAction func closeModal(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func back() {
        webView.goBack()
    }
    
    func forward() {
        webView.goForward()
    }
    
    
}
