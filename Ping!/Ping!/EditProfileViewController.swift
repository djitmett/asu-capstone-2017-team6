//
//  EditProfileViewController.swift
//  Ping!
//
//  Created by Nathan Waitman on 1/28/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//
// creating branch

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
    var repeatpassword = "password"
    var useravatar = "avatar.jpeg"
    var usertime = "test"
    
    let defaults = UserDefaults.standard
    
    let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/updateuserdata.php?"
    
   // @IBAction func doneButtonTapped(_ sender: Any) {
    //    let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileController") as! ProfileController
   //     self.navigationController?.pushViewController(nextViewController, animated: true)
        //self.present(nextViewController, animated:true, completion:nil)
        
    //}
    
    @IBAction func ChangeAvatarTapped(_ sender: Any) {
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
        
        //DOESN'T WORK YET
        //Save image
        //let img = AvatarImageView.image
        //let data = UIImagePNGRepresentation(img!)
        //UserDefaults.standard.set(data, forKey: "myImageKey")
        //UserDefaults.standard.synchronize()
        
    }
    
    @IBAction func SaveButtonTapped(_ sender: Any) {
        
        //OneSignal player_id as user_device_id for now
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "GT_PLAYER_ID_LAST") != nil) {
            user_device_id = (defaults.object(forKey: "GT_PLAYER_ID_LAST") as? String)!
        }
        
        //DB Variables
        user_first_name = FirstNameTextField.text!
        user_last_name = LastNameTextField.text!
        phone = PhoneNumberTextField.text!
        email = EmailTextField.text!
        password = PasswordTextField.text!
        repeatpassword = RepeatPasswordTextField.text!
        
        if (user_first_name != "" &&
            user_last_name != "" &&
            phone != "" &&
            email != "" &&
            password != "") {
        
            if (repeatpassword == password) {
            
                //Store values in UserDefaults TODO: Commented out for now to stop sign out on
                defaults.set(user_first_name, forKey: "userFirstName")
                defaults.set(user_last_name, forKey: "userLastName")
                defaults.set(phone, forKey: "userPhone")
                defaults.set(email, forKey: "userEmail")
                defaults.set(password, forKey: "userPassword")
                defaults.set(true, forKey: "isLogged")
                defaults.synchronize()
        
                //CALL THE EDIT FUNCTION (SEND DATA TO DB)
                edit(first_name: user_first_name, last_name: user_last_name,
                     phone_num: phone, user_email: email, user_password: password)
               
                let alert = UIAlertController(title: "Confirmation", message: "Your profile information has been saved.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            else {
                let alert = UIAlertController(title: "Error", message: "Passwords don't match.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func edit(first_name:String, last_name:String, phone_num:String, user_email:String,
              user_password:String) {
        
        print("edit")
        //let postParameters = "user_fb_id=84&user_device_id=12345&user_type=changed&user_first_name=testfirst1&user_last_name=testlast1&user_phone=12345&user_email=TestEmail&user_password=testpass&user_avatar=none&user_join_datetime=nodatetime";
        
        //URL is defined above
        let requestURL = NSURL(string: URL_SIGNUP)
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //setting the method to post
        request.httpMethod = "POST"
        
        // Encode avatar image for saving in DB
        let imageData = UIImagePNGRepresentation(AvatarImageView.image!)
        var encodedAvatar = imageData?.base64EncodedString(options: .lineLength64Characters)
        let customAllowedSet = NSCharacterSet(charactersIn:"+").inverted
        encodedAvatar = encodedAvatar?.addingPercentEncoding(withAllowedCharacters:customAllowedSet as CharacterSet)!
        //print (encodedAvatar)
        //creating the post parameter by concatenating the keys and values from text field
        var postParameters = "user_fb_id= " + userfbid
        postParameters += "&user_type=" + usertype
        postParameters += "&user_device_id=" + user_device_id
        postParameters += "&user_first_name=" + first_name
        postParameters += "&user_last_name=" + last_name
        postParameters += "&user_phone=" + phone_num
        postParameters += "&user_email=" + user_email
        postParameters += "&user_password=" + user_password
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
        //print(postParameters)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        AvatarImageView.image = resizeImage(image: selectedImage, targetSize: CGSize.init(width:124,height:124))
        // Dismiss the picker.
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        
        //Text field delegation
        FirstNameTextField.delegate = self
        LastNameTextField.delegate = self
        PhoneNumberTextField.delegate = self
        EmailTextField.delegate = self
        PasswordTextField.delegate = self
        RepeatPasswordTextField.delegate = self
        self.hideKeyboard()
        
        var firstName = ""
        var lastName = ""
        var phoneNumber = ""
        var emailAddress = ""
        var myPassword = ""
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
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
        self.RepeatPasswordTextField.text = myPassword
        
        loadData(phone_number:phoneNumber)
        
        self.AvatarImageView.layer.cornerRadius = self.AvatarImageView.frame.size.width / 2;
        self.AvatarImageView.clipsToBounds = true;
        
        // Do any additional setup after loading the view.
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
    
    //Validate login with database
    func loadData(phone_number:String) {
        
        //DATABASE PHP SCRIPT
        let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/getuserdata.php?"
        //URL is defined above
        let requestURL = NSURL(string: URL_SIGNUP)
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        //setting the method to post
        request.httpMethod = "POST"
        //creating the post parameter by concatenating the keys and values from text field
        let postParameters = "user_phone="+phone_number;
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
                    var myData : NSArray!
                    //getting the json response
                    msg = parseJSON["message"] as! String?
                    //printing the response
                    //print(msg)
                    //If phonenumber exists in DB
                    if(msg == "Operation successfully!"){
                        myData = parseJSON["data"] as! NSArray?
                        // TODO: load DB info into text fields
                        //let db_password = myData[5] as? String
                        //let user_first_name = myData[2] as? String
                        //let user_last_name = myData[3] as? String
                        let encodedAvatar = myData[7] as? String
                        //print (encodedAvatar!)
                        if (encodedAvatar != nil) {
                            if (encodedAvatar! != "testimage.jpg") {
                                let dataDecoded : Data = Data(base64Encoded: encodedAvatar!, options: .ignoreUnknownCharacters)!
                                let decodedImage = UIImage(data: dataDecoded)!
                                  DispatchQueue.main.async {
                                    self.AvatarImageView.image = decodedImage
                                }
                            }
                        }
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
}


//override func viewWillDisappear(animated: Bool) {
 //   let SideMenuTableController = ViewController(nibNameOrNil: NibName, bundleOrNil: nil)
   // self.EditProfileViewController(SideMenuTableController, animated: true, completion: nil)
//}


extension UIViewController {
    @objc func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


