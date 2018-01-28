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
    
func getRequestFromPhone(phone_number: String, completion: @escaping (_ trackLat: Double, _ trackLong: Double, _ lastUpdate: String) -> ()) {
        let requestURL = "http://52.42.38.63/ioswebservice/api/getrequestbyto.php?"
        let postParameters = "user_phone="+phone_number;
    var pendRequest = [String ] ()// array to fill with pending request
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
                        //print("MESSAGE=",msg)
                        if(msg == "Operation successfully!"){
                            data = parseJSON["data"] as! NSArray?
                            let tempRequest = (data[0] as? String)!
                            pendRequest.append(tempRequest)
                        } else {
                            pendRequest.append("No Request")
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
    
    // Do any additional setup after loading the view.
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
