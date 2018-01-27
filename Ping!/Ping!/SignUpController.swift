//
//  LoginController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 11/16/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit

class SignUpController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phonenumberField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    //INIT variables
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
    
    
    @IBOutlet weak var signupButton: UIButton!
    
    //DATABASE PHP SCRIPT
    let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/adduserdata.php?"
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        print("image picker cancel")
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avatarImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        print("image picker controller")
        self.dismiss(animated: true, completion: nil)
        
        //below was the original code:
        // The info dictionary may contain multiple representations of the image. You want to use the original.
//        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
//            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
//        }
//
//        // Set photoImageView to display the selected image.
//        avatarImageView.image = selectedImage
//
//        // Dismiss the picker.
//        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        //Hide the keyboard
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        phonenumberField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    //Sign up button
    @IBAction func signupBtn(_ sender: Any) {
        print("signup button pressed ")
        //OneSignal player_id as user_device_id for now
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "GT_PLAYER_ID_LAST") != nil){
            user_device_id = (defaults.object(forKey: "GT_PLAYER_ID_LAST") as? String)!}
        
        //DB Variables
        user_first_name = firstNameField.text!
        user_last_name = lastNameField.text!
        phone = phonenumberField.text!
        email = emailField.text!
        password = passwordField.text!
        
        //Store values in UserDefaults
        defaults.set(user_first_name, forKey: "userFirstName")
        defaults.set(user_last_name, forKey: "userLastName")
        defaults.set(phone, forKey: "userPhone")
        defaults.set(true, forKey: "isLogged")
        defaults.synchronize()
        
        //date time
        let date = Date()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let todaysDate = dateFormatterGet.string(from: date)
        usertime = todaysDate
        
        //save image and compress to lowest quality range is 0.0 to 1.0
        //can also make PNG Rep
        let imageData = UIImageJPEGRepresentation(avatarImageView.image!, 0.0)
        //should never be nil because of default photo
        if(imageData==nil) {
            print("image data is nil")
            return;
            
        }
        //debug:
        print("the image data is ", imageData)
        
        
        //CALL THE SIGN UP FUNCTION (SEND DATA TO DB)
        sign_up(first_name: user_first_name, last_name: user_last_name, imageDataKey: imageData! as NSData)
//        sign_up(first_name: user_first_name, last_name: user_last_name)
        
    }
    
    func sign_up(first_name:String, last_name:String, imageDataKey: NSData) {
//    func sign_up(first_name:String, last_name:String) {
    
        //URL is defined above
        print("sign_up")
        let requestURL = NSURL(string: URL_SIGNUP)
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        let useravatar_test = imageDataKey
        print("useravatar_test", useravatar_test)
        
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
                    print(msg)
                    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        phonenumberField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
    }
    
}
