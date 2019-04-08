//
//  Receipt.swift
//  ReceiptStorage
//
//  Created by Beyhan Bresner on 23/03/19.
//  Copyright © 2019 Beyhan Bresner. All rights reserved.
//

import Foundation
import Firebase

class Receipt {
    
    var date: String
    var receiptUrl: String
    var name: String
    
    init(){
        self.date = ""
        self.receiptUrl = ""
        self.name = ""
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let date = value["date"] as? String,
            let receiptUrl = value["imageUrl"] as? String,
            let name = value["name"] as? String else {
                return nil
        }
        
        self.date = date
        self.receiptUrl = receiptUrl
        self.name = name
    }
    
    init(dictionary: [String: Any]) {
        let date = dictionary["date"] as? String
        let receiptUrl = dictionary["imageUrl"] as? String
        let name = dictionary["name"] as? String
        
        
        self.date = date!
        self.receiptUrl = receiptUrl!
        self.name = name!
    }
}
