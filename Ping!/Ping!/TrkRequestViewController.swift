//
//  TrkRequestViewController.swift
//  Ping!
//
//  Created by Corey Rakes on 11/17/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit
import OneSignal



class TrkRequestViewController: UIViewController, UITextFieldDelegate {
    
    /**
     - Text field needs to be implemented & include the 'hide away keyboard'
     - Grab text field input and store it into a request number variable
     - Run requested number against the DB
     - Return a message if it doesn't exist
     - if it does, proceed by grabbing their assigned player_id and store their phonenumber
     
     **/
    @IBOutlet weak var phoneNumber: UITextField!
    @IBAction func sendTracking(_ sender: Any) {
        
        
        //USER DEFAULTS FOR ONESIGNAL ID
        let defaults = UserDefaults.standard
        //CURRENTLY GRABS YOUR INFORMATION TO SEND THE PUSH NOTIFICATION TO YOU
        //let player_id = (defaults.object(forKey: "GT_PLAYER_ID_LAST") as? String)!
        let userFirstName = (defaults.object(forKey: "userFirstName") as? String)!
        let phone_number = (defaults.object(forKey: "userPhone") as? String)!
        
        // Validate phone number exists in DB
        let player_id = getPlayerIdFromPhoneNumber(phoneNumber: phoneNumber.text!)
        if (player_id != "INVALID"){
            print("Valid Number")
        } else {
            print("Invalid number")
        }
        
        //All OneSignal content is in JSON format
        let data = [
            "Phone" : phone_number,
            ]
        let message = userFirstName + " would like to share their location with you."
        print("Player_Id=", player_id)
        let notificationContent = [
            "include_player_ids": [player_id],
            "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
            "headings": ["en": "PING! TRACKING"],
            "subtitle": ["en": "Someone has sent you a tracking invitation."],
            "data": data,
            //Displays image in push notif.
            //"ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
            //Shows notification bage on application
            "ios_badgeType": "Increase",
            "ios_badgeCount": 1,
            "buttons": [["id": "refuse-button", "text":"Refuse"],["id": "accept-button", "text":"Accept" ]]
            ] as [String : Any]
        
        //Send request and receive confirmation
        OneSignal.postNotification(notificationContent, onSuccess: { result in
            print("result = \(result!)")
        }, onFailure: {error in
            print("error = \(error!)")
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumber.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func getPlayerIdFromPhoneNumber(phoneNumber: String) -> String {
        let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/getuserdata.php?"
        let requestURL = NSURL(string: URL_SIGNUP)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        let postParameters = "user_phone="+phoneNumber;
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        var player_Id:String = ""
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
            if error != nil{
                print("error is \(String(describing: error))")
                return;
            }
            //parsing the response
            do {
                print("Got HERE!")
                //converting resonse to NSDictionary
                let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                //parsing the json
                if let parseJSON = myJSON {
                    //creating a string
                    var msg : String!
                    var data : NSArray!
                    //getting the json response
                    msg = parseJSON["message"] as! String?
                    if(msg == "Operation successfully!"){
                        data = parseJSON["data"] as! NSArray?
                        DispatchQueue.main.async(execute: {
                            player_Id = (data[1] as? String)!
                        })
                    } else if(msg == "User does not exist!"){
                        DispatchQueue.main.async(execute: {
                            player_Id = "INVALID"
                        })
                    }
                }
            } catch {
                print(error)
            }
            
        })
        //executing the task
        task.resume()
        print("Returning=", player_Id)
        return player_Id
    }
}
