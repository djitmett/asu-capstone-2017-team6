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
        
        //CURRENTLY GRABS YOUR INFORMATION TO SEND THE PUSH NOTIFICATION TO YOU
        //let player_id = (defaults.object(forKey: "GT_PLAYER_ID_LAST") as? String)!
        var player_ID = ""
        // Validate phone number exists in DB
        //let player_id = getPlayerIdFromPhoneNumber_test(phoneNumber: phoneNumber.text!)
        
        getPlayerIdFromPhoneNumber(phoneNumber: phoneNumber.text!){(value) in
            player_ID = value
            self.sendTracking2(player_id: player_ID)
        }
    }
    
    
    func sendTracking2(player_id:String){
        let defaults = UserDefaults.standard
        let userFirstName = (defaults.object(forKey: "userFirstName") as? String)!
        let phone_number = (defaults.object(forKey: "userPhone") as? String)!
        if (player_id != "INVALID"){
            //print("Valid Number")
        } else {
            //print("Invalid number")
        }
        
        //All OneSignal content is in JSON format
        let data = [
            "Phone" : phone_number,
            ]
        let message = userFirstName + " would like to share their location with you."
        //print("Player_Id=", player_id)
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
            "buttons": [["id": "reject-button", "text":"Reject"],["id": "accept-button", "text":"Accept" ]]
            ] as [String : Any]
        
        //Send request and receive confirmation
        OneSignal.postNotification(notificationContent, onSuccess: { result in
            //print("result = \(result!)")
        }, onFailure: {error in
            print("error = \(error!)")
        })
    }
    
    @IBAction func clearTracking(_ sender: Any) {
        print("@ClearTracking")
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "currentTrackedUser") != nil){
            defaults.removeObject(forKey: "currentTrackedUser")
            print("Cleared tracked user")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumber.delegate = self
        
        //test notification
        //OneSignal.postNotification(["contents": ["en": "Is this the message"], "include_player_ids": [player_id]])
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
    
    func getPlayerIdFromPhoneNumber(phoneNumber: String, completion: @escaping (_ retPlayerID: String) -> ()) {
        let requestURL = "http://52.42.38.63/ioswebservice/api/getuserdata.php?"
        let postParameters = "user_phone="+phoneNumber;
        var player_ID: String = ""
        var request = URLRequest(url: URL(string: requestURL+postParameters)!)
        request.httpMethod = "POST"
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request, completionHandler:{
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let error = error {
                    print (error)
                    return
                }
                if let data = data {
                    do {
                        //converting resonse to NSDictionary
                        let myJSON =  try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                        //parsing the json
                        if let parseJSON = myJSON {
                            //creating a string
                            var msg : String!
                            var data : NSArray!
                            //getting the json response
                            msg = parseJSON["message"] as! String?
                            //print("MESSAGE=",msg)
                            if(msg == "Operation successfully!"){
                                data = parseJSON["data"] as! NSArray?
                                player_ID = (data[1] as? String)!
                            } else if(msg == "User does not exist!"){
                                player_ID = "INVALID"
                            }
                        }
                        completion(player_ID)
                    } catch {
                        print(error)
                    }
                }
            }
        })
        task.resume()
    }
    
}
