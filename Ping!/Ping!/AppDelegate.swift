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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       // let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        //Receiving notification
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            print("Received Notification: \(notification!.payload.notificationID)")
            //print("launchURL = \(notification?.payload.launchURL)")
            print("content_available = \(String(describing: notification?.payload.contentAvailable))")
        }
        
        //Opening notification
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message = \(payload!.body)")
            print("badge number = \(String(describing: payload?.badge))")
            //IF THE PUSH NOTIFICATION HAS DATA
            if let additionalData = result!.notification.payload!.additionalData {
                print("additionalData = \(additionalData)")
                //Should be nested in if statement for better handling but here it takes the value
                //Phone from the sent JSON string
                let phone_number = additionalData["Phone"]!
                print("Phone number from push notification: ", phone_number)
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true, ]
        
         OneSignal.initWithLaunchOptions(launchOptions,
                                         appId: "2a59fef0-d729-453e-b3ba-8d5f89bc102f", handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        // Add your AppDelegate as an obsserver
        OneSignal.add(self as OSSubscriptionObserver)
        
        // Sync hashed email if you have a login system or collect it.
        //   Will be used to reach the user at the most optimal time of day.
        // OneSignal.syncHashedEmail(userEmail)
        
        
        // Override point for customization after application launch.
        print(UserDefaults.standard.dictionaryRepresentation())
        let defaults = UserDefaults.standard
        if let isUserLoggedIn = UserDefaults.standard.object(forKey: "isLogged"),
            isUserLoggedIn is Bool {
            let logged = (defaults.object(forKey: "isLogged") as? Bool)!
            print (isUserLoggedIn)
            
            window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: (logged ? "TabController" : "Login"))
            window?.makeKeyAndVisible()
        }
        
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        
        return true
    }
    
    //One Signal subscription changes
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
            
            // get player ID
            if var player_id = stateChanges.to.userId {
                player_id = stateChanges.to.userId!
                print("Current playerId \(player_id)")
                
            }
            
        }
        print("SubscriptionStateChange: \n\(stateChanges)\n")
        print("UNWRAPPED OPTIONAL USER ID: \n\(stateChanges.to.userId)\n")
        
        
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
    
    
    
}

