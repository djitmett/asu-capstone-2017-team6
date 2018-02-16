//
//  UserAnnotation.swift
//  
//
//  Created by Corey Rakes on 2/13/18.
//

import Foundation
import UIKit
import MapKit

class UserAnnotation: NSObject, MKAnnotation {
    var identifier = "user"
    var title: String?
    var coordinate: CLLocationCoordinate2D
    init (name:String, lat: CLLocationDegrees, long:CLLocationDegrees){
        title = name
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
}
