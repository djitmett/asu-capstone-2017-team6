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

//Loading extension for map loading spinner
/*
 extension UIViewController {
 class func displaySpinner(onView : UIView) -> UIView {
 let spinnerView = UIView.init(frame: onView.bounds)
 spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
 let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
 ai.startAnimating()
 ai.center = spinnerView.center
 
 DispatchQueue.main.async {
 spinnerView.addSubview(ai)
 onView.addSubview(spinnerView)
 }
 
 return spinnerView
 }
 
 
 class func removeSpinner(spinner :UIView) {
 DispatchQueue.main.async {
 spinner.removeFromSuperview()
 }
 }
 }
 */
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var userPhoneNumber = ""
    
    //Spinner view variable
    var sv : UIView!
    
    //MAP DISPLAY
    @IBOutlet var line1Label: UILabel!
    @IBOutlet var line2Label: UILabel!
    @IBOutlet var line3Label: UILabel!
    @IBOutlet var mapDisplay: MKMapView!
    @IBOutlet var requestLabel: UILabel!
    @IBOutlet var phoneNumField: UITextField!
    @IBOutlet var requestBtn: UIButton!
    
    var mapUpdateTimer: Timer!
    var mapLoadTimer: Timer!
    
    var lastPhone: String! = ""
    
    let manager = CLLocationManager()
    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
    var player_id = ""
    
    var lastUpdateTime = DispatchTime.now() - 60 // Force DB update as soon as app loads by changing lastUpdateTime to an arbitrary time
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Get most recent location
        let location = locations[0]
        
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
            
        } else {
            print("Could not get userPhone")
        }
    }
    @IBOutlet weak var retrievedImg: UIImageView!
    
    //redirect from login
    @IBAction func unwindSegueToMap(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Create spinner view
        // sv = UIViewController.displaySpinner(onView: self.view)
        
        //Map
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //USER DEFAULTS FOR ONESIGNAL ID
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "GT_PLAYER_ID_LAST") != nil) {
            player_id = (defaults.object(forKey: "GT_PLAYER_ID_LAST") as? String)!
        }
        else {
            print("NO PLAYER ID CAPTURED")
        }
        //Avatar imaged -- NEEDS TO BE FIXED ; DOES NOT WORK
        //if let imgData = UserDefaults.standard.object(forKey: "myImageKey") as? NSData {
        //   retrievedImg.image = UIImage(data: imgData as Data)
        //}
        
        mapUpdateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateMap), userInfo: nil, repeats: true)
        mapUpdateTimer.fire() // We could use this to show the updated map immediately, but the loading wheel is nice. - JH
        
        //Requests
        if(defaults.object(forKey: "userPhone") != nil){
            userPhoneNumber = (defaults.object(forKey: "userPhone") as? String)!
        }
        //****************
        // Call on getRequestsFrom function in tracking view
        //Populates global arrays
        //****************
        TrkRequestMainViewController().getRequestFrom(phone_number: self.userPhoneNumber) { (success) -> Void in
//            if success {
//                print(pending[0].getReq_from_user_phone())
//                print(pending[0].getReq_to_user_phone())
//                print(pending[0].getReq_status())
//                
//                
//            }
        }
    }
    
    
    func updateUserLocation(userPhone:String, latitude:Double, longitude:Double) {
        //DATABASE PHP SCRIPT
        let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/adduserlocation.php?"
        let requestURL = NSURL(string: URL_SIGNUP)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        
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
    
    @objc func updateMap(){
        // If currently tracking a user, show their location, otherwise show user's current location on map.
        //print("update map start")
        //let defaults = UserDefaults.standard
        //if (defaults.object(forKey: "currentTrackedUser") != nil) && ((defaults.object(forKey: "currentTrackedUser") as? String)! != ""){
        if (tracking.count > 0){
            self.mapDisplay.showsUserLocation=false
            //let allAnnotations = mapDisplay.annotations
            //self.mapDisplay.removeAnnotations(allAnnotations)
            //let currentTrackedUser = (defaults.object(forKey: "currentTrackedUser") as? String)!
            for req in tracking{
                //print("Updating:"+req.getReq_from_user_phone())
                getLocationFromPhone(phone_number: req.getReq_from_user_phone()){(lat, long, lastUpdate) in
                    let myLocUpdate = self.convertGmtToLocal(date:lastUpdate)
                    self.updateMap2(phone_number: req.getReq_from_user_phone(), latitude: lat, longitude: long, locUpdate: myLocUpdate)
                }
            }
            // remove any unreferenced annotations
            var i=0 as Int
            while (i < mapDisplay.annotations.count){
                let ann = mapDisplay.annotations[i]
                var x=0 as Int
                var deleteMe = true as Bool
                while (x < tracking.count){
                    if ((ann.title as! String).contains(tracking[x].getReq_from_user_phone())){
                        deleteMe = false
                    }
                    x = x + 1
                }
                if (deleteMe){
                    //print("Removing Title=" + (ann.title as! String))
                    self.mapDisplay.removeAnnotation(ann)
                }
                i = i + 1
            }
            // find min/max lat/long
            var minLong = 180.0  as Double
            var maxLong = -180.0 as Double
            var minLat = 90.0  as Double
            var maxLat = -90.0 as Double
            for ann in mapDisplay.annotations{
                if (ann.coordinate.longitude < minLong){
                    minLong = ann.coordinate.longitude
                }
                if (ann.coordinate.longitude > maxLong){
                    maxLong = ann.coordinate.longitude
                }
                if (ann.coordinate.latitude < minLat){
                    minLat = ann.coordinate.latitude
                }
                if (ann.coordinate.latitude > maxLat){
                    maxLat = ann.coordinate.latitude
                }
            }
            print(String(format:"MinLong=%f MaxLong=%f MinLat=%f MaxLat=%f", minLong, maxLong, minLat, maxLat))
            // Based on min/max lat/long, zoom map
            //TODO: This code is not working yet! Math is wrong!!
            if (minLong != 180 || maxLong != -180 || minLat != 90 || maxLat != -90){
                var locationSpan = MKCoordinateSpan(latitudeDelta: 0,longitudeDelta: 0)
                locationSpan.latitudeDelta = maxLat - minLat
                locationSpan.longitudeDelta = maxLong - minLong
                var locationCenter = CLLocationCoordinate2D(latitude: 0,longitude: 0)
                locationCenter.latitude = (maxLat - minLat) / 2;
                locationCenter.longitude = (maxLong - minLong) / 2;
                
                var region = mapDisplay.region
                region = MKCoordinateRegionMake(locationCenter, locationSpan)
                mapDisplay.setRegion(region, animated:false)
                mapDisplay.centerCoordinate = locationCenter
            }
            
        } else {
            // Show current user's current location
            let currLoc = manager.location
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            let timeStamp = Date()
            
            //BREAK POINT IF USER DOESN'T ALLOW USER LOCATIONS
            if(currLoc != nil) {
                self.updateMap2(phone_number: "Self", latitude: (currLoc?.coordinate.latitude)!, longitude: (currLoc?.coordinate.longitude)!, locUpdate: dateFormatter.string(from: timeStamp))
            }
            else {
                //NO DATA TO SEND
                //Remove spinner view after labels have been updated
                // UIViewController.removeSpinner(spinner: sv)
                
            }
        }
    }
    
    func updateMap2(phone_number: String, latitude: Double, longitude: Double, locUpdate:String){
        //print("LAT=",latitude," LONG=", longitude, " @", locUpdate)
        //var allAnnotations = mapDisplay.annotations
        //self.mapDisplay.removeAnnotations(allAnnotations)
        
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
//        var region = mapDisplay.region
//        if (phone_number != lastPhone){
//            region = MKCoordinateRegionMake(myLocation, MKCoordinateSpanMake(0.01, 0.01))
//            lastPhone = phone_number
//        } else {
//            region = MKCoordinateRegionMake(myLocation, mapDisplay.region.span)
//        }
        
        var i=0 as Int
        while (i < mapDisplay.annotations.count){
            let ann = mapDisplay.annotations[i]
            //print("Title=" + (ann.title as! String) + " Phone=" + phone_number)
            if ((ann.title as! String).contains(phone_number)){
                //print("Removing Title=" + (ann.title as! String) + " Phone=" + phone_number)
                self.mapDisplay.removeAnnotation(ann)
            }
            i = i + 1
        }
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = myLocation
        annotation.title = phone_number
        mapDisplay.addAnnotation(annotation)
        
        //mapDisplay.setRegion(region, animated:false)
        //mapDisplay.centerCoordinate = myLocation
        //mapDisplay.showAnnotations(mapDisplay.annotations, animated: false)
        
        self.line1Label.text = String(format: "Tracking user %@ Lat=%.2f Long=%.2f",phone_number, latitude, longitude)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let timeStamp = Date()
        self.line2Label.text = String(format: "Map updated @ %@", dateFormatter.string(from: timeStamp))
        //let myLocUpdate = convertGmtToLocal(date:locUpdate)
        self.line3Label.text = "User loc updated @ " + locUpdate
        
        //Remove spinner view after labels have been updated
        //UIViewController.removeSpinner(spinner: sv)
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
    
    func convertGmtToLocal(date:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss SSSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: dt!)
    }
}

