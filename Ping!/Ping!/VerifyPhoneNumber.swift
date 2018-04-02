//
//  VerifyPhoneNumber.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 3/23/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//
import Foundation
import UIKit

class VerifyPhoneNumber: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phone_number: UITextField!
    
    @IBAction func phone_verify(_ sender: Any) {
        
        if(phone_number.text != "") {
            var phonenumber_trimmed = phone_number.text?.trimmingCharacters(in: .whitespaces)
            phonenumber_trimmed = phonenumber_trimmed?.replacingOccurrences(of: "-", with: "")
            phonenumber_trimmed = phonenumber_trimmed?.replacingOccurrences(of: "(", with: "")
            phonenumber_trimmed = phonenumber_trimmed?.replacingOccurrences(of: ")", with: "")
            phonenumber_trimmed = phonenumber_trimmed?.replacingOccurrences(of: " ", with: "")
            
            let defaults = UserDefaults.standard
            defaults.set(phonenumber_trimmed, forKey: "userPhone")
            defaults.synchronize()
            let verify_type = "sms"
            print(phonenumber_trimmed)
            start_verification(phone_number: phonenumber_trimmed!, verify_type: verify_type)
            
            /**
             let storyBoard : UIStoryboard = UIStoryboard(name: "PhoneVerification", bundle:nil)
             let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifySMS") as UIViewController
             self.present(nextViewController, animated:true, completion:nil)
             **/
            
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please fill in a valid phone number", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func goToNextView() {
        performSegue(withIdentifier: "phone_verification_next", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phone_number.delegate = self
        self.hideKeyboard()
    }
    
    func start_verification(phone_number:String, verify_type:String) {
        
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
                         DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "phone_verification_next", sender: self)
                            })
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
        print(postParameters)
        
    }
    
    
    
}
