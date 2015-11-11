//
//  ShareViewController.swift
//  
//
//  Created by Amir Moosavi on 21/08/2015.
//
//

import UIKit

class AutoUser : UITableViewCell{
    
 
}


class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var close: UIImageView!
    
    @IBOutlet weak var send: UILabel!
    
    var type = ""
    
    var shareID = ""
    
    var shareTitle = ""
    
    var users: [User] = []
    
    var autoUsers = [User]()
    
    var removedUsers = [User]()
    
    
    var subTags: [Int] = []
    
    
    var autocompleteTableView = UITableView(frame: CGRect(x: 0, y: 180, width: UIScreen.mainScreen().bounds.width, height: 500))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.title = self.shareTitle
        
        let tapClose = UITapGestureRecognizer()
        
        tapClose.addTarget(self, action: "closeModal")
        
        close.userInteractionEnabled = true
        
        self.close.addGestureRecognizer(tapClose)
        
        let tapSend = UITapGestureRecognizer()
        
        tapSend.addTarget(self, action: "sendMsg")
        
        send.userInteractionEnabled = true
        
        self.send.addGestureRecognizer(tapSend)
        
        self.automaticallyAdjustsScrollViewInsets = false

        self.view.addSubview(autocompleteTableView)
        
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
        
        
        
        
        let substring = (self.userNames.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if substring != "" {
            autocompleteTableView.hidden = false
            searchAutocompleteEntriesWithSubstring(substring)
        } else {
            autocompleteTableView.hidden = true
        }
        
        
        return true
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return textView.text.characters.count + (text.characters.count - range.length) <= 140
        
    }
    
    
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        autoUsers.removeAll(keepCapacity: false)
        
        for user in users
        {
          
            let myString: NSString! = user.name as NSString
            
            let substringRange: NSRange! = myString.rangeOfString(substring, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if (substringRange.location == 0)
            {
                autoUsers.append(user)
            }
        }
        autoUsers.sortInPlace() { $0.name < $1.name }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("AutoUser", forIndexPath: indexPath) 
        let index = indexPath.row as Int
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red:0.5, green:0.07, blue:0.21, alpha:1.0)
        cell.selectedBackgroundView = bgColorView
        
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
            
            let subCount = toSend.subviews.count
            
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
                    if subTags.contains(addedUser.tag) {
                        

                    } else {
                        if subCount == 1 {
                            addedUser.frame.origin.x = 5
                            addedUser.frame.origin.y = 35
                            self.toSend.addSubview(addedUser)
                            subTags.append(addedUser.tag)
                        } else if subCount == 2 {
                            addedUser.frame.origin.x = 150
                            addedUser.frame.origin.y = 35
                            self.toSend.addSubview(addedUser)
                            subTags.append(addedUser.tag)
                            
                        }
                    }
                }
                
                removedUsers.append(user)
                
                users.removeAtIndex(users.indexOf(user)!)
                
                searchAutocompleteEntriesWithSubstring(userNames.text!)
                
                userNames.text = ""
                autocompleteTableView.hidden = true
                
            }
        }
        
    }
    
    @IBOutlet weak var userNames: UITextField!
    
    @IBOutlet weak var shareMessage: UITextView!
    
    @IBOutlet weak var toSend: UIView!
    
    func removeUser(sender: AnyObject) {
        
        subTags.removeAtIndex(subTags.indexOf(sender.view!!.tag)!)
        
        for user in removedUsers {
            
            if user.id == sender.view!!.tag {
                
                users.append(user)
                
                removedUsers.removeAtIndex(removedUsers.indexOf(user)!)
                
                searchAutocompleteEntriesWithSubstring(userNames.text!)
                
            }
            
        }
        
        let addedUser = sender.view!!.superview!

        if addedUser.frame.origin.x == 37.5 {
            
            for user in addedUser.superview!.subviews {
                if user.frame.origin.x == 5 {
                    user.frame = CGRect(x: 37.5, y: 0, width: 140, height: 30)
                } else if user.frame.origin.x == 150 {
                    user.frame = CGRect(x: 5, y: 35, width: 140, height: 30)
                }
            }
            addedUser.removeFromSuperview()
            
        } else if addedUser.frame.origin.x == 5 {
            
            for user in addedUser.superview!.subviews {
                if user.frame.origin.x == 150 {
                    user.frame = CGRect(x: 5, y: 35, width: 140, height: 30)
                    
                }
            }
            addedUser.removeFromSuperview()
            
            
        } else {
            addedUser.removeFromSuperview()
        }
        
    }
    
    func sendMsg(){
        
        var subject = ""
        
        let recipients = subTags.description.replace("[", withString: "").replace("]", withString: "")
            
        subject = "\(self.type[self.type.startIndex])#\(shareID)"
        
        
        
        if subTags.isEmpty {
            
            if UIApplication.sharedApplication().respondsToSelector(Selector("registerUserNotificationSettings:")) {
                
                let noRecipientAlert = UIAlertController(title: "Can't send message", message: "Please add recipients", preferredStyle: UIAlertControllerStyle.Alert)
                noRecipientAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    
                presentViewController(noRecipientAlert, animated: true, completion: nil)
                
                
            } else {
                
                let alert = UIAlertView()
                alert.title = "Can't send message"
                alert.message = "Please add recipients"
                alert.addButtonWithTitle("OK")
                alert.show()
                
            }
            
            
            
        } else {
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
        
        let resnateID = dictionary!["userID"] as! String
        
        if ((shareMessage.text!).characters.count <= 140){
            
            let parameters =  ["body":"\(shareMessage.text)", "subject": "\(subject)", "user": "\(recipients)", "commit": "Send message", "sender_id": resnateID]
            
            
            
            let URL = NSURL(string: "https://www.resnate.com/api/messages")!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
            mutableURLRequest.HTTPMethod = Method.POST.rawValue
            mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
            
            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    let window = UIApplication.sharedApplication().keyWindow
                    
                    if window!.rootViewController as? UITabBarController != nil {
                        let tababarController = window!.rootViewController as! UITabBarController
                        tababarController.selectedIndex = 0
                    }
                    
                
            }
            
        }
        }
        
        
        
    }
    
    func closeModal() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
