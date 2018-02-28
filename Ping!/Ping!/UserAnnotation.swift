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
class UserAnnotationList: NSObject {
    var userLocals = [UserAnnotation]()
    override init() {
        //
    }
    
    init(object: User) {
        self.userLocals += [UserAnnotation(name: object.firstName, lat: object.latitude, long: object.longitude, avatarImage: object.avatar!)]
    }
    func addToList(object: User){
        self.userLocals += [UserAnnotation(name: object.firstName, lat: object.latitude, long: object.longitude, avatarImage: object.avatar!)]
    }
    func getUserLocals() -> [UserAnnotation]{
        return self.userLocals
    }
    func printList(){
        print("UserLocals is count " ,userLocals.count)
    }
}
