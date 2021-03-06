//
//  RequestData.swift
//  Ping!
//
//  Created by Josh Hall on 2/26/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import Foundation


// Class to handle loading TrackingRequestData
class TrackingRequstDataManager{
    var allTrackingRequests = [TrackingRequestData] ()
    
    public func loadTrackingRequestData2(){
//        let trd = TrackingRequestData(req_ID: 999, req_from_user_phone: "999", req_to_user_phone: "999", req_expire_datetime: "999", req_expire_location_latitude: "999", req_expire_location_longitude: "999", req_create_datetime: "999", req_status: "999", req_status_change_datetime: "999", req_from_user_fname: "999", req_from_user_lname: "999", location_latitude : "999", location_longitude : "999", location_datetime : "999")
//        allTrackingRequests.append(trd)
        
        
    }
    
    public func update(){
        print("TrackingRequstDataManager.update Complete!")
    }
    
    public func loadTrackingRequestData(phone_number: String, completion: @escaping (_ success: Bool) -> Void) {
        let requestURL = "http://52.42.38.63/ioswebservice/api/getrequestdatabyto.php?"
        let postParameters = "to_user_phone=" + (phone_number)
        var pendRequest = [String] ()// array to fill with pending request
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
                            if(msg == "Operation successful!"){
                                data = parseJSON["data"] as! NSArray?
                                for request in data{
                                    let element = request as! NSArray
                                    // Define variables for tracking request
                                    var myReq_ID : Int
                                    var myReq_from_user_phone : String
                                    var myReq_to_user_phone : String
                                    var myReq_expire_datetime : String
                                    var myReq_expire_location_latitude : String
                                    var myReq_expire_location_longitude : String
                                    var myReq_create_datetime : String
                                    var myReq_status : String
                                    var myReq_status_change_datetime : String
                                    var myReq_from_user_fname : String
                                    var myReq_from_user_lname : String
                                    
                                    // Error check each field in array before conversion
                                    if let tempVar = element[0] as? Int {
                                        myReq_ID = (element[0] as? Int)!
                                    } else {
                                        myReq_ID = -999
                                    }
                                    if let tempVar = element[1] as? String {
                                        myReq_from_user_phone = (element[1] as? String)!
                                    } else {
                                        myReq_from_user_phone = ""
                                    }
                                    if let tempVar = element[2] as? String {
                                        myReq_to_user_phone = (element[2] as? String)!
                                    } else {
                                        myReq_to_user_phone = ""
                                    }
                                    if let tempVar = element[3] as? String {
                                        myReq_expire_datetime = (element[3] as? String)!
                                    } else {
                                        myReq_expire_datetime = ""
                                    }
                                    if let tempVar = element[4] as? String {
                                        myReq_expire_location_latitude = (element[4] as? String)!
                                    } else {
                                        myReq_expire_location_latitude = ""
                                    }
                                    if let tempVar = element[5] as? String {
                                        myReq_expire_location_longitude = (element[5] as? String)!
                                    } else {
                                        myReq_expire_location_longitude = ""
                                    }
                                    if let tempVar = element[6] as? String {
                                        myReq_create_datetime = (element[6] as? String)!
                                    } else {
                                        myReq_create_datetime = ""
                                    }
                                    if let tempVar = element[7] as? String {
                                        myReq_status = (element[7] as? String)!
                                    } else {
                                        myReq_status = ""
                                    }
                                    if let tempVar = element[8] as? String {
                                        myReq_status_change_datetime = (element[8] as? String)!
                                    } else {
                                        myReq_status_change_datetime = ""
                                    }
                                    if let tempVar = element[9] as? String {
                                        myReq_from_user_fname = (element[9] as? String)!
                                    } else {
                                        myReq_from_user_fname = ""
                                    }
                                    if let tempVar = element[10] as? String {
                                        myReq_from_user_lname = (element[10] as? String)!
                                    } else {
                                        myReq_from_user_lname = ""
                                    }
                                    let trd = TrackingRequestData(req_ID: 999, req_from_user_phone: "999", req_to_user_phone: "999", req_expire_datetime: "999", req_expire_location_latitude: "999", req_expire_location_longitude: "999", req_create_datetime: "999", req_status: "999", req_status_change_datetime: "999", req_from_user_fname: "999", req_from_user_lname: "999", location_latitude : "999", location_longitude : "999", location_datetime : "999")
                                    self.allTrackingRequests.append(trd)
                                }
                            } else {
                                pendRequest.append("No Requests")
                            }
                            
                        }
                        
                        //  print(self.allRequests)
                    } catch {
                        print(error)
                    }
                    
                }
                completion(true)
            }
        })
        task.resume()
        
        //return pendRequest
    }
}

// Define class for TrackingRequestData
class TrackingRequestData {
    
    var req_ID: Int
    var req_from_user_phone: String
    var req_to_user_phone: String
    var req_expire_datetime: String
    var req_expire_location_latitude: String
    var req_expire_location_longitude: String
    var req_create_datetime: String
    var req_status: String
    var req_status_change_datetime: String
    
    var req_from_user_fname : String
    var req_from_user_lname : String
    
    var location_latitude : String
    var location_longitude : String
    var location_datetime : String
    
    init (req_ID: Int, req_from_user_phone: String, req_to_user_phone: String, req_expire_datetime: String, req_expire_location_latitude: String, req_expire_location_longitude: String, req_create_datetime: String, req_status: String, req_status_change_datetime: String, req_from_user_fname: String, req_from_user_lname: String, location_latitude : String, location_longitude : String, location_datetime : String) {
        self.req_ID = req_ID
        self.req_from_user_phone = req_from_user_phone
        self.req_to_user_phone = req_to_user_phone
        self.req_expire_datetime = req_expire_datetime
        self.req_expire_location_latitude = req_expire_location_latitude
        self.req_expire_location_longitude = req_expire_location_longitude
        self.req_create_datetime = req_create_datetime
        self.req_status = req_status
        self.req_status_change_datetime = req_status_change_datetime
        self.req_from_user_fname = req_from_user_fname
        self.req_from_user_lname = req_from_user_lname
        self.location_latitude = location_latitude
        self.location_longitude = location_longitude
        self.location_datetime = location_datetime
    }
    
    // Getters
    public func getReq_ID() -> Int{
        return self.req_ID
    }
    public func getReq_from_user_phone() -> String{
        return self.req_from_user_phone
    }
    public func getReq_to_user_phone() -> String{
        return self.req_to_user_phone
    }
    public func getReq_expire_datetime() -> String{
        return self.req_expire_datetime
    }
    public func getReq_expire_location_latitude() -> String{
        return self.req_expire_location_latitude
    }
    public func getReq_expire_location_longitude() -> String{
        return self.req_expire_location_longitude
    }
    public func getReq_create_datetime() -> String{
        return self.req_create_datetime
    }
    public func getReq_status() -> String{
        return self.req_status
    }
    public func getReq_status_change_datetime() -> String{
        return self.req_status_change_datetime
    }
    public func getReq_from_user_fname() -> String{
        return self.req_from_user_fname
    }
    public func getReq_from_user_lname() -> String{
        return self.req_from_user_lname
    }
    public func getlocation_latitude() -> String{
        return self.location_latitude
    }
    public func getlocation_longitude() -> String{
        return self.location_longitude
    }
    public func getlocation_datetime() -> String{
        return self.location_datetime
    }
    
}
