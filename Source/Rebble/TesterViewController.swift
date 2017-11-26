//
//  TesterViewController.swift
//  Rebble
//
//  Created by Carson Katri on 11/26/17.
//  Copyright © 2017 Carson Katri. All rights reserved.
//

import UIKit

class TesterViewController: UIViewController {

    var manager: WatchManager!
    
    @IBOutlet weak var uuid: UITextField!
    @IBOutlet weak var characteristic: UITextField!
    @IBOutlet weak var response: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
