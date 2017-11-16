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
        //mapDisplay.centerCoordinate = location.coordinate
        mapDisplay.showAnnotations(mapDisplay.annotations, animated: true)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapDisplay.setRegion(region, animated:true)
        
        //Prints user's speed to console
        print(location.speed)
        
        //Displays user's location
        self.mapDisplay.showsUserLocation=true
        
        //Lat Label
        self.latLabel.text = String(location.coordinate.latitude)
        //Long Label
        self.longLabel.text = String(location.coordinate.longitude)
        //Display traffic colors on map
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

}

