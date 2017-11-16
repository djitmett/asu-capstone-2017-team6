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
    var email : String
    var password: String
    var avatar : UIImage?
    
    init?(firstName:String, lastName:String, phoneNumber:String, email:String, password:String, avatar:UIImage?){
        
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.password = password
        self.avatar = avatar
        
    }
}
