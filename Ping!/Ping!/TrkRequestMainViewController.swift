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
    
    
    let request = ["Brian", "Corey", "Josh", "Darya", "Nathan"]
    let request2 = ["Nathan","Darya", "Josh", "Corey","Brian" ]
    var pending = [String] ()
    var tracking = [String] ()
    

    
    func getRequestFrom(phone_number: String) -> () {
        let requestURL = "http://52.42.38.63/ioswebservice/api/getrequestsbyfrom.php?"
        let postParameters = "from_user_phone=" + (phone_number)
        print(requestURL+postParameters)
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
                        print("MESSAGE=",msg)
                        if(msg == "Operation successful!"){
                            data = parseJSON["data"] as! NSArray?
                            var i=0 as Int
                            while (i<data.count){
                                print(data[i])
                                i = i + 1
                            }
                            //let tempRequest = (data[0] as? String)!
                            //pendRequest.append(tempRequest)
                        } else {
                            //pendRequest.append("No Request")
                        }
                    }
                    //completion(lat, long, lastUpdate)
                    self.pending = pendRequest
                    print(self.pending)
                } catch {
                    print(error)
                }
            }
        }
    })
    task.resume()
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
    let defaults = UserDefaults.standard
    if (defaults.object(forKey: "userPhone") != nil){
        getRequestFrom(phone_number:defaults.object(forKey: "userPhone") as! String)
    }
    
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (tableView.tag == 1){
        numberOfTracked = request.count
        return numberOfTracked
    }else if(tableView.tag == 2){
        numberOfRequested = request2.count
        return numberOfRequested
    }else{
    return 0
    }
}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell
        if(tableView.tag == 1){
            cell.textLabel?.text = request[indexPath.row]
        }else if(tableView.tag == 2){
            cell.textLabel?.text = request2[indexPath.row]
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


class trackingRequest {
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
}

