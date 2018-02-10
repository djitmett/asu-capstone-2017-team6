//
//  AppDelegate.swift
//  Ping!
//
//  Created by Darya T Jitmetta on 10/19/17.
//  Copyright © 2017 Darya T Jitmetta. All rights reserved.
//
// test
import UIKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {
    
    var window: UIWindow?
    
    static var appDelegate: AppDelegate!
    
    override init() {
        super.init()
        AppDelegate.appDelegate = self
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        //Receiving notification
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            //print("Received Notification: \(notification!.payload.notificationID)")
            //print("launchURL = \(notification?.payload.launchURL)")
            //print("content_available = \(String(describing: notification?.payload.contentAvailable))")
            
        }
        
        //Opening notification
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            //print("Message = \(payload!.body)")
            //print("badge number = \(String(describing: payload?.badge))")
            
            //IF THE PUSH NOTIFICATION HAS DATA
            if let additionalData = result!.notification.payload!.additionalData {
                //print("additionalData = \(additionalData)")
                
                //Should be nested in if statement for better handling but here it takes the value
                //Phone from the sent JSON string
                if additionalData["Indefinite"]! as! Bool == true {
                    print("Indefinite tracking is ON")
                }
                else {
                    print("Set tracking duration: ", additionalData["Duration"]!)
                }
                
                let phone_number = additionalData["Phone"]! as! String
                //print("Phone number from push notification: ", phone_number)
                
                //debug action in notification: prints when accept or reject is pressed
                if let actionSelected = payload?.actionButtons {
                    //print("actionSelected = \(actionSelected)")
                }
                
                //determines which notification button is pressed
                if let actionID = result?.action.actionID {
                    //print("actionID = \(actionID)")
                    //if accept-button is pressed
                    if actionID == "accept-button"{
                        //print("accept-id pressed!!!!")
                        
                        // This gets userID from phone but we only need phone to get location
                        let defaults = UserDefaults.standard
                        defaults.set(phone_number, forKey: "currentTrackedUser") // was user_id, now phone_number
                        // Navigate to map page
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        //let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabController") as! UITabBarController
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainNavController")
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = nextViewController
                        self.window?.makeKeyAndVisible()
                        
                        //                        self.getUserIdFromPhoneNumber(phoneNumber: phone_number){(value) in
                        //                            if (value >= 0){
                        //                                print("Start Tracking User_ID=", value)
                        //
                        //
                        //                            } else {
                        //                                print ("Could not get userID for phone_number=", phone_number)
                        //                            }
                        //                        }
                    }
                    //if reject-button is pressed
                    if actionID == "reject-button" {
                        print("reject-id pressed!!!!")
                    }
                }
                
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true, ]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "2a59fef0-d729-453e-b3ba-8d5f89bc102f", handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            //print("User accepted notifications: \(accepted)")
        })
        
        // Add your AppDelegate as an obsserver
        OneSignal.add(self as OSSubscriptionObserver)
        
        // Override point for customization after application launch.
        print(UserDefaults.standard.dictionaryRepresentation())
        let defaults = UserDefaults.standard
        if let isUserLoggedIn = UserDefaults.standard.object(forKey: "isLogged"),
            isUserLoggedIn is Bool {
            let logged = (defaults.object(forKey: "isLogged") as? Bool)!
            //print (isUserLoggedIn)
            
            window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: (logged ? "MainNavController" : "Login"))
            window?.makeKeyAndVisible()
        }
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        return true
    }
    
    //One Signal subscription changes
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            //print("Subscribed for OneSignal push notifications!")
            
            // get player ID
            if var player_id = stateChanges.to.userId {
                player_id = stateChanges.to.userId!
                //print("Current playerId \(player_id)")
                
            }
            
        }
        //print("SubscriptionStateChange: \n\(stateChanges)\n")
        //print("UNWRAPPED OPTIONAL USER ID: \n\(stateChanges.to.userId)\n")
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getUserIdFromPhoneNumber(phoneNumber: String, completion: @escaping (_ retUserID: Int) -> ()) {
        let requestURL = "http://52.42.38.63/ioswebservice/api/getuserdata.php?"
        let postParameters = "user_phone="+phoneNumber;
        var user_ID: Int = -1
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
                                user_ID = (data[9] as? Int)!
                            } else if(msg == "User does not exist!"){
                                user_ID = -1
                            }
                        }
                        completion(user_ID)
                    } catch {
                        print(error)
                    }
                }
            }
        })
        task.resume()
    }
    
}

