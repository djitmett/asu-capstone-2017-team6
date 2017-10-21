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

