//
//  WatchCharacteristics.swift
//  Rebble
//
//  Created by Carson Katri on 10/4/17.
//  Copyright © 2017 Carson Katri. All rights reserved.
//

import Foundation

enum WatchCharacteristic: String {
    case service = "0000fed9-0000-1000-8000-00805f9b34fb"
    case connectivity = "00000001-328E-0FBB-C642-1AA6699BDADA"
    case pairingTrigger = "00000002-328E-0FBB-C642-1AA6699BDADA"
    case mtu = "00000003-328e-0fbb-c642-1aa6699bdada"
    case connectionParams = "00000005-328E-0FBB-C642-1AA6699BDADA"
    case configDescriptor = "00002902-0000-1000-8000-00805f9b34fb"
    
    case read = "10000002-328E-0FBB-C642-1AA6699BDADA"
    case write = "10000001-328E-0FBB-C642-1AA6699BDADA"
}
