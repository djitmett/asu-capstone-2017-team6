//
//  TrkRequestMainViewController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 1/21/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import UIKit

class TrkRequestMainViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table1: UITableView!
    @IBOutlet weak var table2: UITableView!
    
    
    var request = [String] ()//For tableview
    var request2 = [String] ()//for tableview
    var userPhoneNumber = ""
    var pending = [TrackingRequest] ()
    var tracking = [TrackingRequest] ()
    var allRequests = [TrackingRequest] ()


    //func getRequestFrom(phone_number: String) -> Array<String> {
    func getRequestFrom(phone_number: String) {
        let defaults = UserDefaults.standard
        if(defaults.object(forKey: "userPhone") != nil){
            userPhoneNumber = (defaults.object(forKey: "userPhone") as? String)!
        }
        let requestURL = "http://52.42.38.63/ioswebservice/api/getrequestsbyfrom.php?"
        let postParameters = "from_user_phone=" + (userPhoneNumber)
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
                            self.allRequests.removeAll()
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
                                
                                // Create Tracking Request object
                                let tempTR = TrackingRequest(req_ID: myReq_ID, req_from_user_phone: myReq_from_user_phone, req_to_user_phone: myReq_to_user_phone, req_expire_datetime: myReq_expire_datetime, req_expire_location_latitude: myReq_expire_location_latitude, req_expire_location_longitude: myReq_expire_location_longitude, req_create_datetime: myReq_create_datetime, req_status: myReq_status, req_status_change_datetime: myReq_status_change_datetime)
                                // If pending, add to pending array
                                if (tempTR.getReq_status()=="PENDING"){
                                    self.request.append(tempTR.getReq_to_user_phone())
                                    self.pending.append(tempTR)
                                    print(request)
                                }
                                // If approved, add to current tracking array
                                if (tempTR.getReq_status()=="APPROVED"){
                                    self.request2.append(tempTR.getReq_from_user_phone())
                                    self.tracking.append(tempTR)
                                }
                                // Store all tracking reqeusts
                                self.allRequests.append(tempTR)
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
        }
    })
    task.resume()
    //return pendRequest
    }

    @IBAction func clearMapBtn(_ sender: Any) {
        print("@ClearTracking")
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "currentTrackedUser") != nil){
            defaults.removeObject(forKey: "currentTrackedUser")
            print("Cleared tracked user")
        }
    
}

    let cellIdentifier : String = "cell"
    var numberOfTracked : Int = 0
    var numberOfRequested : Int = 0
    
override func viewDidLoad() {
    super.viewDidLoad()
    //pending.self = getRequestFrom(phone_number: userPhoneNumber)
    getRequestFrom(phone_number: userPhoneNumber)
    let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
    DispatchQueue.main.asyncAfter(deadline: when) {
        self.table1.reloadData()
        self.table2.reloadData()
    }
    
    
    // Do any additional setup after loading the view.
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (tableView.tag == 1){
        numberOfTracked = request2.count
        return numberOfTracked
    }else if(tableView.tag == 2){
        numberOfRequested = request.count
        return numberOfRequested
    }else{
    return 0
    }
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell
        if(tableView.tag == 1){
            cell.textLabel?.text = self.request2[indexPath.row]
            
        }else if(tableView.tag == 2){
            cell.textLabel?.text = self.request[indexPath.row]
        }
        return (cell)
    }
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */

}

// Define class for a TrackingRequest
class TrackingRequest {
    var req_ID: Int
    var req_from_user_phone: String
    var req_to_user_phone: String
    var req_expire_datetime: String
    var req_expire_location_latitude: String
    var req_expire_location_longitude: String
    var req_create_datetime: String
    var req_status: String
    var req_status_change_datetime: String
    
    init (req_ID: Int, req_from_user_phone: String, req_to_user_phone: String, req_expire_datetime: String, req_expire_location_latitude: String, req_expire_location_longitude: String, req_create_datetime: String, req_status: String, req_status_change_datetime: String) {
        self.req_ID = req_ID
        self.req_from_user_phone = req_from_user_phone
        self.req_to_user_phone = req_to_user_phone
        self.req_expire_datetime = req_expire_datetime
        self.req_expire_location_latitude = req_expire_location_latitude
        self.req_expire_location_longitude = req_expire_location_longitude
        self.req_create_datetime = req_create_datetime
        self.req_status = req_status
        self.req_status_change_datetime = req_status_change_datetime
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
}
