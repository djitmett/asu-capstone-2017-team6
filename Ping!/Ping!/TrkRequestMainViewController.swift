//
//  TrkRequestMainViewController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 1/21/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import UIKit

class TrkRequestMainViewController: UIViewController {
    
    @IBAction func clearMapBtn(_ sender: Any) {
        print("@ClearTracking")
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "currentTrackedUser") != nil){
            defaults.removeObject(forKey: "currentTrackedUser")
            print("Cleared tracked user")
        }
    
}
override func viewDidLoad() {
    super.viewDidLoad()
    
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
