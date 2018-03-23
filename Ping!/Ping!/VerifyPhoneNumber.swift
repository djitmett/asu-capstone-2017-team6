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
            let defaults = UserDefaults.standard
            defaults.set(phone_number.text, forKey: "userPhone")
            defaults.synchronize()
        
            start_verification(phone_number: phone_number.text!)
            
            /**
            let storyBoard : UIStoryboard = UIStoryboard(name: "PhoneVerification", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifySMS") as UIViewController
            self.present(nextViewController, animated:true, completion:nil)
             **/
            
            self.performSegue(withIdentifier: "phone_verification_next", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please fill in a valid phone number", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        phone_number.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func start_verification(phone_number:String) {
        
        //Twillio Verify API
        let URL_SIGNUP = "https://api.authy.com/protected/json/phones/verification/start?"
        
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
        request.httpMethod = "POST"
        
        //Creating post paramter
        var postParameters = "via=sms"
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
    
    
    
}
