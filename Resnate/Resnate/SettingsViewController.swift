

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var songkickEntry: UITextField!
    
    @IBOutlet var privateListening: UISwitch!
    
    var userID = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Settings"
        
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
        
        self.songkickEntry.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        self.songkickEntry.delegate = self
        
        self.songkickEntry.returnKeyType = .Done
        
        self.privateListening.addTarget(self, action: Selector("switchIsChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
        
        let resnateToken = dictionary!["token"] as! String
            
        let userID = dictionary!["userID"] as! String
        
        let req = Router(OAuthToken: resnateToken, userID: userID)
        
        request(req.buildURLRequest("users/", path: "/profile")).responseJSON { response in
            
            if let re = response.result.value {
                
                let user = JSON(re)
                
                if let userID = user["id"].int {
                    
                    self.userID = userID
                    
                    if let songkickID = user["songkickID"].string {
                        
                        self.songkickEntry.text = songkickID
                        
                    }
                    
                } else {
                    
                    if let userID = user["id"].string {
                        
                        self.userID = Int(userID)!
                        
                        if let songkickID = user["songkickID"].string {
                            
                            self.songkickEntry.text = songkickID
                            
                        }
                        
                    }
                    
                }
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func switchIsChanged(mySwitch: UISwitch) {
        if mySwitch.on {
            print("on")
        } else {
            print("off")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.text?.characters.count > 0 && textField.text?.characters.count < 200 {
            
            textField.resignFirstResponder()
            
            let dictionary = Locksmith.loadDataForUserAccount("resnateAccount")
            
            let resnateToken = dictionary!["token"] as! String
            
            let songkickID = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            let parameters =  ["token": "\(resnateToken)", "songkickID": songkickID]
            
            let URL = NSURL(string: "https://www.resnate.com/api/users/\(self.userID)")!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
            mutableURLRequest.HTTPMethod = Method.PUT.rawValue
            mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
            
            request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                
                let upcomingGigsLink = "https://api.songkick.com/api/3.0/users/\(songkickID)/calendar.json?reason=attendance&apikey=Pxms4Lvfx5rcDIuR&"
                
                request(.GET, upcomingGigsLink).responseJSON { response in
                    
                    if let re = response.result.value {
                        
                        let json = JSON(re)
                        
                        if let totalEntries = json["resultsPage"]["totalEntries"].int {
                                
                            if totalEntries > 50 {
                                
                                
                            } else {
                                
                                if let gigs = json["resultsPage"]["results"]["calendarEntry"].array {
                                    
                                    var allGigs: [Dictionary<String, String>] = []
                                    
                                    for gig in gigs {
                                        
                                        if let gigID = gig["event"]["id"].int {
                                            
                                            if let date = gig["event"]["start"]["date"].string {
                                                
                                               allGigs.append([ "songkick_id" : "\(gigID)", "gig_date" : "\(date)" ])
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    let data = try? NSJSONSerialization.dataWithJSONObject(allGigs, options: [])
                                    let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                    
                                    let parameters =  ["token": "\(resnateToken)", "multiGigs": string!]
                                    
                                    let URL = NSURL(string: "https://www.resnate.com/api/apiMultipleCreate/")!
                                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                                    mutableURLRequest.HTTPMethod = Method.POST.rawValue
                                    mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                                    
                                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                                        
                                     
                                        
                                    }
                                    
                                }
                                
                            }
                                
                        }
                        
                    }
                    
                    
                }
                
                
                let pastGigsLink = "https://api.songkick.com/api/3.0/users/\(songkickID)/gigography.json?apikey=Pxms4Lvfx5rcDIuR"
                
                request(.GET, pastGigsLink).responseJSON { response in
                    
                    if let re = response.result.value {
                        
                        let json = JSON(re)
                        
                        if let totalEntries = json["resultsPage"]["totalEntries"].int {
                            
                            if totalEntries > 50 {
                                
                                
                            } else {
                                
                                if let pastGigs = json["resultsPage"]["results"]["event"].array {
                                    
                                    var allPastGigs: [Dictionary<String, String>] = []
                                    
                                    for pastGig in pastGigs {
                                        
                                        if let pastGigID = pastGig["id"].int {
                                            
                                            if let date = pastGig["start"]["date"].string {
                                                
                                                allPastGigs.append([ "songkick_id" : "\(pastGigID)", "gig_date" : "\(date)" ])
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    let data = try? NSJSONSerialization.dataWithJSONObject(allPastGigs, options: [])
                                    let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                    
                                    let parameters =  ["token": "\(resnateToken)", "multiGigs": string!]
                                    
                                    let URL = NSURL(string: "https://www.resnate.com/api/apiPastMultipleCreate/")!
                                    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(""))
                                    mutableURLRequest.HTTPMethod = Method.POST.rawValue
                                    mutableURLRequest.setValue("Token \(resnateToken)", forHTTPHeaderField: "Authorization")
                                    
                                    request(ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0).responseJSON { response in
                                        
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                }
                
                
            }
            
        }
        
        return true
    }

}
