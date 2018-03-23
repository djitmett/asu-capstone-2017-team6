//
//  VerifySMSToken.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 3/23/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import UIKit

class VerifySMSToken: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sms_code: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var verify_sms_next: UIButton!
    
    @IBAction func verify_sms_next(_ sender: Any) {
        
        if (sms_code.text != "" ) {
            let defaults = UserDefaults.standard
            if (defaults.object(forKey: "userPhone") != nil) {
                let phone_number = (defaults.object(forKey: "userPhone") as? String)!
                 let phone_number_trim = phone_number.trimmingCharacters(in: .whitespaces)
                start_verification(phone_number: phone_number_trim, sms_code: sms_code.text!)
            }
        
            /** Signup Segue
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignUp") as UIViewController
        self.present(nextViewController, animated:true, completion:nil)
             **/
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func start_verification(phone_number:String, sms_code:String) {
        
       
        
        //Twillio Verify API
        let URL_SIGNUP = "https://api.authy.com/protected/json/phones/verification/check?"
        
        //URL is defined above
        let requestURL = NSURL(string: URL_SIGNUP)
        
        let headers = [
            "x-authy-api-key": "hdWHzYFILyJRhk4PAA5X6mRanNzm7x5d",
            "cache-control": "no-cache",
            "postman-token": "cd0e3194-17d3-53ff-9707-f5bdc35b25bf"
        ]
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //setting the method to post
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        
        //Creating post paramter
        var postParameters = "country_code=1"
        postParameters += "&phone_number=" + phone_number
        postParameters += "&verification_code" + sms_code
        
        
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
                    var success : Bool!
                    
                    //getting the json response
                    msg = parseJSON["message"] as! String?
                    success = parseJSON["success"] as! Bool?
                    
                    //printing the response
                    print(msg)
                    print(success)
                    
                    //If phonenumber exists in DB
                    if(success == true){
                        print("worked")
                    }
                    //Phonenumber does not exist in DB
                    if(success == false){
                        print("didn't work")
                    }
                }
            } catch {
                print(error)
            }
            
        }
        
        //executing the task
        task.resume()
        //Prints HTTP POST data in console
        print(postParameters)
        
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
