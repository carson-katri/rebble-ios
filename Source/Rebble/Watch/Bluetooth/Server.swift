//
//  Server.swift
//  BLE server. Watch connects to this and subscribes to a characteristic. That's how it sends us data.
//
//  Created by Carson Katri on 2/7/18.
//  Copyright © 2018 Carson Katri. All rights reserved.
//

import Foundation
import CoreBluetooth



enum ServerService: String {
    case service = "10000000-328E-0FBB-C642-1AA6699BDADA"
    case serviceBadBad = "BADBADBA-DBAD-BADB-ADBA-BADBADBADBAD"
}

class Server: NSObject, CBPeripheralManagerDelegate {
    static let shared = Server()
    
    var manager: CBPeripheralManager!
    
    var characteristics: [CBMutableCharacteristic]!
    var serviceUUID: String!
    
    /* CHARACTERISTICS */
    var write = CBMutableCharacteristic(type: CBUUID(string: "10000001-328E-0FBB-C642-1AA6699BDADA"), properties: [.writeWithoutResponse, .notify], value: nil, permissions: .writeable)
    var read = CBMutableCharacteristic(type: CBUUID(string: "10000002-328E-0FBB-C642-1AA6699BDADA"), properties: [.read], value: nil, permissions: .readable)
    /* --------------- */
    
    override init() {
        super.init()
        manager = CBPeripheralManager(delegate: self, queue: nil)
        serviceUUID = ServerService.service.rawValue
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state != CBManagerState.poweredOn {
            print("[Server] \(peripheral.state.string())")
            return
        }
        
        print("[Server] poweredOn")
        
        self.startAdvertising()
        
        // Build the service
        let service = CBMutableService(type: CBUUID(string: serviceUUID), primary: true)
        service.characteristics = [read, write]
        
        // Add the service
        self.manager.add(service)
    }
    
    /* ADVERTISE */
    func startAdvertising() {
        print("[Server] started advertising")
        self.manager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: serviceUUID)]])
    }
    
    /* STOP ADVERTISING */
    func stopAdvertising() {
        print("[Server] stopped advertising")
        self.manager.stopAdvertising()
    }
    
    func sendData(to: Pebble, data: [UInt8]) {
        manager.updateValue(Data(bytes: data), for: write, onSubscribedCentrals: nil)
    }
    
    func sendAck(to: Pebble, serial: Int) {
        let data: [UInt8] = [UInt8(((serial << 3) | 1) & 0xff)]
        manager.updateValue(Data(bytes: data), for: write, onSubscribedCentrals: nil)
    }
    
    /* Request for Characteristic */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid.uuidString != read.uuid.uuidString {
            print("[Server] Unexpected read request")
            return
        }
        
        print("[Server] Sending response to request for \(request.characteristic.uuid.uuidString)")
        self.manager.respond(to: request, withResult: .success)
    }
}
