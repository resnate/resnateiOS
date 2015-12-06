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
                            
                            if let badgeName = badge["name"].string {
                                
                                let imageName = "\(badgeName).png"
                                let image = UIImage(named: imageName)
                                let imageView = UIImageView(image: image!)
                                
                                imageView.frame = CGRect(x: 10, y: y, width: 100, height: 100)
                                self.badgesScrollView.addSubview(imageView)
                                
                                if let badgeDescription = badge["description"].string {
                                    
                                    let badgeNameLabel = UILabel(frame: CGRect(x: 130, y: y + 10, width: 190, height: 20))
                                    badgeNameLabel.text = badgeName
                                    badgeNameLabel.textColor = UIColor.whiteColor()
                                    badgeNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
                                    self.badgesScrollView.addSubview(badgeNameLabel)
                                    
                                    let badgeDescriptionLabel = UILabel(frame: CGRect(x: 130, y: y + 30, width: 190, height: 50))
                                    badgeDescriptionLabel.numberOfLines = 3
                                    badgeDescriptionLabel.text = badgeDescription
                                    badgeDescriptionLabel.textColor = UIColor.whiteColor()
                                    badgeDescriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
                                    self.badgesScrollView.addSubview(badgeDescriptionLabel)
                                    
                                }
                                
                                y += 150
                                
                            }
                            
                            
                            
                            
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
