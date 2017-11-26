//
//  HealthViewController.swift
//  Rebble
//
//  Created by Carson Katri on 10/4/17.
//  Copyright © 2017 Carson Katri. All rights reserved.
//

import UIKit
import BulletinBoard

class ViewController: UIViewController {
    
    lazy var bulletinManager: BulletinManager = {
        
        let rootItem: BulletinItem = PageBulletinItem(title: "")
        return BulletinManager(rootItem: rootItem)
        
    }()
    
    var nextItem = { (item: PageBulletinItem) in
        // Show the next item:
        item.displayNextItem()
    }
    
    var paired: Bool = false
    
    var manager: WatchManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        manager = WatchManager.shared
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup watch:
        if !paired {
            newWatch()
        } else {
            setupWatch()
        }
    }
    
    func newWatch() {
        bulletinManager.prepare()
        
        let start = PageBulletinItem(title: "New Watch")
        start.image = #imageLiteral(resourceName: "watch")
        start.descriptionText = "Setup your new Pebble Watch!"
        start.actionButtonTitle = "Find Watch"
        start.interfaceFactory.tintColor = #colorLiteral(red: 0.9869872928, green: 0.2803094089, blue: 0.1182710156, alpha: 1)
        start.actionHandler = { item in
            // Show the pair page:
            self.bulletinManager.dismissBulletin(animated: true)
            self.performSegue(withIdentifier: "connect", sender: self)
            item.displayNextItem()
        }
        start.alternativeHandler = nextItem
        
        bulletinManager.push(item: start)
        
        bulletinManager.presentBulletin(above: self)
    }
    
    func setupWatch() {
        bulletinManager.prepare()
        
        let alerts = PageBulletinItem(title: "Notifications")
        alerts.image = #imageLiteral(resourceName: "notifications")
        alerts.descriptionText = "Recieve notifications on your wrist."
        alerts.actionButtonTitle = "Enable"
        alerts.alternativeButtonTitle = "Skip"
        alerts.interfaceFactory.tintColor = #colorLiteral(red: 0.9869872928, green: 0.2803094089, blue: 0.1182710156, alpha: 1)
        alerts.actionHandler = nextItem
        alerts.alternativeHandler = nextItem
        
        let health = PageBulletinItem(title: "Health")
        health.image = #imageLiteral(resourceName: "health")
        health.descriptionText = "Keep track of steps and sleep."
        health.actionButtonTitle = "Enable"
        health.alternativeButtonTitle = "Skip"
        health.interfaceFactory.tintColor = #colorLiteral(red: 0.9869872928, green: 0.2803094089, blue: 0.1182710156, alpha: 1)
        health.actionHandler = nextItem
        health.alternativeHandler = nextItem
        alerts.nextItem = health
        
        let location = PageBulletinItem(title: "Location")
        location.image = #imageLiteral(resourceName: "location")
        location.descriptionText = "Allow your watch to know it's location."
        location.actionButtonTitle = "Enable"
        location.alternativeButtonTitle = "Skip"
        location.interfaceFactory.tintColor = #colorLiteral(red: 0.9869872928, green: 0.2803094089, blue: 0.1182710156, alpha: 1)
        location.actionHandler = nextItem
        location.alternativeHandler = nextItem
        health.nextItem = location
        
        let done = PageBulletinItem(title: "All Done!")
        done.image = #imageLiteral(resourceName: "connected")
        done.descriptionText = "Your watch is ready to use."
        done.actionButtonTitle = "Awesome"
        done.interfaceFactory.tintColor = #colorLiteral(red: 0.9869872928, green: 0.2803094089, blue: 0.1182710156, alpha: 1)
        done.isDismissable = true
        done.actionHandler = { item in
            self.bulletinManager.dismissBulletin(animated: true)
        }
        location.nextItem = done
        
        bulletinManager.popToRootItem()
        bulletinManager.push(item: alerts)
        
        bulletinManager.presentBulletin(above: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.destination is ScanTableViewController {
            let destination = segue.destination as! ScanTableViewController
            destination.superview = self
        }
    }
}
