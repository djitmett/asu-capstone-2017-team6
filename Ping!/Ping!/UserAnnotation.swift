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
    //tile is the user's phone number
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var image: UIImage
    init (phone:String, lat: CLLocationDegrees, long:CLLocationDegrees, avatarImage: UIImage){
        self.title = phone
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
        self.userLocals += [UserAnnotation(phone: object.phoneNumber, lat: object.latitude, long: object.longitude, avatarImage: object.avatar!)]
    }
    func addToList(object: User){
        if !self.userLocals.contains(where: { $0.title == object.phoneNumber}){
                self.userLocals += [UserAnnotation(phone: object.phoneNumber, lat: object.latitude, long: object.longitude, avatarImage: object.avatar!)]
            print("Annotation added")
        } else {
            print("Annotation not added")
            printList()
        }
    }
    func getUserLocals() -> [UserAnnotation]{
        return self.userLocals
    }
    func printList(){
        print("UserLocals is count " ,userLocals.count)
    }
}
