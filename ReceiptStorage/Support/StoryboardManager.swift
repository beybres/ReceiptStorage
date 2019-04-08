//
//  StoryboardManager.swift
//  ReceiptStorage
//
//  Created by Beyhan Bresner on 21/03/19.
//  Copyright © 2019 Beyhan Bresner. All rights reserved.
//

import UIKit

class StoryboardManager {
    class func segueToLogin() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = mainStoryBoard.instantiateViewController(withIdentifier: "LoginNavigationViewController") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.replaceRootViewController(with: loginViewController, animated: true)
    }
    
    class func segueToMain() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = mainStoryBoard.instantiateViewController(withIdentifier: "MainNavigationViewController") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.replaceRootViewController(with: mainViewController, animated: true)
    }
}
