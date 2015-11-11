//
//  FollowViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 08/07/2015.
//  Copyright (c) 2015 Resnate. All rights reserved.
//

import UIKit

class FollowViewController: UIViewController, UIScrollViewDelegate {

    var ID = 0
    
    var type = ""
    
    var page = 1
    
    var y = 0
    
    var remaining = false
    
    var dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
    
    func loadUsers(){
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = String(ID)
        
        let req = Router(OAuthToken: resnateToken, userID: resnateID)
        
        let path = "/\(type)/\(page)"
        
        request(req.buildURLRequest("users/", path: path)).responseJSON { response in
            
            let json = JSON(response.result.value!)
            
            if let users = json.array {
                
                if users.count != 10 {
                    
                    self.remaining = false
                    
                } else {
                    
                    
                    self.remaining = true
                }
                
                for user in users {
                    
                    let followUberView = UIView(frame: CGRect(x: 0, y: self.y, width: 350, height: 150))
                    
                    let name = user["name"].string!
                    
                    let uid = user["uid"].string!
                    
                    let id = user["id"].int!
                    
                    let url = NSURL(string: "https://graph.facebook.com/\(uid)/picture?width=200&height=200")
                    
                    let resnateID = String(id)
                    
                    let req = Router(OAuthToken: resnateToken, userID: resnateID)
                    
                    
                    request(req.buildURLRequest("users/", path: "/level")).responseJSON { response in
                        
                        var json = JSON(response.result.value!)
                        if let levelText = json["level_name"].string {
                            
                            let badgeImgView = UIImageView(frame: CGRect(x: 120, y: 30, width: 70, height: 70))
                            
                            let badgeImg = UIImage(named: "\(levelText).png")
                            
                            badgeImgView.image = badgeImg
                            
                            followUberView.addSubview(badgeImgView)
                        }
                        
                        if let points = json["points"].string {
                            
                            let pointsLabel = UILabel(frame: CGRect(x: 210, y: 40, width: 150, height: 50))
                            
                            pointsLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 50)
                            
                            pointsLabel.textColor = UIColor.whiteColor()
                            
                            pointsLabel.text = points
                            
                            followUberView.addSubview(pointsLabel)
                            
                        }
                        
                    }
                    
                    
                    
                    self.getDataFromUrl(url!) { data in
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            
                            let followUserView = UIImageView(frame: CGRect(x: 10, y: 0, width: 100, height: 100))
                            
                            let userImg = UIImage(data: data!)
                            
                            followUserView.image = userImg
                            
                            followUberView.addSubview(followUserView)
                            
                            let tapRecProfile = UITapGestureRecognizer()
                            
                            tapRecProfile.addTarget(self, action: "profile:")
                            followUberView.tag = id
                            followUberView.addGestureRecognizer(tapRecProfile)
                            followUberView.userInteractionEnabled = true
                            
                        }
                    }
                    
                    
                    let followLabel = UILabel(frame: CGRect(x: 120, y: 0, width: 220, height: 30))
                    
                    followLabel.textColor = UIColor.whiteColor()
                    
                    followLabel.text = name
                    
                    followLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
                    
                    followUberView.addSubview(followLabel)
                    
                    
                    self.followView.addSubview(followUberView)
                    
                    self.y += 150
                    
                }
                
                self.followView.contentSize.height = CGFloat(self.y + 20)
                
            }
            
            
            
        }
        
        page += 1
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        self.navigationItem.title = type.capitalizedString
        
        self.dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        loadUsers()
        
        self.followView.delegate = self
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if self.remaining == true {
            
            if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) && scrollView.contentSize.height > 1 && scrollView.tag != -1) {
                
                self.followView.contentSize.height += 10
                
                let loadingView = UIActivityIndicatorView(frame: CGRect(x: Int(self.followView.frame.width/2 - 25), y: Int(self.followView.contentSize.height - 30), width: 50, height: 50))
                
                self.followView.addSubview(loadingView)
                
                loadingView.startAnimating()
                
                self.followView.tag = -1
                
                loadUsers()
                
                self.followView.tag = 0
                
                let delay = 0.3 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    loadingView.stopAnimating()
                }
                
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet weak var followView: UIScrollView!
    

}
