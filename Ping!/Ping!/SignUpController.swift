//
//  LoginController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 11/16/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//
//test

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
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        avatarImageView.image = resizeImage(image: selectedImage, targetSize: CGSize.init(width:200,height:200))
        // Dismiss the picker.
        self.dismiss(animated: true, completion: nil)
    
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
        
        if (user_first_name != "" &&
            user_last_name != "" &&
            phone != "" &&
            email != "" &&
            password != ""){
            
            //Store values in UserDefaults
            defaults.set(user_first_name, forKey: "userFirstName")
            defaults.set(user_last_name, forKey: "userLastName")
            defaults.set(phone, forKey: "userPhone")
            defaults.synchronize()
            
            //date time
            let date = Date()
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let todaysDate = dateFormatterGet.string(from: date)
            usertime = todaysDate
            
            //CALL THE SIGN UP FUNCTION (SEND DATA TO DB)
            sign_up(first_name: user_first_name, last_name: user_last_name)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func sign_up(first_name:String, last_name:String) {
        
        //URL is defined above
        let requestURL = NSURL(string: URL_SIGNUP)
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //Create request
        request.httpMethod = "POST"
        
        // Encode avatar image for saving in DB
        let imageData = UIImagePNGRepresentation(avatarImageView.image!)
        var encodedAvatar = imageData?.base64EncodedString(options: .lineLength64Characters)
        let customAllowedSet = NSCharacterSet(charactersIn:"+").inverted
        encodedAvatar = encodedAvatar?.addingPercentEncoding(withAllowedCharacters:customAllowedSet as CharacterSet)!
        
        //Creating post paramter
        var postParameters = "user_fb_id= " + userfbid
        postParameters += "&user_type=" + usertype
        postParameters += "&user_device_id=" + user_device_id
        postParameters += "&user_first_name=" + user_first_name
        postParameters += "&user_last_name=" + user_last_name
        postParameters += "&user_phone=" + phone
        postParameters += "&user_email=" + email
        postParameters += "&user_password=" + password
        postParameters += "&user_join_datetime=" + usertime
        postParameters += "&user_avatar=" + encodedAvatar!
        
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
                    if(msg == "Data added successfully!"){
                        let defaults = UserDefaults.standard
                        defaults.set(true, forKey: "isLogged")
                        defaults.synchronize()
                        self.segueMap()
                        
                    }
                    if (msg == "User already exists!"){
                        let alert = UIAlertController(title: "Error", message: "This user already exists.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
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
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        phonenumberField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        self.hideKeyboard()
        
        //Round avatar placeholder
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
        self.avatarImageView.clipsToBounds = true;
        
        //Set Icons & Round Corners
        firstNameField.setLeftViewFAIcon(icon: .FAUser, leftViewMode: .always, textColor: .white, backgroundColor: .clear, size: nil)
        firstNameField.layer.cornerRadius = 5
        
        lastNameField.setLeftViewFAIcon(icon: .FAUser, leftViewMode: .always, textColor: .white, backgroundColor: .clear, size: nil)
        lastNameField.layer.cornerRadius = 5
        
        phonenumberField.setLeftViewFAIcon(icon: .FAPhone, leftViewMode: .always, textColor: .white, backgroundColor: .clear, size: nil)
        phonenumberField.layer.cornerRadius = 5
        
        emailField.setLeftViewFAIcon(icon: .FAEnvelope, leftViewMode: .always, textColor: .white, backgroundColor: .clear, size: nil)
        emailField.layer.cornerRadius = 5
        
        passwordField.setLeftViewFAIcon(icon: .FALock, leftViewMode: .always, textColor: .white, backgroundColor: .clear, size: nil)
        passwordField.layer.cornerRadius = 5
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func segueMap() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainNavController")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
}
extension NSMutableData{
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

