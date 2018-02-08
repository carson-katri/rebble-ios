//
//  HealthViewController.swift
//  Rebble
//
//  Created by Carson Katri on 10/4/17.
//  Copyright © 2017 Carson Katri. All rights reserved.
//

import UIKit
import Charts
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
    var setup: Bool = false
    
    var manager: WatchManager!
    
    @IBOutlet weak var watchIcon: UIImageView!
    @IBOutlet weak var batteryLevel: UILabel!
    
    @IBOutlet weak var stepChart: LineChartView!
    @IBOutlet weak var sleepChart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        manager = WatchManager.shared
        manager.onPaired = { watch in
            print(watch)
            self.paired = true
        }
        
        // Ping the Server so it starts up
        Server.shared
        
        /* Fake step data
        let data = LineChartDataSet(values: [ChartDataEntry(x: 0, y: 0), ChartDataEntry(x: 100, y: 73), ChartDataEntry(x: 200, y: 109), ChartDataEntry(x: 300, y: 322), ChartDataEntry(x: 400, y: 421), ChartDataEntry(x: 700, y: 544), ChartDataEntry(x: 900, y: 620)], label: "Steps")
        data.axisDependency = .left
        
        data.setColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        data.lineWidth = 5
        
        data.drawCirclesEnabled = false
        data.drawFilledEnabled = true
        data.drawValuesEnabled = false
        
        data.circleHoleColor = #colorLiteral(red: 0.282318294, green: 0.2823728323, blue: 0.282314837, alpha: 1)
        data.setCircleColor(#colorLiteral(red: 0.282318294, green: 0.2823728323, blue: 0.282314837, alpha: 1))
        data.circleRadius = 4
        
        data.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        data.fillAlpha = 1
        
        stepChart.data = LineChartData(dataSets: [data])
        
        stepChart.xAxis.drawGridLinesEnabled = false
        stepChart.backgroundColor = #colorLiteral(red: 0.1996459365, green: 0.7111043334, blue: 0.8989264369, alpha: 1)
        stepChart.drawGridBackgroundEnabled = false
        
        stepChart.drawBordersEnabled = false
        
        stepChart.chartDescription?.enabled = false
        
        stepChart.pinchZoomEnabled = false
        stepChart.dragEnabled = true
        stepChart.setScaleEnabled(false)
        
        stepChart.legend.enabled = false
        stepChart.xAxis.enabled = false
        
        let leftAxis = stepChart.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawLabelsEnabled = false
        
        stepChart.rightAxis.enabled = false
        
        stepChart.xAxis.axisMaximum = 1440 */
        
        let _ = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.reloadData()
        }
    }
    
    @IBAction func pairWatch(_ sender: Any) {
        // Setup watch:
        if !paired {
            newWatch()
        } else if !setup {
            setupWatch()
            setup = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func newWatch() {
        bulletinManager.prepare()
        
        let start = PageBulletinItem(title: "New Watch")
        start.image = #imageLiteral(resourceName: "watch")
        start.descriptionText = "Setup your new Pebble Watch!"
        start.actionButtonTitle = "Find Watch"
        start.interfaceFactory.tintColor = #colorLiteral(red: 0.9882352941, green: 0.2784313725, blue: 0.1176470588, alpha: 1)
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
    
    func reloadData() {
        // BATTERY LIFE:
        manager.get(uuid: "0000180F-0000-1000-8000-00805f9b34fb", char: "00002a19-0000-1000-8000-00805f9b34fb", data: { data in
            print(data)
        }) { err in
            print(err)
        }
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
        
        if segue.destination is TesterViewController {
            let destination = segue.destination as! TesterViewController
            destination.manager = manager
        }
    }
}
