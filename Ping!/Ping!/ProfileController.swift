//
//  ProfileController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 11/20/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {

    @IBAction func logout(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isLogged")
        defaults.synchronize()
        performSegue(withIdentifier: "unwindSegueToLogin", sender: self)
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
