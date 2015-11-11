//
//  BadgesViewController.swift
//  Resnate
//
//  Created by Amir Moosavi on 09/11/2015.
//  Copyright © 2015 Resnate. All rights reserved.
//

import UIKit

class BadgesViewController: UIViewController {
    
    var ID = 0
    
    @IBOutlet weak var badgesScrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Badges"

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "testBkgd.jpg")!)
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: String(self.ID))
        
        request(req.buildURLRequest("users/", path: "/level")).responseJSON { response in
            
            if let re = response.result.value {
                
                let json = JSON(re)
                
                if let badges = json["badges"].array {

                    var y = 20
                    if badges.count > 0 {
                        
                        let reverseBadges = badges.reverse()
                        for badge in reverseBadges {

                                let imageName = "\(badge).png"
                                let image = UIImage(named: imageName)
                                let imageView = UIImageView(image: image!)
                                
                                imageView.frame = CGRect(x: 50, y: y, width: Int(UIScreen.mainScreen().bounds.width - 100), height: Int(UIScreen.mainScreen().bounds.width - 100))
                                self.badgesScrollView.addSubview(imageView)
                                y += Int(UIScreen.mainScreen().bounds.width - 30)
                            
                        }
                        
                        self.badgesScrollView.contentSize.height = CGFloat(y)
                        
                    }
                    
                }
            }
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
