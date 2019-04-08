//
//  User.swift
//  ReceiptStorage
//
//  Created by Beyhan Bresner on 21/03/19.
//  Copyright © 2019 Beyhan Bresner. All rights reserved.
//

let UserID = "id"
let UserEmail = "email"

import Foundation

class User {
    var id: String?
    var email: String?
    
    // Used to check either user is logged in or not
    var isLoggedIn: Bool {
        return self.id != nil
    }
    
    static let currentUser : User = {
        let instance = User()
        return instance
    }()
    
    init() {
        self.setUp()
    }
    
    fileprivate func setUp(){
        self.id = UserDefaults.standard.string(forKey: UserID)
        self.email = UserDefaults.standard.string(forKey: UserEmail)
    }
    
    func saveUserInformation(userInfo: [String: Any]) {
        if let id = userInfo[UserID] as? String {
            self.id = id
            UserDefaults.standard.set(self.id, forKey: UserID)
        }
        
        if let email = userInfo[UserEmail] as? String {
            self.email = email
            UserDefaults.standard.set(self.email, forKey: UserEmail)
        }
    }
    
    func logOut(){
        self.id = nil
        self.email = nil
        
        UserDefaults.standard.set(nil, forKey: UserID)
        UserDefaults.standard.set(nil, forKey: UserEmail)
    }
}
