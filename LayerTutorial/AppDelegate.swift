//
//  AppDelegate.swift
//  LayerTutorial
//
//  Created by Rommel Rico on 11/7/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit
import LayerKit

/**
 Layer App ID from developer.layer.com
 */
let LQSLayerAppIDString = "layer:///apps/staging/725c98a0-a51f-11e6-bfe9-455cd2013b06"

#if arch(i386) || arch(x86_64) // Simulator
    
    // If on simulator set the user ID to Simulator and participant to Device
let LQSCurrentUserID = "Simulator"
let LQSParticipantUserID = "Device"
let LQSInitialMessageText = "Hey Device! This is your friend, Simulator."
    
#else // Device
    
    // If on device set the user ID to Device and participant to Simulator
let LQSCurrentUserID = "Device"
let LQSParticipantUserID = "Simulator"
let LQSInitialMessageText = "Hey Simulator! This is your friend, Device."
    
#endif

let LQSParticipant2UserID = "Dashboard"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var layerClient: LYRClient!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Check if Sample App is using a valid app ID.
        if (isValidAppID()) {
            // Add support for shake gesture
            application.applicationSupportsShakeToEdit = true
            
            // Show a usage the first time the app is launched
            showFirstTimeMessage()
            
            // Initialize a LYRClient object
            let appID = URL(string: LQSLayerAppIDString)
            layerClient = LYRClient(appID: appID!)
            layerClient.connect { (success: Bool, error: Error?) in
                if success {
                    print("Layer Client did connect!")
                    self.authenticateLayerWithUserID(LQSCurrentUserID, completion: { (success: Bool, error: Error?) in
                        if success {
                            print("Layer Client did authenticate")
                        } else {
                            print("Failed to authenticate to Layer: Error: \(error?.localizedDescription)")
                        }
                    })
                } else {
                    print("Failed to connect to Layer with error: \(error?.localizedDescription)")
                }
            }
            
            let navigationController: UINavigationController = self.window!.rootViewController as! UINavigationController
            let viewController: LayerMainViewController = navigationController.topViewController as! LayerMainViewController
            viewController.layerClient = layerClient
        }
        
        return true
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

    // MARK - Layer Authentication Methods
    
    func authenticateLayerWithUserID(_ userID: String, completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        if let layerClient = layerClient {
            if layerClient.authenticatedUser?.userID != nil {
                print("Layer Authenticated as User \(layerClient.authenticatedUser?.userID)")
                completion(true, nil)
                return
            }
            
            // Authenticate with Layer
            layerClient.requestAuthenticationNonce(completion: { (nonce: String?, error: Error?) in
                if (nonce?.isEmpty)! {
                    completion(false, error)
                    return
                }
                
                print("completed: nonce: \(nonce!)")
                
                self.requestIdentityTokenForUserID(userID: userID, appID: layerClient.appID.absoluteString, nonce: nonce!, completion: { (identityToken: String, error: Error?) in
                    if identityToken.isEmpty {
                        completion(false, error)
                        return
                    }
                    
                    print("completed: identityToken: \(identityToken)")
                    
                    layerClient.authenticate(withIdentityToken: identityToken, completion: { (authenticatedUser: LYRIdentity?, error: Error?) in
                        if !(authenticatedUser?.userID.isEmpty)! {
                            completion(true, error)
                            print("Layer authenticated as user: \(authenticatedUser?.userID)")
                        } else {
                            completion(false, error)
                        }
                    })
                })
            })
        }
    }
    
    private func requestIdentityTokenForUserID(userID: String, appID: String, nonce: String, completion: @escaping ((_ identityToken: String, _ error: Error?) -> Void)) {
        //TODO: Authenticate against your own backend to get your own Identity Token. In our case, USDSecurity.
        let identityToken = "abcd-1234-efgh-5678"
        completion(identityToken, nil)
        
        
//        let identityTokenURL = URL(string: "https://layer-identity-provider.herokuapp.com/identity_tokens")
//        let request = NSMutableURLRequest(url: identityTokenURL!)
//        //let request = NSMutableURLRequest(URL: identityTokenURL!)
//        //let request = NSMutableURLRequest(url: identityTokenURL!)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        
//        let parameters = ["app_id": appID, "user_id": userID, "nonce": nonce]
//        //let requestBody = try? NSJSONSerialization.dataWithJSONObject(parameters, options: [])
//        let requestBody: Data? = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//        request.httpBody = requestBody
//        
//        let sessionConfiguration = URLSessionConfiguration.ephemeral
//        let session = URLSession(configuration: sessionConfiguration)
//        
//        //        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
//        //        let session = NSURLSession(configuration: sessionConfiguration)
//        
//        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
//            if error != nil {
//                completion("", error)
//                return
//            }
//            
//            // Deserialize the response
//            let responseObject = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
//            
//            if responseObject["error"] == nil {
//                let identityToken = responseObject["identity_token"] as! String
//                completion(identityToken, nil)
//            } else {
//                let domain = "layer-identity-provider.herokuapp.com"
//                let code = (responseObject["status"]! as AnyObject).integerValue
//                let userInfo = [
//                    NSLocalizedDescriptionKey: "Layer Identity Provider Returned an Error.",
//                    NSLocalizedRecoverySuggestionErrorKey: "There may be a problem with your APPID."
//                ]
//                
//                let error = NSError(domain: domain, code: code!, userInfo: userInfo)
//                completion("", error)
//            }
//        }
//        
//        dataTask.resume()
        
    }

    
    // MARK - First Run Notification
    
    func showFirstTimeMessage() {
        let LQSApplicationHasLaunchedOnceDefaultsKey = "applicationHasLaunchedOnce"
        
        let standardUserDefaults = UserDefaults.standard
        if (!standardUserDefaults.bool(forKey: LQSApplicationHasLaunchedOnceDefaultsKey)) {
            standardUserDefaults.set(true, forKey: LQSApplicationHasLaunchedOnceDefaultsKey)
            standardUserDefaults.synchronize()
            
            // This is the first launch ever
            let alert = UIAlertController(title: "Hello!", message: "This is a very simple example of a chat app using Layer. Launch this app on a Simulator and a Device to start a 1:1 conversation. If you shake the Device the navbar color will change on both the Simulator and Device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK - Check if Sample App is using a valid app ID.
    
    func isValidAppID() -> Bool {
        if LQSLayerAppIDString == "LAYER_APP_ID" {
            return false
        }
        return true
    }
    
}


// - MARK LYRClientDelegate Delegate Methods

extension AppDelegate: LYRClientDelegate {
    
    func layerClient(_ client: LYRClient, didReceiveAuthenticationChallengeWithNonce nonce: String) {
        print("Layer Client did recieve authentication challenge with nonce: \(nonce)")
    }
    
    
    // MARK: Transport 
    
    func layerClient(_ client: LYRClient, willAttemptToConnect attemptNumber: UInt, afterDelay delayInterval: TimeInterval, maximumNumberOfAttempts attemptLimit: UInt) {
        print("Layer Client willAttemptToConnect")
    }
    
    func layerClientDidConnect(_ client: LYRClient) {
        print("Layer Client did connect")
    }
    
    func layerClient(_ client: LYRClient, didLoseConnectionWithError error: Error) {
        print("Layer Client did Lose Connection with error")
    }
    
    func layerClientDidDisconnect(_ client: LYRClient) {
        print("Layer Client did disconnect")
    }
    
    
    //MARK: Authentication
    
    func layerClient(_ client: LYRClient, didAuthenticateAsUserID userID: String) {
        print("Layer Client did authenticate as User ID: \(userID)")
    }
    
    func layerClientDidDeauthenticate(_ client: LYRClient) {
        print("Layer Client did deauthenticate")
    }
    
    
    // MARK: Sessions
    
    func layerClient(_ client: LYRClient, didCreateSession session: LYRSession) {
        print("Layer Client did create session")
    }
    
    func layerClient(_ client: LYRClient, didAuthenticateSession session: LYRSession) {
        print("Layer Client did authenticate session")
    }
    
    func layerClient(_ client: LYRClient, didResumeSession session: LYRSession) {
        print("Layer Client did resume session")
    }
    
    func layerClient(_ client: LYRClient, didSwitchTo session: LYRSession) {
        print("Layer Client did switch to")
    }
    
    func layerClient(_ client: LYRClient, didDestroy session: LYRSession) {
        print("Layer Client did destroy")
    }
    
    
    // MARK: Synchronization and Content Management
    
    func layerClient(_ client: LYRClient, objectsDidChange changes: [LYRObjectChange]) {
        print("Layer Client objects did change")
    }
    
    func layerClient(_ client: LYRClient, didFailOperationWithError error: Error) {
        print("Layer Client did fail operation with error: \(error.localizedDescription)")
    }
    
    func layerClient(_ client: LYRClient, willBegin contentTransferType: LYRContentTransferType, of object: Any, with progress: LYRProgress) {
        print("Layer Client will Begin transfer")
    }
    
    func layerClient(_ client: LYRClient, didFinish contentTransferType: LYRContentTransferType, of object: Any) {
        print("Layer Client did Finish transfer")
    }
    
}
