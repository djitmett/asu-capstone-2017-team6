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
    //tile is the user's name, can be changed later
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var image: UIImage
    init (name:String, lat: CLLocationDegrees, long:CLLocationDegrees, avatarImage: UIImage){
        self.title = name
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.image = avatarImage
    }
    
}
