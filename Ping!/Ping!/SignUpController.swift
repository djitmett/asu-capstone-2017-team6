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
        
        //CALL THE SIGN UP FUNCTION (SEND DATA TO DB)
        sign_up(first_name: user_first_name, last_name: user_last_name)
        
    }
    
    func sign_up(first_name:String, last_name:String) {
    
        //URL is defined above
        print("sign_up")
        var request = URLRequest(url: URL(string: URL_SIGNUP)!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        //creating the post parameter by concatenating the keys and values from text field
        let postParameters = [
            "user_fb_id" : userfbid,
            "user_type" : usertype,
            "user_device_id" : user_device_id,
            "user_first_name" : user_first_name,
            "user_last_name" : user_last_name,
            "user_phone" : phone,
            "user_email" : email,
            "user_password" : password,
            "user_join_datetime" : usertime,
            //            "user_avatar" : useravatar
        ]
        let imageData = UIImageJPEGRepresentation(avatarImageView.image!, 0.0)
        
        request.httpBody = createBody(parameters: postParameters,
                                boundary: boundary,
                                data: imageData!,
                                mimeType: "image/jpg",
                                filename: useravatar)
        
        let fileName = useravatar
        //        let mimetype = "image/jpg"
        //        let fieldName = "user_avatar1"
        //
        //
        //
        ////        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //
        //
        //        //GET IMAGE DATA
        ////        let avatarImageData = imageDataKey
        //
        ////        request.httpBody = createBodyWithParameters(parameters: postParameters, filePathKey: "user_avatar", imageDataKey: avatarImageData, boundary: boundary) as Data
        
        
        
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
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        print("body1 is ", body.length)
        //        print("body1 is ", body)
        let stringTest1 = String(data: body as Data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
        //        print("the body1 is ", stringTest1)
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        print("body2 is ", body.length)
        //        print("body2 is ", body)
        let stringTest2 = String(data: body as Data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
        //        print("the body2 is ", stringTest2)
        
        body.appendString(boundaryPrefix)
        //        body.appendString("Content-Disposition: form-data; name=\"user_avatar\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Disposition: form-data; name=\"user_avatar\"\r\n\r\n")
        //        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        
        print("body3 is ", body.length)
        //        print("body3 is ", body)
        let stringTest3 = String(data: body as Data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
        print("the body3 is ", stringTest3)
        
        body.appendString("testimage.jpg\r\n")
        
        //        body.append(data)
        //        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        print("body4 is ", body.length)
        //        print("body4 is ", body)
        let stringTest4 = String(data: body as Data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
        print("the body4 is ", stringTest4)
        
        return body as Data
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
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
extension NSMutableData{
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

