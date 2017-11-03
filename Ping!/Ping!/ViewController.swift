//
//  ViewController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 10/19/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    //DB TEST DISPLAY VARS
    @IBOutlet weak var first_name: UITextField!
    @IBOutlet weak var last_name: UITextField!
    @IBOutlet weak var helloName: UILabel!
    
    //INIT FIRST NAME LAST NAME TEXT FIELDS
    var user_first_name = "First Name"
    var user_last_name = "Last Name"
    
    //DATABASE PHP SCRIPT
    let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/adduser.php"
    
    @IBAction func signupBtn(_ sender: Any) {
         user_first_name = first_name.text!
         user_last_name = last_name.text!
        
        //CALL THE SIGN UP FUNCTION (SEND DATA TO DB)
        sign_up(first_name: user_first_name, last_name: user_last_name)
        
        //TESTING  NAME IS BEING GRABBED
        helloName.text = user_first_name + " " + user_last_name
    }
    
    func sign_up(first_name:String, last_name:String) {
        
        //URL is defined above
        let requestURL = NSURL(string: URL_SIGNUP)
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //setting the method to post
        request.httpMethod = "POST"
        
        //Other DB values
        let usertype = "user"
        let email = "email@test.com"
        let password = "password"
        let useravatar = "avatar.jpeg"
        let usertime = "2017-11-01 21:34:12"
        
        //creating the post parameter by concatenating the keys and values from text field
        let postParameters = "user="+usertype+"&user_first_name="+first_name+"&user_last_name="+last_name+"&user_email="+email+"&user_password="+password+"&user_avatar="+useravatar+"&user_join_datetime="+usertime;
        
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
        print(postParameters)
    }

    
    
    //MAP DISPLAY
    @IBOutlet var longLabel: UILabel!
    @IBOutlet var latLabel: UILabel!
    @IBOutlet var mapDisplay: MKMapView!
    @IBOutlet var requestLabel: UILabel!
    @IBOutlet var phoneNumField: UITextField!
    @IBOutlet var requestBtn: UIButton!
    
    let manager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]

        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        mapDisplay.centerCoordinate = location.coordinate
        mapDisplay.showAnnotations(mapDisplay.annotations, animated: true)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapDisplay.setRegion(region, animated:true)
        
        print(location.speed)
        
        self.mapDisplay.showsUserLocation=true
        
        self.latLabel.text = String(location.coordinate.latitude)
        
        self.longLabel.text = String(location.coordinate.longitude)
        mapDisplay.showsTraffic=true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        //manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }
    /**
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapDisplay.showsUserLocation = true
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
**/


}

