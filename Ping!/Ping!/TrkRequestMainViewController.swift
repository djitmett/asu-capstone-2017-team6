//
//  TrkRequestMainViewController.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 1/21/18.
//  Copyright © 2018 Darya T Jitmetta. All rights reserved.
//

import UIKit

//Global arrays for tracking
var pending = [TrackingRequest] ()
var tracking = [TrackingRequest] ()
var tracked = [TrackingRequest] ()
var allRequests = [TrackingRequest] ()


class TrkRequestMainViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var table1: UITableView!
    @IBOutlet weak var table3: UITableView!
    @IBOutlet weak var table2: UITableView!

    @IBAction func RemoveTrk(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = table1.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        updateRequestByID(req: tracking[indexPath.row].getReq_ID(),table: 1)
        table1.reloadData()
        table2.reloadData()
        table3.reloadData()
    }
    // Added all required function to retrieve which cell button is selected
    @IBAction func DenyTrk(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = table3.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        updateRequestByID(req: tracked[indexPath.row].getReq_ID(),table: 3)
        table1.reloadData()
        table2.reloadData()
        table3.reloadData()
    }
    @IBAction func AcceptTrk(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = table2.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        updateRequestByID(req: pending[indexPath.row].getReq_ID(),table: 2)
        table1.reloadData()
        table2.reloadData()
        table3.reloadData()
        // We've got the index path for the cell that contains the button, now do something with it.
        print("button is in row \(indexPath.row)")
    }
    func updateRequestByID(req: Int,table: Int)->Void{
        var statusMsg = "PENDING"
        if table == 1 {
            statusMsg = "EXPIRED"
        }else if table == 2{
            statusMsg = "APPROVED"
        }else if table == 3{
            statusMsg = "REJECTED"
        }
        
        let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/updaterequestbyID.php?"
        let requestURL = NSURL(string: URL_SIGNUP)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        
        var postParameters = "req_ID=\(req)"
        postParameters += "&req_status=\(statusMsg)"

        print(postParameters)
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            if error != nil{
                print("error is \(String(describing: error))")
                return;
            }
        
        }
        task.resume()
    }
    func timeStamp()->String{
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: now)
        return dateString
    }
    var request = [String] ()//For tableview
    var request2 = [String] ()//for tableview
    var request3 = [String] ()//For tableview
    var userPhoneNumber = ""
    
    //func getRequestFrom(phone_number: String) -> Array<String> {
    func getRequestFrom(phone_number: String, completion: @escaping (_ success: Bool) -> Void) {
        let defaults = UserDefaults.standard
        if(defaults.object(forKey: "userPhone") != nil){
            userPhoneNumber = (defaults.object(forKey: "userPhone") as? String)!
        }
        let requestURL = "http://52.42.38.63/ioswebservice/api/getrequestsbyto.php?"
        let postParameters = "to_user_phone=" + (userPhoneNumber)
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
                                allRequests.removeAll()
                                pending.removeAll()
                                tracking.removeAll()
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
                                    
                                    // Create Tracking Request object
                                    let tempTR = TrackingRequest(req_ID: myReq_ID, req_from_user_phone: myReq_from_user_phone, req_to_user_phone: myReq_to_user_phone, req_expire_datetime: myReq_expire_datetime, req_expire_location_latitude: myReq_expire_location_latitude, req_expire_location_longitude: myReq_expire_location_longitude, req_create_datetime: myReq_create_datetime, req_status: myReq_status, req_status_change_datetime: myReq_status_change_datetime, req_from_user_fname: myReq_from_user_fname, req_from_user_lname: myReq_from_user_lname)
                                    
                                    //Convert expiration date string to date
                                    let expire = tempTR.getReq_expire_datetime()
                                    let currentDate = Date()
                                    if(expire != "indefinite" && tempTR.getReq_status() != "EXPIRED") {
                                        let expireDate = expire.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss zz")
                                        if (expireDate < currentDate) {
                                            print("expired")
                                            print(currentDate)
                                            let id = tempTR.getReq_ID()
                                            self.updateRequestByID(req: id, table: 2)
                                        }
                                        else {
                                            //print("not expired")
                                        }
                                    }
 
                                    // If pending, add to pending array
                                    if (tempTR.getReq_status()=="PENDING"){
                                        let name = tempTR.getReq_from_user_fname() + " " + tempTR.getReq_from_user_lname()
                                        self.request.append(name)
                                        pending.append(tempTR)
                                        print(request)
                                    }
                                    // If approved, add to current tracking array
                                    if (tempTR.getReq_status()=="APPROVED"){
                                        let name = tempTR.getReq_from_user_fname() + " " + tempTR.getReq_from_user_lname()
                                        self.request2.append(name)
                                        tracking.append(tempTR)
                                    }
                                    // Store all tracking reqeusts
                                    allRequests.append(tempTR)
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
    
    //func getRequestBy(phone_number: String) -> Array<String> {
    func getRequestBy(phone_number: String, completion: @escaping (_ success: Bool) -> Void) {
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
                                allRequests.removeAll()
                                tracked.removeAll()
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
                                    
                                    // Create Tracking Request object
                                    let tempTR = TrackingRequest(req_ID: myReq_ID, req_from_user_phone: myReq_from_user_phone, req_to_user_phone: myReq_to_user_phone, req_expire_datetime: myReq_expire_datetime, req_expire_location_latitude: myReq_expire_location_latitude, req_expire_location_longitude: myReq_expire_location_longitude, req_create_datetime: myReq_create_datetime, req_status: myReq_status, req_status_change_datetime: myReq_status_change_datetime, req_from_user_fname: myReq_from_user_fname, req_from_user_lname: myReq_from_user_lname)
                                    
                                    //Convert expiration date string to date
                                    let expire = tempTR.getReq_expire_datetime()
                                    let currentDate = Date()
                                    if(expire != "indefinite" && tempTR.getReq_status() != "EXPIRED") {
                                        let expireDate = expire.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss zz")
                                        if (expireDate < currentDate) {
                                            print("expired")
                                            print(currentDate)
                                            let id = tempTR.getReq_ID()
                                            self.updateRequestByID(req: id, table:2)
                                      
                                        }
                                        else {
                                            //print("not expired")
                                        }
                                    }
                                    
                                    // If approved, add to current tracked array
                                    if (tempTR.getReq_status()=="APPROVED"){
                                        let name =
                                            tempTR.getReq_from_user_fname() + " " + tempTR.getReq_from_user_lname()
                                        self.request3.append(name)
                                        tracked.append(tempTR)
                                    }
                                    // Store all tracking reqeusts
                                    allRequests.append(tempTR)
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
    
    
    //Expire the request in the DB
    func expireRequest(request_id: Int) {
        let URL_SIGNUP = "http://52.42.38.63/ioswebservice/api/updaterequestbyID.php?"
        let requestURL = NSURL(string: URL_SIGNUP)
        let request = NSMutableURLRequest(url: requestURL! as URL)
        request.httpMethod = "POST"
        
        var postParameters = "req_ID=\(request_id)"
        postParameters += "&req_status=EXPIRED"
        
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            if error != nil{
                print("error is \(String(describing: error))")
                return;
            }
            
            do {
                let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if let parseJSON = myJSON {
                    var msg : String!
                    msg = parseJSON["message"] as! String?
                    print("MESSAGE=" + msg)
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }

    
    let cellIdentifier : String = "cell"
    var numberOfTracked : Int = 0
    var numberOfRequested : Int = 0
    var numberOfTracking : Int = 0
    
    
    @IBAction func clearMapBtn(_ sender: Any) {
        print("@ClearTracking")
        //let defaults = UserDefaults.standard
        //if (defaults.object(forKey: "currentTrackedUser") != nil){
        //    defaults.removeObject(forKey: "currentTrackedUser")
        //    print("Cleared tracked user")
        
            for i in 0 ..< pending.count {
                let deleteAllTR = pending[i];
                let deleteAllID = deleteAllTR.getReq_ID()
                self.expireRequest(request_id: deleteAllID)
            }
        request.removeAll()
        pending.removeAll()
        self.table2.reloadData()
            
        //}
        
    }
    
    
    @IBAction func clearTrkBtn(_ sender: Any) {
        for i in 0 ..< tracking.count {
            let deleteAllTR = tracking[i];
            let deleteAllID = deleteAllTR.getReq_ID()
            self.expireRequest(request_id: deleteAllID)
        }
        
        request2.removeAll()
        tracking.removeAll()
        self.table1.reloadData()
    }
    
    
    @IBAction func clearUserBtn(_ sender: Any) {
        for i in 0 ..< tracked.count {
            let deleteAllTR = tracked[i];
            let deleteAllID = deleteAllTR.getReq_ID()
            self.expireRequest(request_id: deleteAllID)
        }
        
        request3.removeAll()
        tracked.removeAll()
        self.table3.reloadData()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table1.layer.borderWidth = 2.0;
        table2.layer.borderWidth = 2.0;
        table3.layer.borderWidth = 2.0;
        
        
        //pending.self = getRequestFrom(phone_number: userPhoneNumber)
        getRequestFrom(phone_number: userPhoneNumber) { (success) -> Void in
            let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.table1.reloadData()
                self.table2.reloadData()
            }
        }
        getRequestBy(phone_number: userPhoneNumber) { (success) -> Void in
            let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.table3.reloadData()
            }
        }
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = NSLocalizedString("Reloading Data", comment: "Pull to refresh")
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(refreshOptions(sender:)),
                                     for: .valueChanged)
            scrollView.refreshControl = refreshControl
        }
    }
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
        // Place refresh code between here
        
        // and here
        sender.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 1){
            numberOfTracked = request2.count
            return numberOfTracked
        }else if(tableView.tag == 2){
            numberOfRequested = request.count
            return numberOfRequested
        }else if(tableView.tag == 3){
            numberOfTracking = request3.count
            return numberOfTracking
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
       
        }else if(tableView.tag == 3) {
            cell.textLabel?.text = self.request3[indexPath.row]
        }
        return (cell)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt
        indexPath: IndexPath) {
     
        if editingStyle == .delete {
            
            if(tableView.tag == 1) {
                let deleteTR = tracking[indexPath.row]
                let deleteID = deleteTR.getReq_ID()
                request2.remove(at: indexPath.row)
                tracking.remove(at: indexPath.row)
                
                self.expireRequest(request_id: deleteID)
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
            
            if(tableView.tag == 2) {
                let deleteTR = pending[indexPath.row]
                let deleteID = deleteTR.getReq_ID()
                request.remove(at: indexPath.row)
                pending.remove(at: indexPath.row)
                
                self.expireRequest(request_id: deleteID)
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
                
            }
            
            if(tableView.tag == 3) {
                let deleteTR = tracked[indexPath.row]
                let deleteID = deleteTR.getReq_ID()
                request3.remove(at: indexPath.row)
                tracked.remove(at: indexPath.row)
                
                self.expireRequest(request_id: deleteID)
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
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
    var req_from_user_fname : String
    var req_from_user_lname : String
    
    init (req_ID: Int, req_from_user_phone: String, req_to_user_phone: String, req_expire_datetime: String, req_expire_location_latitude: String, req_expire_location_longitude: String, req_create_datetime: String, req_status: String, req_status_change_datetime: String, req_from_user_fname: String, req_from_user_lname: String) {
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
    
}
extension String
{
    func toDate( dateFormat format  : String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        //dateFormatter.timeZone = NSTimeZone.default
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        return dateFormatter.date(from: self)!
        
    }
    
}
