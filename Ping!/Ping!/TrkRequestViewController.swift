//
//  TrkRequestViewController.swift
//  Ping!
//
//  Created by Corey Rakes on 11/17/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit
import OneSignal
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class TrkRequestViewController: UIViewController, UITextFieldDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var destinationInput: UITextField!
    @IBOutlet weak var trackingDurationSwitch: UISwitch!
    @IBOutlet weak var trackingDurationPicker: UIDatePicker!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var timedTrackingLabel: UILabel!
    @IBOutlet weak var indefiniteTrackingLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    //Default geocoords
    var end_long: Double? = 0.00
    var end_lat: Double?  = 0.00
    

    
    @IBAction func sendTracking(_ sender: Any) {
        
        var player_ID = ""
        getPlayerIdFromPhoneNumber(phoneNumber: phoneNumber.text!){(value) in
            player_ID = value
            if !value.isEmpty {
                self.sendTracking2(player_id: player_ID)
                self.reset()
            }
            else{
                print("empty id")
                self.phoneNumber.layer.borderColor = UIColor.red.cgColor
                self.phoneNumber.layer.borderWidth = 1.0
            }
        }
    }
    
    func reset() {
        self.phoneNumber.layer.borderColor = UIColor.gray.cgColor
        self.phoneNumber.layer.borderWidth = 0.0
        self.phoneNumber.text = nil
        self.destinationInput.text = nil
        self.trackingDurationSwitch.isOn = true
        self.trackingDurationPicker.isEnabled = false
        self.indefiniteTrackingLabel.textColor = UIColor.black
        self.timedTrackingLabel.textColor = UIColor.gray
    }
    
    @IBAction func trackingDurationSwitchAction(_ sender: Any) {
        if trackingDurationSwitch.isOn {
            trackingDurationPicker.isEnabled = false
            indefiniteTrackingLabel.textColor = UIColor.black
            timedTrackingLabel.textColor = UIColor.gray
        }
        else {
            trackingDurationPicker.isEnabled = true
            timedTrackingLabel.textColor = UIColor.black
            indefiniteTrackingLabel.textColor = UIColor.gray
        }
    }
    
    @IBAction func enteringDestination(_ sender: Any) {
        resultSearchController.searchBar.delegate = self
        present(resultSearchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Ignore user events
        UIApplication.shared.beginIgnoringInteractionEvents()
        //Activity
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion:nil)
        
        //Search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil{
                print("ERROR")
            }
            else {
                 self.destinationInput.text = searchBar.text
                //self.destinationInput.text = mapView.ann
                
                print(self.mapView.annotations.description)
                
            }
            
        }
    }
    
    //Previous version of obtaining lat & long
    /*
    @IBAction func endDestination(_ sender: UITextField) {
        let geocoder = CLGeocoder()
        let address = destinationInput.text
      
        geocoder.geocodeAddressString(address!) {
            placemarks, error in
            let placemark = placemarks?.first
            self.end_lat = placemark?.location?.coordinate.latitude
            self.end_long = placemark?.location?.coordinate.longitude
            print("Lat: \(self.end_lat ?? 0), Lon: \(self.end_long ?? 0)")
         }
     }
         */
    
    func sendTracking2(player_id:String){
        let defaults = UserDefaults.standard
        var userFirstName = ""
        var phone_number = ""
        
        //Get hour & min set from date picker
        let date = trackingDurationPicker.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour!
        let minute = components.minute!
        
        if (defaults.object(forKey: "userFirstName") != nil) {
            userFirstName = (defaults.object(forKey: "userFirstName") as? String)!
        }
        if (defaults.object(forKey: "userPhone") != nil) {
            phone_number = (defaults.object(forKey: "userPhone") as? String)!
        }
        if (player_id != "INVALID"){
            //print("Valid Number")
        } else {
            //print("Invalid number")
        }
        
        //All OneSignal content is in JSON format
        
        let data = [
            "Phone" : phone_number,
            "End-Location" : [end_lat,end_long],
            "Indefinite" : trackingDurationSwitch.isOn,
            "Duration" : [hour,minute],
            ] as [String : Any]
        
        let message = userFirstName + " would like to share their location with you."
        print("Player_Id=", player_id)
        let notificationContent = [
            "include_player_ids": [player_id],
            "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
            "headings": ["en": "PING! TRACKING"],
            "subtitle": ["en": "Someone has sent you a tracking invitation."],
            "data": data,
            //Shows notification bage on application
            "ios_badgeType": "Increase",
            "ios_badgeCount": 1,
            "buttons": [["id": "reject-button", "text":"Reject"],["id": "accept-button", "text":"Accept" ]]
            ] as [String : Any]
        
        //Send request and receive confirmation
        OneSignal.postNotification(notificationContent, onSuccess: { result in
            print("result = \(result!)")
        }, onFailure: {error in
            print("error = \(error!)")
        })
        
        // Send request to DB
        let requestURL = NSURL(string: "http://52.42.38.63/ioswebservice/api/addrequest.php?")
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        
        //creating the post parameter by concatenating the keys and values
        let fromNumber = phone_number
        let toNumber = phoneNumber.text!
        
        let now = NSDate()
        
        let expireDateTime = Calendar.current.date(byAdding:
                .minute,
                value: hour * 60 + minute,
                to: now as Date)
        
        var postParameters = "req_from_user_phone=\(fromNumber)"
        postParameters += "&req_to_user_phone=\(toNumber)"
        
        if(!trackingDurationSwitch.isOn) {
        postParameters += "&req_expire_datetime=\(expireDateTime!)"
        }
        else {
        postParameters += "&req_expire_datetime=indefinite"
        }
        postParameters += "&req_expire_location_latitude=\(end_lat!)"
        postParameters += "&req_expire_location_longitude=\(end_long!)"
        
        
        print("AddRequest PostParms=" + postParameters)
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
                    var msg : String!
                    msg = parseJSON["message"] as! String?
                    //printing the response
                    //print(msg)
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
        phoneNumber.delegate = self
        destinationInput.delegate = self
        trackingDurationPicker.isEnabled = false
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.handleMapSearchDelegate = self
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        locationSearchTable.handleMapSearchDelegate = self
        locationSearchTable.mapView = mapView
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func getPlayerIdFromPhoneNumber(phoneNumber: String, completion: @escaping (_ retPlayerID: String) -> ()) {
        let requestURL = "http://52.42.38.63/ioswebservice/api/getuserdata.php?"
        let postParameters = "user_phone="+phoneNumber;
        var player_ID: String = ""
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
                                player_ID = (data[1] as? String)!
                                
                                //Display success dialog
                                let successAlert = UIAlertController(title: "Tracking request confirmation", message: "Request sent successfully!", preferredStyle: UIAlertControllerStyle.alert)
                                successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                                    
                                    //action code
                                    
                                }))
                                self.present(successAlert, animated: true, completion: nil)
                            } else if(msg == "User does not exist!"){
                                player_ID = "INVALID"
                                let failAlert = UIAlertController(title: "Tracking request confirmation", message: "Request failed! User does not exist.", preferredStyle: UIAlertControllerStyle.alert)
                                failAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                                    
                                    //action code
                                    
                                }))
                                self.present(failAlert, animated: true, completion: nil)
                            }
                        }
                        completion(player_ID)
                    } catch {
                        print(error)
                    }
                }
            }
        })
        task.resume()
        
        
    }
    
}
extension TrkRequestViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
}

extension TrkRequestViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        //Construct address
        var addressLine = "\(placemark.subThoroughfare!) "
        addressLine += "\(placemark.thoroughfare!), "
        addressLine += "\(placemark.locality!) "
        addressLine += "\(placemark.administrativeArea!)"
        
        //Update variables based on cell selection
        destinationInput.text = addressLine
        end_lat = annotation.coordinate.latitude
        end_long = annotation.coordinate.longitude
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
        print(selectedItem.coordinate.latitude)
        print(selectedItem.coordinate.longitude)
    }
}


