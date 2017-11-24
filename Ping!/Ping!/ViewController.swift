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
    
    //MAP DISPLAY
    @IBOutlet var line1Label: UILabel!
    @IBOutlet var line2Label: UILabel!
    @IBOutlet var line3Label: UILabel!
    @IBOutlet weak var mapDisplay: MKMapView!
    @IBOutlet var requestLabel: UILabel!
    @IBOutlet var phoneNumField: UITextField!
    @IBOutlet var requestBtn: UIButton!
    
    let manager = CLLocationManager()
    
    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
   
    var player_id = ""

    var lastUpdateTime = DispatchTime.now()
    var lastUpdateTime2 = DispatchTime.now()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Get most recent location
        let location = locations[0]

        //let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        //let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        //mapDisplay.setRegion(region, animated:true)
        
        //mapDisplay.centerCoordinate = location.coordinate
        
        //mapDisplay.showAnnotations(mapDisplay.annotations, animated: false)
        
        //Prints user's speed to console
        //print(location.speed)
        
        //Get user's phone number entered from signup
        let defaults = UserDefaults.standard
        //print("Getting userPhone@", Date())
        if (defaults.object(forKey: "userPhone") != nil){
            let userPhoneNumber = (defaults.object(forKey: "userPhone") as? String)!
            
            // Update user's location in DB every 30 seconds
            var start = lastUpdateTime
            var end = DispatchTime.now()
            var nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            var elapsedTime = Double(nanoTime)/1_000_000_000
            if (elapsedTime > 30){
                //print("Update location in DB")
                updateUserLocation(userPhone:userPhoneNumber,latitude:location.coordinate.latitude,longitude:location.coordinate.longitude)
                lastUpdateTime = DispatchTime.now()
            }
            start = lastUpdateTime2
            end = DispatchTime.now()
            nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            elapsedTime = Double(nanoTime)/1_000_000_000
            // ToDo: create a timer to update map and remove from this function
            if (elapsedTime > 5){
                self.updateMap()
                lastUpdateTime2 = DispatchTime.now()
            }
            
            //Lat Label
            //self.latLabel.text = String(location.coordinate.latitude)
            //Long Label
            //self.longLabel.text = String(location.coordinate.longitude)
           
            //Display traffic colors on map
            //mapDisplay.showsTraffic=true
            
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
        //self.mapDisplay.showsUserLocation=true
        
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
    
    func updateMap(){
        // If currently tracking a user, show their location, otherwise show user's current location on map.
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "currentTrackedUser") != nil) && ((defaults.object(forKey: "currentTrackedUser") as? String)! != ""){
            self.mapDisplay.showsUserLocation=false
            let currentTrackedUser = (defaults.object(forKey: "currentTrackedUser") as? String)!
            getLocationFromPhone(phone_number: currentTrackedUser){(lat, long, lastUpdate) in
                self.updateMap2(phone_number: currentTrackedUser, latitude: lat, longitude: long, locUpdate: lastUpdate)
            }
        } else {
            // Show current user's current location
            let currLoc = manager.location
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            let timeStamp = Date()
            
            self.updateMap2(phone_number: "Self", latitude: (currLoc?.coordinate.latitude)!, longitude: (currLoc?.coordinate.longitude)!, locUpdate: dateFormatter.string(from: timeStamp))
        }
    }
    
    func updateMap2(phone_number: String, latitude: Double, longitude: Double, locUpdate:String){
        
        print("LAT=",latitude," LONG=", longitude, " @", locUpdate)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        let allAnnotations = mapDisplay.annotations
        self.mapDisplay.removeAnnotations(allAnnotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = myLocation
        annotation.title = phone_number
        mapDisplay.addAnnotation(annotation)
        
        mapDisplay.setRegion(region, animated:true)
        mapDisplay.centerCoordinate = myLocation
        mapDisplay.showAnnotations(mapDisplay.annotations, animated: false)
        
        self.line1Label.text = String(format: "Tracking user %@ Lat=%.2f Long=%.2f",phone_number, latitude, longitude)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let timeStamp = Date()
        self.line2Label.text = String(format: "Map updated @ %@", dateFormatter.string(from: timeStamp))
        self.line3Label.text = "User loc updated @ " + locUpdate
    }
    
    func getLocationFromPhone(phone_number: String, completion: @escaping (_ trackLat: Double, _ trackLong: Double, _ lastUpdate: String) -> ()) {
        let requestURL = "http://52.42.38.63/ioswebservice/api/getuserlocation.php?"
        let postParameters = "user_phone="+phone_number;
        var lat: Double = 0
        var long: Double = 0
        var lastUpdate: String = ""
        var request = URLRequest(url: URL(string: requestURL+postParameters)!)
        request.httpMethod = "POST"
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request, completionHandler:{
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let error = error {
                    print (error)
                    return
                }
                if let data = data {
                    do {
                        //converting resonse to NSDictionary
                        let myJSON =  try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                        //parsing the json
                        if let parseJSON = myJSON {
                            //creating a string
                            var msg : String!
                            var data : NSArray!
                            //getting the json response
                            msg = parseJSON["message"] as! String?
                            //print("MESSAGE=",msg)
                            if(msg == "Operation successfully!"){
                                data = parseJSON["data"] as! NSArray?
                                let tempLat = (data[0] as? String)!
                                let tempLong = (data[1] as? String)!
                                lat = Double(tempLat)!
                                long = Double(tempLong)!
                                lastUpdate = (data[2] as? String)!
                            } else {
                                lat = -999
                                long = -999
                                lastUpdate = "Update Location N/A"
                            }
                        }
                        completion(lat, long, lastUpdate)
                    } catch {
                        print(error)
                    }
                }
            }
        })
        task.resume()
    }
}

