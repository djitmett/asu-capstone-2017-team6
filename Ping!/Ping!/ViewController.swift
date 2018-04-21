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
import Kingfisher

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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var userPhoneNumber = ""
    
    let defaults = UserDefaults.standard
    
    //Spinner view variable
    var sv : UIView!
    
    //MAP DISPLAY
    @IBOutlet var line1Label: UILabel!
    @IBOutlet var line2Label: UILabel!
    @IBOutlet var line3Label: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var requestLabel: UILabel!
    @IBOutlet var phoneNumField: UITextField!
    @IBOutlet var requestBtn: UIButton!
    @IBOutlet weak var pingBtn: UIButton!
    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    
    var mapUpdateTimer: Timer!
    var mapLoadTimer: Timer!
    
    var lastPhone: String! = ""
    let defualtAvatar = UIImage(named: "default_avatar")
    
    let manager = CLLocationManager()
    let trackingRequestDataManager = TrackingRequstDataManager()
    
    // let appDelegate = UIApplication.shared.delegate! as! AppDelegate
    
    let appDelegate =  AppDelegate.appDelegate
    
    var player_id = ""
    var autoRepositionMap = true as Bool
    
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
                //print("Update location in DB")
                updateUserLocation(userPhone:userPhoneNumber,latitude:location.coordinate.latitude,longitude:location.coordinate.longitude)
                lastUpdateTime = DispatchTime.now()
            }
            
        } else {
            print("Could not get userPhone")
        }
    }
    @IBOutlet weak var retrievedImg: UIImageView!
    
    //redirect from login
    @IBAction func unwindSegueToMap(segue:UIStoryboardSegue) {
        
    }
    
    
    @IBAction func refreshMap(_ sender: Any) {
        TrkRequestMainViewController().getRequestFrom(phone_number: self.userPhoneNumber) { (success) -> Void in
            
        }
        
        updateMap()
        
    }
    
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        
        //Map Display Type Settings
        if (defaults.object(forKey: "mapType") != nil) {
            let mapType = (defaults.object(forKey: "mapType") as? String)!
            if(mapType == "hybrid"){
                mapView.mapType = .hybrid
            }
            if(mapType == "satellite"){
                mapView.mapType = .satellite
            }
            if(mapType == "standard"){
                mapView.mapType = .standard
            }
        }
        else {
            defaults.set("standard", forKey: "mapType")
            defaults.synchronize()
            mapView.mapType = .standard
        }
        
        //Map Interval Settings
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSettings()
        TrkRequestMainViewController().getRequestFrom(phone_number: self.userPhoneNumber) { (success) -> Void in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSettings()
        
        let defaults = UserDefaults.standard
        
        //Create spinner view
        // sv = UIViewController.displaySpinner(onView: self.view)
        
        //Map
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        self.mapView.delegate = self
        autoRepositionMap = true
        
        //USER DEFAULTS FOR ONESIGNAL ID
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
        
        //Ping! Button
        pingBtn.setFAIcon(icon: .FAMapMarker, iconSize: 50, forState: .normal)
        //Menu Button
        menuBtn.setFAIcon(icon: .FABars, iconSize: 20)
        //Refresh Button
        refreshBtn.setFAIcon(icon: .FARefresh, iconSize: 20)
        
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
        
        //        trackingRequestDataManager.loadTrackingRequestData(phone_number: "1212") { (success) -> Void in
        //            print("TrackingRequstDataManager.update Complete!")
        //        }
        
        // If currently tracking a user, show their location, otherwise show user's current location on map.
        //print("update map start")
        
        //let defaults = UserDefaults.standard
        //if (defaults.object(forKey: "currentTrackedUser") != nil) && ((defaults.object(forKey: "currentTrackedUser") as? String)! != ""){
        if (tracking.count > 0){
            self.mapView.showsUserLocation=true
            //let allAnnotations = mapDisplay.annotations
            //self.mapDisplay.removeAnnotations(allAnnotations)
            //let currentTrackedUser = (defaults.object(forKey: "currentTrackedUser") as? String)!
            for req in tracking{
                //print("Updating:"+req.getReq_from_user_phone())
                getLocationFromPhone(phone_number: req.getReq_from_user_phone()){(lat, long, lastUpdate) in
                    let myLocUpdate = self.convertGmtToLocal(date:lastUpdate)
                    self.updateMap2(phone_number: req.getReq_from_user_phone(), latitude: lat, longitude: long, locUpdate: myLocUpdate)
                }
                // For same user, load history data
                getHistoryByPhone(phone_number: req.getReq_from_user_phone()){(history) in
                    // TODO: Show breadcrumbs on map. For now, just printing history data
                    var i = 0 as Int
                    var points = [CLLocationCoordinate2D]()
                    var history_days = -7
                    let current_date = Date()
                    //Declare number of days to go back
                    //Will be replaced by a user defaults selection made in settings
                    if (self.defaults.object(forKey: "breadHistory") != nil) {
                        history_days = (self.defaults.object(forKey: "breadHistory") as? Int)!
                    }
                    else {
                        self.defaults.set(-7, forKey: "breadHistory")
                        self.defaults.synchronize()
                        history_days = -7
                    }
                    
                    //Determine starting point of history
                    let history_limit = (Calendar.current.date(byAdding: .day, value: history_days, to: current_date))
                    //Debug
                    print("History: Today's date is ", current_date)
                    print("History: Breadcrumbs will only go as far as: ", history_limit!)
                    
                    for h in history{
                        //Converting string to date object
                        let history_data = h.history_Location_datetime.toDate(dateFormat:"yyyy-MM-dd HH:mm:ss zz")
                        //Add to array if within limit
                        if (history_data > history_limit!) {
                            let myLoc = CLLocationCoordinate2D(latitude:Double(h.history_Location_latitude)!, longitude:Double(h.history_Location_longitude)!)
                            points.append(myLoc)
                            i = i + 1
                        }
                    }
                    //TODO: Check if user has enabled breadcrumbs
                    if (self.defaults.object(forKey: "breadcrumbs") != nil) {
                        let state = (self.defaults.object(forKey: "breadcrumbs") as? String)!
                        print("Breadcrumb state ", state)
                        if(state == "on"){
                            if(points.count > 0) {
                                let myPolyline = MKPolyline(coordinates: points, count: i)
                                myPolyline.title = req.getReq_from_user_phone()
                                print("PolyLine Title:" +  myPolyline.title!)
                                self.mapView.add(myPolyline)
                            }
                        }
                        else{
                            let myPolyline = MKPolyline(coordinates: points, count: i)
                            let overlays = self.mapView.overlays
                            self.mapView.removeOverlays(overlays)
                            self.mapView.remove(myPolyline)
                            
                        }
                    }
                    else {
                        self.defaults.set("on", forKey: "breadcrumbs")
                        self.defaults.synchronize()
                        if(points.count > 0) {
                            let myPolyline = MKPolyline(coordinates: points, count: i)
                            myPolyline.title = req.getReq_from_user_phone()
                            self.mapView.add(myPolyline)
                        }
                    }
                }
            }
            // remove any unreferenced annotations
            var i=0 as Int
            while (i < mapView.annotations.count){
                let ann = mapView.annotations[i]
                var x=0 as Int
                var deleteMe = true as Bool
                while (x < tracking.count){
                    if ((ann.title as! String).contains(tracking[x].getReq_from_user_phone())){
                        deleteMe = false
                    }
                    let expire =  tracking[x].getReq_expire_datetime()
                    if(expire != "indefinite") {
                        let expireDate = expire.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss zz")
                        if (expireDate < Date()) {
                            deleteMe = true
                            print("reached expired time")
                            let id = tracking[x].getReq_ID()
                            TrkRequestMainViewController().updateRequestByID(req: id, table:1)
                            tracking.remove(at: x)
                        }
                    }
                    else {
                        //convert expiration coords into double
                        let expire_lat = Double(tracking[x].getReq_expire_location_latitude())
                        let expire_long = Double(tracking[x].getReq_expire_location_longitude())
                        //If the current location of the annotation is equal to the end destination
                        if (ann.coordinate.longitude == expire_long  && ann.coordinate.latitude == expire_lat) {
                            deleteMe = true
                            print("reached expired location")
                            let id = tracking[x].getReq_ID()
                            //Update DB to set status of that request as "EXPIRED" and remove it from the array
                            TrkRequestMainViewController().updateRequestByID(req: id, table:1)
                            tracking.remove(at: x)
                        }
                    }
                    x = x + 1
                }
                if (deleteMe){
                    //print("Removing Title=" + (ann.title as! String))
                    self.mapView.removeAnnotation(ann)
                    let title = ann.title
                    let overlays = self.mapView.overlays
                    for overlay in overlays
                    {
                        if overlay.title! == title
                        {
                            self.mapView.remove(overlay)
                            autoRepositionMap = true
                        }
                    }

                }
                i = i + 1
            }
            // find min/max lat/long
            //Top Left Coords
            var topLeftLat = -90.0 as Double
            var topLeftLong = 180.0  as Double
            
            //Bottom Right Coords
            var bottomRightLong = -180.0 as Double
            var bottomRightLat = 90.0  as Double
            
            for ann in mapView.annotations{
                if (ann.coordinate.longitude < topLeftLong){
                    topLeftLong = ann.coordinate.longitude
                }
                if (ann.coordinate.longitude > bottomRightLong){
                    bottomRightLong = ann.coordinate.longitude
                }
                if (ann.coordinate.latitude < bottomRightLat){
                    bottomRightLat = ann.coordinate.latitude
                }
                if (ann.coordinate.latitude > topLeftLat){
                    topLeftLat = ann.coordinate.latitude
                }
                
            }
            //print(String(format:"MinLong=%f MaxLong=%f MinLat=%f MaxLat=%f", topLeftLong, bottomRightLong, bottomRightLat, topLeftLat))
            // Based on min/max lat/long, zoom map
            if (autoRepositionMap){
                if (topLeftLong != 180 || bottomRightLong != -180 || bottomRightLat != 90 || topLeftLat != -90){
                    var region: MKCoordinateRegion = MKCoordinateRegion()
                    region.center.latitude = topLeftLat - (topLeftLat - bottomRightLat) * 0.5
                    region.center.longitude = topLeftLong + (bottomRightLong - topLeftLong) * 0.5
                    region.span.latitudeDelta = fabs(topLeftLat - bottomRightLat) * 1.4
                    region.span.longitudeDelta = fabs(bottomRightLong - topLeftLong) * 1.4
                    region = mapView.regionThatFits(region)
                    mapView.setRegion(region, animated: true)
                }
            }
            
        } else {
            var i = 0
            while (i < mapView.annotations.count){
                let ann = mapView.annotations[i]
                var x=0 as Int
                var deleteMe = true as Bool
                while (x < tracking.count){
                    if (!(ann.title as! String).contains(tracking[x].getReq_from_user_phone())){
                        deleteMe = false
                    }
                     x = x + 1
                }
                if (deleteMe){
                    //print("Removing Title=" + (ann.title as! String))
                    self.mapView.removeAnnotation(ann)
                    self.mapView.removeAnnotation(ann)
                    let title = ann.title
                    let overlays = self.mapView.overlays
                    for overlay in overlays
                    {
                        if overlay.title! == title
                        {
                            self.mapView.remove(overlay)
                            autoRepositionMap = true
                        }
                    }

                }
                i = i + 1
            }
                    
            // Show current user's current location
            let currLoc = manager.location
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            let timeStamp = Date()
            
            //BREAK POINT IF USER DOESN'T ALLOW USER LOCATIONS
            
            //if not tracking anyone, show user's location:
            if(currLoc != nil) {
                self.updateMap2(phone_number: "Self", latitude: (currLoc?.coordinate.latitude)!, longitude: (currLoc?.coordinate.longitude)!, locUpdate: dateFormatter.string(from: timeStamp))
            }
            else {
                //NO DATA TO SEND
                //Remove spinner view after labels have been updated
                // UIViewController.removeSpinner(spinner: sv)
                
                //removed the following to prevent pin from showing self
                //                self.updateMap2(phone_number: "Self", latitude: (currLoc?.coordinate.latitude)!, longitude: (currLoc?.coordinate.longitude)!, locUpdate: dateFormatter.string(from: timeStamp))
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
        
        var newAnnotation = true as Bool
        var i=0 as Int
        while (i < mapView.annotations.count){
            let ann = mapView.annotations[i]
            //print("Title=" + (ann.title as! String) + " Phone=" + phone_number)
            if ((ann.title as! String).contains(phone_number)){
                //print("Removing Title=" + (ann.title as! String) + " Phone=" + phone_number)
                self.mapView.removeAnnotation(ann)
                newAnnotation = false
            }
            i = i + 1
        }
        // If this is a new tracking request, reset autoreposition
        if (newAnnotation){
            autoRepositionMap = true
        }
        
        
        //        var annotation = MKPointAnnotation()
        //        annotation.coordinate = myLocation
        //        annotation.title = phone_number
        //        mapView.addAnnotation(annotation)
        
        
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
        
        //remove +0.002 from final code. offest in place for testing self messages. Leave in place for testing callouts later
        //        let user = UserAnnotation(name:phone_number, lat: latitude, long:(longitude + 0.002))
        loadData(phone_number: phone_number)
        if ImageCache.default.retrieveImageInDiskCache(forKey: phone_number) != nil{
            let user = UserAnnotation(phone:phone_number, lat: latitude, long:longitude, avatarImage: ImageCache.default.retrieveImageInDiskCache(forKey: phone_number)!)
            mapView.addAnnotation(user)
        }
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
                                    ImageCache.default.store(decodedImage, forKey: phone_number)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? UserAnnotation{
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            imageView.image = ImageCache.default.retrieveImageInDiskCache(forKey: annotation.title!)
            imageView.layer.cornerRadius = imageView.layer.frame.size.width / 2
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 5
            imageView.layer.borderColor = UIColor.white.cgColor
            //                imageView.isUserInteractionEnabled = false
            view.addSubview(imageView)
            view.isUserInteractionEnabled = true
            view.isEnabled = true
            view.canShowCallout = true
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if (!animated){
            autoRepositionMap = false
        }
    }
    
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return nil
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(false)
        autoRepositionMap = true
    }
    
    public func getHistoryByPhone(phone_number: String, completion: @escaping (_ history: [HistoryData]) -> ()) {
        let requestURL = "http://52.42.38.63/ioswebservice/api/gethistorybyphone.php?"
        let postParameters = "user_phone=" + (phone_number)
        var request = URLRequest(url: URL(string: requestURL+postParameters)!)
        var myHistory = [HistoryData] ()
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
                            if(msg == "Operation successful!"){
                                data = parseJSON["data"] as! NSArray?
                                for history in data{
                                    let element = history as! NSArray
                                    // Define variables for tracking request
                                    var myLocation_ID : Int
                                    var myLocation_user_id : Int
                                    var myLocation_latitude : String
                                    var myLocation_longitude : String
                                    var myLocation_datetime : String
                                    var myLocation_user_phone : String
                                    
                                    myLocation_ID = (element[0] as? Int)!
                                    myLocation_user_id = (element[1] as? Int)!
                                    myLocation_latitude = (element[2] as? String)!
                                    myLocation_longitude = (element[3] as? String)!
                                    myLocation_datetime = (element[4] as? String)!
                                    myLocation_user_phone = (element[5] as? String)!
                                    
                                    let hd = HistoryData(history_Location_ID: myLocation_ID, history_Location_user_id: myLocation_user_id, history_Location_latitude: myLocation_latitude, history_Location_longitude: myLocation_longitude, history_Location_datetime: myLocation_datetime, history_Location_user_phone: myLocation_user_phone)
                                    
                                    myHistory.append(hd)
                                }
                            } else {
                                //pendRequest.append("No Requests")
                            }
                            
                        }
                        
                        //  print(self.allRequests)
                    } catch {
                        print(error)
                    }
                    
                }
                completion(myHistory)
            }
        })
        task.resume()
        
        //return pendRequest
    }
    
}

class HistoryData{
    var history_Location_ID : Int
    var history_Location_user_id : Int
    var history_Location_latitude : String
    var history_Location_longitude : String
    var history_Location_datetime : String
    var history_Location_user_phone : String
    
    init (history_Location_ID: Int, history_Location_user_id: Int, history_Location_latitude: String, history_Location_longitude: String, history_Location_datetime: String, history_Location_user_phone: String) {
        self.history_Location_ID = history_Location_ID
        self.history_Location_user_id = history_Location_user_id
        self.history_Location_latitude = history_Location_latitude
        self.history_Location_longitude = history_Location_longitude
        self.history_Location_datetime = history_Location_datetime
        self.history_Location_user_phone = history_Location_user_phone
    }
}

