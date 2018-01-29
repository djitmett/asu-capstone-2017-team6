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
    var email = "email@test.com"
    var phone = "180012345678"
    var password = "password"
    var useravatar = "avatar.jpeg"

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        var firstName = ""
        var lastName = ""
        var phoneNumber = ""
        var email = ""
        
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
            email = (defaults.object(forKey: "userEmail") as? String)!
        }
        if (defaults.object(forKey: "userPassword") != nil) {
            password = (defaults.object(forKey: "userPassword") as? String)!
        }
        
        FirstNameTextField.resignFirstResponder()
        LastNameTextField.resignFirstResponder()
        PhoneNumberTextField.resignFirstResponder()
        EmailTextField.resignFirstResponder()
        PasswordTextField.resignFirstResponder()
        RepeatPasswordTextField.resignFirstResponder()
        
        self.FirstNameTextField.text = firstName
        self.LastNameTextField.text = lastName
        self.PhoneNumberTextField.text = phoneNumber
        self.EmailTextField.text = email
        


        // Do any additional setup after loading the view.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
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
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        //let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        //imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        //imagePickerController.delegate = self
        //present(imagePickerController, animated: true, completion: nil)
        
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
    }
    
    //MARK: UIImagePickerControllerDelegate
    //func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
      //  dismiss(animated: true, completion: nil)
    //}
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //AvatarImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil)
        
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
       guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        AvatarImageView.image = selectedImage
        
        // Dismiss the picker.
        self.dismiss(animated: true, completion: nil)
    }
    
    
   
    
    

}
