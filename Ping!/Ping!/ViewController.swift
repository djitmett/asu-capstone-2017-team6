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
import OneSignal

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
   
    var player_id = ""
    
    //MAP DISPLAY
    @IBOutlet var longLabel: UILabel!
    @IBOutlet var latLabel: UILabel!
    @IBOutlet var mapDisplay: MKMapView!
    @IBOutlet var requestLabel: UILabel!
    @IBOutlet var phoneNumField: UITextField!
    @IBOutlet var requestBtn: UIButton!
    
    let manager = CLLocationManager()
    var lastUpdateTime = DispatchTime.now()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Get most recent location
        let location = locations[0]

        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        
        mapDisplay.showAnnotations(mapDisplay.annotations, animated: true)
        
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapDisplay.setRegion(region, animated:true)
        
        mapDisplay.centerCoordinate = location.coordinate
        
        //Prints user's speed to console
        //print(location.speed)
        
        //Get user's phone number entered from signup
        let defaults = UserDefaults.standard
        //print("Getting userPhone@", Date())
        if (defaults.object(forKey: "userPhone") != nil){
            let userPhoneNumber = (defaults.object(forKey: "userPhone") as? String)!
            
            // Update user's location in DB every 30 seconds
            let start = lastUpdateTime
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let elapsedTime = Double(nanoTime)/1_000_000_000
            if (elapsedTime > 30){
                print("Update location in DB")
                updateUserLocation(userPhone:userPhoneNumber,latitude:location.coordinate.latitude,longitude:location.coordinate.longitude)
                lastUpdateTime = DispatchTime.now()
            }
            
            //Lat Label
            self.latLabel.text = String(location.coordinate.latitude)
            //Long Label
            self.longLabel.text = String(location.coordinate.longitude)
           
            //Display traffic colors on map
            mapDisplay.showsTraffic=true
            
            //print(location.coordinate.latitude)
            //print(location.coordinate.longitude)
        } else {
            print("Could not get userPhone")
        }

    }
    @IBOutlet weak var retrievedImg: UIImageView!
    
    //redirect from login
    @IBAction func unwindSegueToMap(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Map
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Displays user's location
        self.mapDisplay.showsUserLocation=true
        
        //USER DEFAULTS FOR ONESIGNAL ID
        let defaults = UserDefaults.standard
        player_id = (defaults.object(forKey: "GT_PLAYER_ID_LAST") as? String)!
        
        //print player id
        //print("player_id: " + player_id)
        
        //Avatar image
        if let imgData = UserDefaults.standard.object(forKey: "myImageKey") as? NSData {
             retrievedImg.image = UIImage(data: imgData as Data)
        }
        
    }
    
    func updateUserLocation(userPhone:String, latitude:Double, longitude:Double) {
        //DATABASE PHP SCRIPT
        let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/adduserlocation.php?"
        
        //52.42.38.63/ioswebservice/api/adduserlocation.php?user_phone=1234567890&location_latitude=35.7020691&location_longitude=139.7753269&location_datetime=2017-11-18 01:31:06
        
        let requestURL = NSURL(string: URL_SIGNUP)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        
        //Othe
        var postParameters = "user_phone=" + userPhone
        postParameters += "&location_latitude=\(latitude)"
        postParameters += "&location_longitude=\(longitude)"
        postParameters += "&location_datetime=\(NSDate())"
        //print("PostParms=" + postParameters)
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
                    //print("MESSAGE=" + msg)
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

