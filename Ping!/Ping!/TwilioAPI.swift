//
//  TwilioAPI.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 3/25/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import UIKit

class TwilioAPI: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func start_verification(phone_number:String, verify_type:String, segue:String) {
        
        //Twillio Verify API
        let twillioAPI = "https://api.authy.com/protected/json/phones/verification/start?"
        
        //URL is defined above
        let requestURL = NSURL(string: twillioAPI)
        
        let headers = [
            "x-authy-api-key": "hdWHzYFILyJRhk4PAA5X6mRanNzm7x5d",
            "cache-control": "no-cache",
            "postman-token": "cd0e3194-17d3-53ff-9707-f5bdc35b25bf"
        ]
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //setting the method to post
        request.allHTTPHeaderFields = headers
        request.httpMethod = "POST"
        
        //Creating post paramter
        var postParameters = "via=" + verify_type
        postParameters += "&country_code=1"
        postParameters += "&phone_number=" + phone_number
        postParameters += "&locale=en"
        
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
                    
                    //If phone number is valid & text send successfully
                    if(success == true){
                        if(segue=="next"){
                            DispatchQueue.main.async(execute: {
                                /**
                                 let storyBoard : UIStoryboard = UIStoryboard(name: "PhoneVerification", bundle:nil)
                                 let nextViewController = storyBoard.instantiateViewController(withIdentifier: "phone_verification_next") as UIViewController
                                 self.present(nextViewController, animated:true, completion:nil)
                                 **/
                            })
                            
                        }
                    }
                    if(success == false && msg=="Phone number is invalid"){
                        DispatchQueue.main.async(execute: {
                            let alert = UIAlertController(title: "Error", message: "This is an invalid phone number.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        })
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            let alert = UIAlertController(title: "Error", message: "There was an error. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        })
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
    
    
    func check_verification(phone_number:String, sms_code:String, segue:String) {
        let headers = [
            "x-authy-api-key": "hdWHzYFILyJRhk4PAA5X6mRanNzm7x5d",
            "cache-control": "no-cache",
            "postman-token": "718a6020-f9d1-c8c5-71ed-038f42d768bd"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.authy.com/protected/json/phones/verification/check?country_code=1&phone_number=\(phone_number)&verification_code=\(sms_code)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                //let httpResponse = response as? HTTPURLResponse
                // print(httpResponse!)
                
                do {
                    
                    let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    
                    if let parseJSON = myJSON {
                        var msg : String!
                        var success : Bool!
                        
                        //getting the json response
                        msg = parseJSON["message"] as! String?
                        success = parseJSON["success"] as! Bool?
                        
                        //printing the response
                        print(msg)
                        print(success)
                        
                        //If SMS validation success
                        if(success == true){
                            DispatchQueue.main.async(execute: {
                                let successAlert = UIAlertController(title: "Success", message: "Your phone number has been validated.", preferredStyle: UIAlertControllerStyle.alert)
                                if(segue=="signup") {
                                    successAlert.addAction(UIAlertAction(title: "Continue to Sign-Up", style: .default, handler: { (action: UIAlertAction!) in
                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignUp") as UIViewController
                                        self.present(nextViewController, animated:true, completion:nil)
                                        
                                    }))
                                }
                                else {
                                    successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                                        
                                        
                                    }))
                                }
                                
                                
                                self.present(successAlert, animated: true, completion: nil)
                                
                            })
                        }
                        //If SMS validation failed
                        if(success == false && msg=="Verification code is incorrect"){
                            DispatchQueue.main.async(execute: {
                                let alert = UIAlertController(title: "Error", message: "Verification code is incorrect. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            })
                        }
                    }
                } catch {
                    print(error)
                }
                
            }
        })
        
        dataTask.resume()
    }
    
    
    
}
