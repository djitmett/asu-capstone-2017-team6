//
//  SideMenuController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 2/9/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import UIKit
import SideMenu
import Font_Awesome_Swift

class SideMenuController: UITableViewController {
    
    @IBOutlet weak var profileAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UIButton!
    
    @IBOutlet weak var favoritesIcon: UILabel!
    @IBOutlet weak var contactsIcon: UILabel!
    @IBOutlet weak var aboutIcon: UILabel!
    @IBOutlet weak var shareIcon: UILabel!
    @IBOutlet weak var rateIcon: UILabel!
    @IBOutlet weak var settingsIcon: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileAvatar.layer.cornerRadius = self.profileAvatar.frame.size.width / 2;
        self.profileAvatar.clipsToBounds = true;
        
        
        favoritesIcon.setFAIcon(icon: .FAStar, iconSize: 20)
        contactsIcon.setFAIcon(icon: .FAAddressBook, iconSize:20)
        aboutIcon.setFAIcon(icon: .FAInfoCircle, iconSize:20)
        shareIcon.setFAIcon(icon: .FAShareSquare, iconSize:20)
        rateIcon.setFAIcon(icon: .FACheckCircle, iconSize:20)
        settingsIcon.setFAIcon(icon: .FACog, iconSize:20)
        
        let defaults = UserDefaults.standard
        var firstName = ""
        var lastName = ""
        var phoneNumber = ""
        
        if (defaults.object(forKey: "userFirstName") != nil) {
             firstName = (defaults.object(forKey: "userFirstName") as? String)!
        }
        if (defaults.object(forKey: "userLastName") != nil) {
             lastName = (defaults.object(forKey: "userLastName") as? String)!
        }
        if (defaults.object(forKey: "userPhone") != nil) {
            phoneNumber = (defaults.object(forKey: "userPhone") as? String)!
        }
        usernameLabel.setTitle(firstName, for: .normal)
        
        //load avatar
        loadData(phone_number: phoneNumber)
    }
    
    //Validate login with database
    func loadData(phone_number:String) {
        
        //DATABASE PHP SCRIPT
        let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/getuserdata.php?"
        //URL is defined above
        let requestURL = NSURL(string: URL_SIGNUP)
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        //setting the method to post
        request.httpMethod = "POST"
        //creating the post parameter by concatenating the keys and values from text field
        let postParameters = "user_phone="+phone_number;
        //adding the parameters to request body
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            if error != nil{
                print("error is \(String(describing: error))")
                return;
            }
            //parsing the response
            do {
                //converting resonse to NSDictionary
                let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                //parsing the json
                if let parseJSON = myJSON {
                    //creating a string
                    var msg : String!
                    var myData : NSArray!
                    //getting the json response
                    msg = parseJSON["message"] as! String?
                    //printing the response
                    //print(msg)
                    //If phonenumber exists in DB
                    if(msg == "Operation successfully!"){
                        myData = parseJSON["data"] as! NSArray?
                        // TODO: load DB info into text fields
                        //let db_password = myData[5] as? String
                        //let user_first_name = myData[2] as? String
                        //let user_last_name = myData[3] as? String
                        let encodedAvatar = myData[7] as? String
                        //print (encodedAvatar!)
                        if (encodedAvatar != nil) {
                            if (encodedAvatar! != "testimage.jpg") {
                                let dataDecoded : Data = Data(base64Encoded: encodedAvatar!, options: .ignoreUnknownCharacters)!
                                let decodedImage = UIImage(data: dataDecoded)!
                                DispatchQueue.main.async {
                                self.profileAvatar.image = decodedImage
                                }
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
            
        }
        
        //executing the task
        task.resume()
        //Prints HTTP POST data in console
        //print(postParameters)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(animated)
        
        // refresh cell blur effect in case it changed
        tableView.reloadData()
        
        //guard SideMenuManager.default.menuBlurEffectStyle == nil else {
        //    return
        //}
        
    }
    
    
}
