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
   
    
    
    //MAP DISPLAY
    @IBOutlet var longLabel: UILabel!
    @IBOutlet var latLabel: UILabel!
    @IBOutlet var mapDisplay: MKMapView!
    @IBOutlet var requestLabel: UILabel!
    @IBOutlet var phoneNumField: UITextField!
    @IBOutlet var requestBtn: UIButton!
    
    let manager = CLLocationManager()
    
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
        print(location.speed)
        
        //Lat Label
        self.latLabel.text = String(location.coordinate.latitude)
        //Long Label
        self.longLabel.text = String(location.coordinate.longitude)
       
        //Display traffic colors on map
        mapDisplay.showsTraffic=true
        

    }
    @IBOutlet weak var retrievedImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Map
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Displays user's location
        self.mapDisplay.showsUserLocation=true
        
        //print player id
        OneSignal.idsAvailable { (pushID, pushToken) in
            print("OneSignal player_id = " + pushID!)
            //print(pushToken)
        }
        
        OneSignal.getPermissionSubscriptionState()
        
        //Avatar image
        if let imgData = UserDefaults.standard.object(forKey: "myImageKey") as? NSData {
             retrievedImg.image = UIImage(data: imgData as Data)
        }
        
    }
    

}

