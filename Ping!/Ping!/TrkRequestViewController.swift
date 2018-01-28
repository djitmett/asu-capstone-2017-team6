//
//  TrkRequestViewController.swift
//  Ping!
//
//  Created by Corey Rakes on 11/17/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit
import OneSignal
import MapKit

class TrkRequestViewController: UIViewController, UITextFieldDelegate{

    
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var destinationInput: UITextField!
    
    @IBOutlet weak var trackingDurationSwitch: UISwitch!
    
    @IBOutlet weak var trackingDurationPicker: UIDatePicker!
    
    
    @IBOutlet weak var timedTrackingLabel: UILabel!
    @IBOutlet weak var indefiniteTrackingLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func sendTracking(_ sender: Any) {
        
        var player_ID = ""

        getPlayerIdFromPhoneNumber(phoneNumber: phoneNumber.text!){(value) in
            player_ID = value
            self.sendTracking2(player_id: player_ID)
        }
    }
    
    @IBAction func trackingDurationSwitchAction(_ sender: Any) {
        if trackingDurationSwitch.isOn {
            trackingDurationPicker.isEnabled = false
            indefiniteTrackingLabel.textColor = UIColor.black
            timedTrackingLabel.textColor = UIColor.gray
        }
        else {
            trackingDurationPicker.isEnabled = true
            timedTrackingLabel.textColor = UIColor.black
            indefiniteTrackingLabel.textColor = UIColor.gray
        }
    }
    
    
    func sendTracking2(player_id:String){
        let defaults = UserDefaults.standard
        var userFirstName = ""
        var phone_number = ""
        var end_long = 0
        var end_lat = 0
        
        let date = trackingDurationPicker.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour!
        let minute = components.minute!
        
        if (defaults.object(forKey: "userFirstName") != nil) {
            userFirstName = (defaults.object(forKey: "userFirstName") as? String)!
        }
        if (defaults.object(forKey: "userPhone") != nil) {
            phone_number = (defaults.object(forKey: "userPhone") as? String)!
        }
        if (player_id != "INVALID"){
            //print("Valid Number")
        } else {
            //print("Invalid number")
        }
        
        //All OneSignal content is in JSON format
        
        let data = [
            "Phone" : phone_number,
            "End-Location" : [end_long, end_lat],
            "Indefinite" : trackingDurationSwitch.isOn,
            "Duration" : [hour,minute],
            ] as [String : Any]
        
        let message = userFirstName + " would like to share their location with you."
        print("Player_Id=", player_id)
        let notificationContent = [
            "include_player_ids": [player_id],
            "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
            "headings": ["en": "PING! TRACKING"],
            "subtitle": ["en": "Someone has sent you a tracking invitation."],
            "data": data,
            //Shows notification bage on application
            "ios_badgeType": "Increase",
            "ios_badgeCount": 1,
            "buttons": [["id": "reject-button", "text":"Reject"],["id": "accept-button", "text":"Accept" ]]
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
        destinationInput.delegate = self
        trackingDurationPicker.isEnabled = false
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
