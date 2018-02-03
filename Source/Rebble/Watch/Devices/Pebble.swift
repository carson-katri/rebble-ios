//
//  Pebble.swift
//  Used as a protocol for different devices
//
//  Created by Carson Katri on 11/27/17.
//  Copyright © 2017 Carson Katri. All rights reserved.
//

import Foundation
import Bluejay

class Pebble {
    var manager: WatchManager!
    
    func registerEndpoint(_ endpoint: Endpoint, callback: (())) {
        //manager.bluejay.listen(to: CharacteristicIdentifier(uuid: <#T##String#>, service: <#T##ServiceIdentifier#>), completion: <#T##(ReadResult<Receivable>) -> Void#>)
    }
    
    func sendToDevice(_ bytes: [Byte], completion: @escaping ((WriteResult) -> Void)) {
        
    }
}
