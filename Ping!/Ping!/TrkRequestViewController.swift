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
    var player_id = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //USER DEFAULTS FOR ONESIGNAL ID
        let defaults = UserDefaults.standard
        player_id = (defaults.object(forKey: "GT_PLAYER_ID_LAST") as? String)!
        
        //test notification
        OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": [player_id]])
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
