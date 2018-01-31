//
//  EditProfileViewController.swift
//  Ping!
//
//  Created by Nathan Waitman on 1/28/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var AvatarImageView: UIImageView!
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var PhoneNumberTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var RepeatPasswordTextField: UITextField!
    
    var user_first_name = "First Name"
    var user_last_name = "Last Name"
    var userfbid = "NULL"
    var user_device_id = "device id"
    var usertype = "user"
    var email = "email@test.com"
    var phone = "180012345678"
    var password = "password"
    var useravatar = "avatar.jpeg"
    var usertime = "test"
    
    let defaults = UserDefaults.standard

    let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/updateuserdata.php?"
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ChangeAvatarTapped(_ sender: Any) {
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
        //Hide the keyboard
        FirstNameTextField.resignFirstResponder()
        LastNameTextField.resignFirstResponder()
        PhoneNumberTextField.resignFirstResponder()
        EmailTextField.resignFirstResponder()
        PasswordTextField.resignFirstResponder()
        RepeatPasswordTextField.resignFirstResponder()
        
        //DOESN'T WORK YET
        //Save image
        //let img = avatarImageView.image
        //let data = UIImagePNGRepresentation(img!)
        //UserDefaults.standard.set(data, forKey: "myImageKey")
        //UserDefaults.standard.synchronize()
        
    }
    
    @IBAction func SaveButtonTapped(_ sender: Any) {
        
        //OneSignal player_id as user_device_id for now
        let defaults = UserDefaults.standard
        
        //DB Variables
        user_first_name = FirstNameTextField.text!
        user_last_name = LastNameTextField.text!
        phone = PhoneNumberTextField.text!
        email = EmailTextField.text!
        password = PasswordTextField.text!
        
        //Store values in UserDefaults
        defaults.set(user_first_name, forKey: "userFirstName")
        defaults.set(user_last_name, forKey: "userLastName")
        defaults.set(phone, forKey: "userPhone")
        defaults.set(true, forKey: "isLogged")
        defaults.synchronize()
        
        //CALL THE SIGN UP FUNCTION (SEND DATA TO DB)
        edit(first_name: user_first_name, last_name: user_last_name)
        
    }
    
    func edit(first_name:String, last_name:String) {
        
        //let postParameters = "user_fb_id=84&user_device_id=12345&user_type=changed&user_first_name=testfirst1&user_last_name=testlast1&user_phone=12345&user_email=TestEmail&user_password=testpass&user_avatar=none&user_join_datetime=nodatetime";
        
        //URL is defined above
        let requestURL = NSURL(string: URL_SIGNUP)
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //setting the method to post
        request.httpMethod = "POST"
        
        //creating the post parameter by concatenating the keys and values from text field
        let postParameters = "user_fb_id= "+userfbid+"&user_type="+usertype+"&user_device_id="+user_device_id+"&user_first_name="+first_name+"&user_last_name="+last_name+"&user_phone="+phone+"&user_email="+email+"&user_password="+password+"&user_avatar="+useravatar+"&user_join_datetime="+usertime;
        
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
                    
                    //getting the json response
                    msg = parseJSON["message"] as! String?
                    
                    //printing the response
                    //print(msg)
                    
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
    
    

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
       guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        AvatarImageView.image = selectedImage
        
        // Dismiss the picker.
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        var firstName = ""
        var lastName = ""
        var phoneNumber = ""
        var emailAddress = ""
        var myPassword = ""
        
        super.viewDidLoad()
        
        if (defaults.object(forKey: "userFirstName") != nil) {
            firstName = (defaults.object(forKey: "userFirstName") as? String)!
        }
        if (defaults.object(forKey: "userLastName") != nil) {
            lastName = (defaults.object(forKey: "userLastName") as? String)!
        }
        if (defaults.object(forKey: "userPhone") != nil) {
            phoneNumber = (defaults.object(forKey: "userPhone") as? String)!
        }
        if (defaults.object(forKey: "userEmail") != nil) {
            emailAddress = (defaults.object(forKey: "userEmail") as? String)!
        }
        if (defaults.object(forKey: "userPassword") != nil) {
            myPassword = (defaults.object(forKey: "userPassword") as? String)!
        }
        
        self.FirstNameTextField.text = firstName
        self.LastNameTextField.text = lastName
        self.PhoneNumberTextField.text = phoneNumber
        self.EmailTextField.text = emailAddress
        self.PasswordTextField.text = myPassword
        
        
        
        // Do any additional setup after loading the view.
    }
   
    
    

}
