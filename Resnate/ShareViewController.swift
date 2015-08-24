//
//  ShareViewController.swift
//  
//
//  Created by Amir Moosavi on 21/08/2015.
//
//

import UIKit

class AutoUser : UITableViewCell{
    
    //Do whatever you want as exta customization
}


class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var type = ""
    
    var shareID: Int = 0
    
    
    var users: [User] = []
    
    var autoUsers = [User]()
    
    var removedUsers = [User]()
    
    
    var subTags: [Int] = []
    
    
    var autocompleteTableView = UITableView(frame: CGRect(x: 0, y: 170, width: UIScreen.mainScreen().bounds.width, height: 500))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Share \(type)"
        var b = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: "sendMsg:")

        self.view.addSubview(autocompleteTableView)
        self.navigationItem.rightBarButtonItem = b
        
        userNames.becomeFirstResponder()
        
        userNames.delegate = self
        
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        
        autocompleteTableView.scrollEnabled = true
        autocompleteTableView.registerClass(AutoUser.self as AnyClass, forCellReuseIdentifier: "AutoUser")
        autocompleteTableView.hidden = true
        
        
        
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        autocompleteTableView.hidden = false
        var substring = (self.userNames.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        searchAutocompleteEntriesWithSubstring(substring)
        return true
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        autoUsers.removeAll(keepCapacity: false)
        
        for user in users
        {
          
            var myString: NSString! = user.name as NSString
            
            var substringRange: NSRange! = myString.rangeOfString(substring, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if (substringRange.location == 0)
            {
                autoUsers.append(user)
            }
        }
        autocompleteTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoUsers.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AutoUser", forIndexPath: indexPath) as! UITableViewCell
        let index = indexPath.row as Int
        
        cell.contentView.subviews.map({ $0.removeFromSuperview() })
        
        let label = UILabel(frame: CGRect(x: 40, y: 0, width: 270, height: 45))
        
        label.text = autoUsers[index].name
        
        let imgURL = NSURL(string: "https://graph.facebook.com/\(autoUsers[index].uid)/picture?width=200&height=200")
        
        let userImgView = UIImageView(frame: CGRect(x: 5, y: 7.5, width: 30, height: 30))
        
        self.getDataFromUrl(imgURL!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                userImgView.image = UIImage(data: data!)
            }
        }
        
        cell.contentView.addSubview(label)
        
        cell.contentView.addSubview(userImgView)
        
        
        cell.tag = autoUsers[index].id
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        for user in autoUsers {
            
            var subCount = toSend.subviews.count
            
            if user.id == selectedCell.tag {
                
                let addedUser = UIView(frame: CGRect(x: 37.5, y: 0, width: 140, height: 30))
                
                addedUser.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
                
                let addedUserLabel = UILabel(frame: CGRect(x: 30, y: 0, width: 100, height: 30))
                
                addedUserLabel.text = user.name
                
                addedUserLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
                
                addedUserLabel.textColor = UIColor.whiteColor()
                
                addedUser.addSubview(addedUserLabel)
                
                
                
                let addedUserClose = UIImageView(frame: CGRect(x: -2.5, y: -2.5, width: 35, height: 35))
                
                addedUserClose.image = UIImage(named: "close")
                
                addedUser.addSubview(addedUserClose)
                
                let tapRec = UITapGestureRecognizer()
                
                tapRec.addTarget(self, action: "removeUser:")
                addedUserClose.addGestureRecognizer(tapRec)
                
                addedUserClose.tag = user.id
                addedUserClose.userInteractionEnabled = true
                
                
                addedUser.tag = user.id
                
                if subCount == 0 {
                    self.toSend.addSubview(addedUser)
                    subTags.append(addedUser.tag)
                } else {
                    if contains(subTags, addedUser.tag) {
                        

                    } else {
                        if subCount == 1 {
                            addedUser.frame.origin.x = 182.5
                            self.toSend.addSubview(addedUser)
                            subTags.append(addedUser.tag)
                        } else if subCount == 2 {
                            addedUser.frame.origin.x = 5
                            addedUser.frame.origin.y = 35
                            self.toSend.addSubview(addedUser)
                            subTags.append(addedUser.tag)
                        } else if subCount == 3 {
                            addedUser.frame.origin.x = 150
                            addedUser.frame.origin.y = 35
                            self.toSend.addSubview(addedUser)
                            subTags.append(addedUser.tag)
                        }
                    }
                }
                
                removedUsers.append(user)
                
                removeAtIndex(&users, find(users, user)!)
                
                searchAutocompleteEntriesWithSubstring(userNames.text)
                
            }
        }
        
    }
    
    @IBOutlet weak var userNames: UITextField!
    
    @IBOutlet weak var shareMessage: UITextView!
    
    @IBOutlet weak var toSend: UIView!
    
    func removeUser(sender: AnyObject) {
        
        removeAtIndex(&subTags, find(subTags, sender.view!.tag)!)
        
        for user in removedUsers {
            
            if user.id == sender.view!.tag {
                
                users.append(user)
                
                removeAtIndex(&removedUsers, find(removedUsers, user)!)
                
                searchAutocompleteEntriesWithSubstring(userNames.text)
                
            }
            
        }
        
        var addedUser = sender.view!.superview!
        
        if addedUser.frame.origin.x == 37.5 {
            
            for user in addedUser.superview!.subviews {
                if user.frame.origin.x == 182.5 {
                    if let userView = user as? UIView {
                        userView.frame = CGRect(x: 37.5, y: 0, width: 140, height: 30)
                    }
                    
                }
                 else if user.frame.origin.x == 5 {
                    if let userView = user as? UIView {
                        userView.frame = CGRect(x: 182.5, y: 0, width: 140, height: 30)
                    }
                    
                } else if user.frame.origin.x == 150 {
                    if let userView = user as? UIView {
                        userView.frame = CGRect(x: 5, y: 35, width: 140, height: 30)
                    }
                    
                }
            }
            addedUser.removeFromSuperview()
            
        } else if addedUser.frame.origin.x == 182.5 {
            
            for user in addedUser.superview!.subviews {
                if user.frame.origin.x == 5 {
                    if let userView = user as? UIView {
                        userView.frame = CGRect(x: 182.5, y: 0, width: 140, height: 30)
                    }
                    
                } else if user.frame.origin.x == 150 {
                    if let userView = user as? UIView {
                        userView.frame = CGRect(x: 5, y: 35, width: 140, height: 30)
                    }
                    
                }
            }
            addedUser.removeFromSuperview()
            
        } else if addedUser.frame.origin.x == 5 {
            
            for user in addedUser.superview!.subviews {
                if user.frame.origin.x == 150 {
                    if let userView = user as? UIView {
                        userView.frame = CGRect(x: 5, y: 35, width: 140, height: 30)
                    }
                    
                }
            }
            addedUser.removeFromSuperview()
            
            
        } else {
            addedUser.removeFromSuperview()
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
