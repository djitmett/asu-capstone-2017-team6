//
//  User.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 11/16/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//

import UIKit

class User {

    //MARK: Properties
    var firstName : String
    var lastName : String
    var phoneNumber : String
    var password: String
    var avatar : UIImage?
    var latitude : Double
    var longitude : Double
    
    init?(firstName:String, lastName:String, phoneNumber:String, password:String, avatar:UIImage?, latitude: Double, longitude: Double){
        
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.password = password
        self.avatar = avatar
        self.latitude = latitude
        self.longitude = longitude
    }
}
