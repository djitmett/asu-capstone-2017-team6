//
//  TrkRequestViewController.swift
//  Ping!
//
//  Created by Corey Rakes on 11/17/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit
import OneSignal

class TrkRequestViewController: UIViewController {
    
    /**
     - Text field needs to be implemented & include the 'hide away keyboard'
     - Grab text field input and store it into a request number variable
     - Run requested number against the DB
     - Return a message if it doesn't exist
     - if it does, proceed by grabbing their assigned player_id and store their phonenumber
     
     **/
    
    @IBAction func sendTracking(_ sender: Any) {
        
        //USER DEFAULTS FOR ONESIGNAL ID
        let defaults = UserDefaults.standard
        //CURRENTLY GRABS YOUR INFORMATION TO SEND THE PUSH NOTIFICATION TO YOU
        let player_id = (defaults.object(forKey: "GT_PLAYER_ID_LAST") as? String)!
        let userFirstName = (defaults.object(forKey: "userFirstName") as? String)!
        let phone_number = (defaults.object(forKey: "userPhone") as? String)!
        
        //All OneSignal content is in JSON format
        let data = [
            "Phone" : phone_number,
            ]
        let message = userFirstName + " would like to share their location with you."
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
            print("result = \(result!)")
        }, onFailure: {error in
            print("error = \(error!)")
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
