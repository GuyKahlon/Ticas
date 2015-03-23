//
//  AppDelegate.swift
//  Ticas
//
//  Created by Guy Kahlon on 3/22/15.
//  Copyright (c) 2015 GuyKahlon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Parse.setApplicationId("iaHDKLNBKY0IhK0U7KiEqhc9lUYHcCz25DK1Tk7G",clientKey: "tOFFXHTORPwjFTbHXk5JNFXMoVEgXjPnPczcXgSP")
        
        let isLoggedIn = PFUser.currentUser() != nil ? true : false
        if  isLoggedIn == false{            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let mainViewControlle = mainStoryboard.instantiateViewControllerWithIdentifier("Register view controller") as UIViewController
            window?.rootViewController = mainViewControlle
            window?.makeKeyAndVisible()
        }
    
        return true
    }
}

