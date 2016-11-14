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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let appID = URL(string: LQSLayerAppIDString)
        let layerClient = LYRClient(appID: appID!, delegate: self, options: nil)
        layerClient.connect { (success: Bool, error: Error?) in
            if success {
                print("Successfully connected to Layer")
            } else {
                print("Failed to connect to Layer with error: \(error?.localizedDescription)")
            }
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
