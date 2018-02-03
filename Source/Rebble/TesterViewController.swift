//
//  TesterViewController.swift
//  Different actions for testing on the watch
//
//  Created by Carson Katri on 11/26/17.
//  Copyright © 2017 Carson Katri. All rights reserved.
//

import UIKit
import Bluejay

class TesterViewController: UIViewController {

    var manager: WatchManager!
    
    @IBOutlet weak var uuid: UITextField!
    @IBOutlet weak var characteristic: UITextField!
    @IBOutlet weak var response: UITextView!
    
    var shouldLog = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Start a test timer for pinging different Characteristics:
        if self.shouldLog {
            self.response.text = ""
            self.manager.get(uuid: WatchCharacteristic.service.rawValue, char: WatchCharacteristic.mtu.rawValue, data: { data in
                self.log("[MTU] \(data)")
            }, failed: { error in
                self.log("[MTU] ERROR: \(error)")
            })
            
            self.manager.get(uuid: WatchCharacteristic.service.rawValue, char: WatchCharacteristic.connectivity.rawValue, data: { data in
                self.log("[Connectivity] \(data)")
            }, failed: { error in
                self.log("[Connectivity] ERROR: \(error)")
            })
            
            self.manager.get(uuid: WatchCharacteristic.service.rawValue, char: WatchCharacteristic.read.rawValue, data: { data in
                self.log("[Read] \(data)")
            }, failed: { error in
                self.log("[Read] ERROR: \(error)")
            })
            
            self.manager.get(uuid: WatchCharacteristic.service.rawValue, char: WatchCharacteristic.connectionParams.rawValue, data: { data in
                self.log("[Connection Params] \(data)")
            }, failed: { error in
                self.log("[Connection Params] ERROR: \(error)")
            })
            
            self.manager.get(uuid: WatchCharacteristic.service.rawValue, char: WatchCharacteristic.configDescriptor.rawValue, data: { data in
                self.log("[Config Descriptor] \(data)")
            }, failed: { error in
                self.log("[Config Descriptor] ERROR: \(error)")
            })
            
            self.manager.get(uuid: WatchCharacteristic.service.rawValue, char: WatchUUID.location.rawValue, data: { data in
                self.log("[Location] \(data)")
            }, failed: { error in
                self.log("[Location] ERROR: \(error)")
            })
            
            self.manager.get(uuid: WatchCharacteristic.service.rawValue, char: WatchUUID.pebbleHealth.rawValue, data: { data in
                self.log("[Pebble Health] \(data)")
            }, failed: { error in
                self.log("[Health] ERROR: \(error)")
            })
            
            self.manager.get(uuid: WatchCharacteristic.service.rawValue, char: WatchUUID.notifications.rawValue, data: { data in
                self.log("[Notifications] \(data)")
            }, failed: { error in
                self.log("[Notifications] ERROR: \(error)")
            })
            
            self.manager.get(uuid: WatchCharacteristic.service.rawValue, char: WatchUUID.weather.rawValue, data: { data in
                self.log("[Weather] \(data)")
            }, failed: { error in
                self.log("[Weather] ERROR: \(error)")
            })
            
            self.manager.get(uuid: WatchCharacteristic.service.rawValue, char: WatchUUID.workout.rawValue, data: { data in
                self.log("[Workout] \(data)")
            }, failed: { error in
                self.log("[Workout] ERROR: \(error)")
            })
        }
    }
    
    func log(_ message: String) {
        if shouldLog {
            self.response.text = "\(self.response.text!)\n\n\(message)"
        }
    }
    
    @IBAction func logStateChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.shouldLog = true
        } else {
            self.shouldLog = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func send(_ sender: Any) {
        manager.get(uuid: uuid.text ?? "", char: characteristic.text ?? "", data: { data in
            self.response.text = "\(data)"
        }) { err in
            self.response.text = "\(err)"
        }
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Presets
    
    @IBAction func health(_ sender: Any) {
        manager.get(uuid: WatchCharacteristic.read.rawValue, char: WatchUUID.pebbleHealth.rawValue, data: { data in
            self.response.text = "\(data)"
        }) { err in
            self.response.text = "\(err)"
        }
    }
    
    @IBAction func workout(_ sender: Any) {
        manager.get(uuid: WatchCharacteristic.read.rawValue, char: WatchUUID.workout.rawValue, data: { data in
            self.response.text = "\(data)"
        }) { err in
            self.response.text = "\(err)"
        }
    }
    
    @IBAction func notifications(_ sender: Any) {
        manager.get(uuid: WatchCharacteristic.read.rawValue, char: WatchUUID.notifications.rawValue, data: { data in
            self.response.text = "\(data)"
        }) { err in
            self.response.text = "\(err)"
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
