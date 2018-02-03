//
//  WatchManager.swift
//  Manages the connection to the watch as well as sending/recieving data
//
//  Created by Carson Katri on 10/4/17.
//  Copyright © 2017 Carson Katri. All rights reserved.
//

import Foundation
import CoreBluetooth
import Bluejay

// Manages watch devices
class WatchManager: NSObject, ConnectionObserver {
    
    // LE
    let bluejay = Bluejay()
    
    var peripherals = [ScanDiscovery]()
    
    var onFound: ([ScanDiscovery]) -> () = { _ in }
    var onPaired: (Peripheral) -> () = { _ in }
    
    var watch: Peripheral? = nil
    
    // CLASSIC
    
    static let shared = WatchManager()
    
    override init() {
        super.init()
        bluejay.start(connectionObserver: self)
    }
    
    func bluetoothAvailable(_ available: Bool) {
        // Available
    }
    
    func connected(to peripheral: Peripheral) {
        // Added peripheral
        watch = peripheral
        onPaired(peripheral)
    }
    
    func disconnected(from peripheral: Peripheral) {
        // Disconnected peripheral
    }
    
    func datalog() {
        /*
        bluejay.listen(to: CharacteristicIdentifier(uuid: , service: ServiceIdentifier(uuid: )), completion: { [weak self] (result: ReadResult<Int64>) in
            guard let weakSelf = self else {
                return
            }
            print("DATALOG:")
            print(result)
        })
 
        self.get(uuid: WatchCharacteristic.read.rawValue, char: WatchUUID.pebbleHealth.rawValue, data: { data in
            print("\n\nDATALOG:\n")
            print(data)
        }) { err in
            print(err)
        }
        
        let message = encode(endpoint: Endpoint.ENDPOINT_DATALOG.rawValue, data: DataLog.DATALOG_OPENSESSION.rawValue)
 */
    }
    
    func scan() {
        bluejay.scan(
            serviceIdentifiers: nil,
            discovery: { [weak self] (discovery, discoveries) -> ScanAction in
                guard let weakSelf = self else {
                    return .stop
                }
                
                weakSelf.peripherals = discoveries
                weakSelf.onFound(discoveries)
                
                return .continue
            },
            stopped: { (discoveries, error) in
                if let error = error {
                    print("Scan failed: \(error.localizedDescription)")
                } else {
                    print("Scan stopped with no errors")
                }
            }
        )
    }
    
    func connect(peripheral: PeripheralIdentifier, completion: @escaping (Bool) -> ()) {
        bluejay.connect(peripheral, completion: { [weak self] (result) in
            switch result {
            case .success(let device):
                print("Connected to \(device.identifier)")
                print("Now send pairing request")
                guard let weakSelf = self else {
                    return
                }
                weakSelf.get(uuid: WatchCharacteristic.service.rawValue, char: WatchCharacteristic.pairingTrigger.rawValue, data: { data in
                    print("GOT DATA: \(data)")
                    print("Now check if connection was successful")
                    weakSelf.get(uuid: WatchCharacteristic.service.rawValue, char: WatchCharacteristic.connectivity.rawValue, data: { data in
                        print("GOT DATA: \(data)")
                        let _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { _ in
                            weakSelf.datalog()
                        })
                        completion(true)
                    }, failed: { error in
                        print("FAILED: \(error)")
                        completion(false)
                    })
                }, failed: { error in
                    print("FAILED: \(error)")
                    completion(false)
                })
            case .cancelled:
                print("Connection cancelled")
                completion(false)
            case .failure(let error):
                print("Failed to connect: \(error)")
                completion(false)
            }
        })
    }
    
    func encode(endpoint: Sendable, data: Sendable) -> [UInt8] {
        
        /*
         private byte[] encodeSimpleMessage(short endpoint, byte command) {
             final short LENGTH_SIMPLEMESSAGE = 1;
             ByteBuffer buf = ByteBuffer.allocate(LENGTH_PREFIX + LENGTH_SIMPLEMESSAGE);
             buf.order(ByteOrder.BIG_ENDIAN);
             buf.putShort(LENGTH_SIMPLEMESSAGE);
             buf.putShort(endpoint);
             buf.put(command);
         
             return buf.array();
         }
         */
        
        let messageLength = Length.LENGTH_PREFIX.rawValue + 1
        let bigEndian = UInt16(messageLength.bigEndian)
        
        let crc = (Bluejay.combine(sendables: [endpoint, bigEndian, data]) as Data)
        
        return [UInt8](crc)
    }
    
    func get(uuid: String, char: String, data: @escaping (UInt8) -> (), failed: @escaping (String) -> ()) {
        let service = ServiceIdentifier(uuid: uuid)
        let characteristic = CharacteristicIdentifier(uuid: char, service: service)
        
        bluejay.read(from: characteristic) { [weak self] (result: ReadResult<UInt8>) in
            guard let weakSelf = self else {
                return
            }
            
            switch result {
            case .success(let response):
                data(response)
            case .cancelled:
                failed("cancelled")
            case .failure(let error):
                failed(error.localizedDescription)
            }
        }
    }
}
