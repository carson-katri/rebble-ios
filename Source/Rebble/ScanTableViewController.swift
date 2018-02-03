//
//  ScanTableViewController.swift
//  Shows the different devices available.
//
//  Created by Carson Katri on 10/4/17.
//  Copyright © 2017 Carson Katri. All rights reserved.
//

import UIKit
import Bluejay

class ScanTableViewController: UITableViewController {

    var manager: WatchManager!
    
    var devices = [ScanDiscovery]()
    
    var superview: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        manager = WatchManager.shared
        manager.onFound = { devices in
            self.tableView.reloadData()
        }
        manager.scan()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Get the number of peripherals
        devices = manager.peripherals
        devices = devices.filter({ $0.peripheral.name != nil })
        return devices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scanCell", for: indexPath)

        // Configure the cell...
        let label = cell.viewWithTag(1) as! UILabel
        let uuid = cell.viewWithTag(2) as! UILabel
        
        let device = devices[indexPath.row].peripheral
        label.text = device.name ?? "No Name"
        uuid.text = device.identifier.uuidString
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Connect peripheral:
        let id = devices[indexPath.row].peripheral.identifier
        manager.connect(peripheral: PeripheralIdentifier(uuid: id), completion: { success in
            print(success)
            if success {
                print("Connected.")
                if self.superview != nil {
                    self.superview?.paired = true
                }
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Failed to connect")
            }
        })
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
