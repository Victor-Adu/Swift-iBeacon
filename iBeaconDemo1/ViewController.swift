//
//  ViewController.swift
//  iBeaconDemo1
//
//  Created by Victor  Adu on 8/21/14.
//  Copyright (c) 2014 Victor  Adu. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController, CBPeripheralManagerDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    
    var peripheralManager : CBPeripheralManager!
    
    var beaconData : NSDictionary!
    
    //We are the Beacon (Broadcast)
    let myUUID = NSUUID(UUIDString: "4C4C8CFB-A77C-4BBA-91C7-F564C319D6DF")  // Think of it as the City  (1)
    //Read a beacon (Similar to 'StickNFind' or 'tag' concept)
    let yourUUID = NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D") //Somebody's UUID-e.g. here is 'artgallery app'
    
    let myIdentifier = "com.codefellows.victorAdu.beacons.the_east_room"     //think of it as the Street I live on (2)
    
    var region : CLBeaconRegion!
    var yourbeaconRegion : CLBeaconRegion!
    
    var locationManager : CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup location manager from ranging
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()

        
        //Setup my beacon
        region = CLBeaconRegion(proximityUUID: myUUID, identifier: myIdentifier) //think of it as my house number (3)
        yourbeaconRegion = CLBeaconRegion(proximityUUID: yourUUID, identifier: "iPhone")
        
        yourbeaconRegion.notifyEntryStateOnDisplay = true
        self.locationManager.startMonitoringForRegion(yourbeaconRegion)
        
        //Lets print out all our monitored regions
        var monitoredRegions = self.locationManager.monitoredRegions
        for monitoredRegion in monitoredRegions {
            println("\(monitoredRegion)")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func toggleBroadcast(sender: AnyObject) {
        //Get beacon to advertise
        self.beaconData = region.peripheralDataWithMeasuredPower(nil)
        
        //Start the peripheral manager
        self.peripheralManager = CBPeripheralManager(delegate:self, queue: nil)

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationManager.stopMonitoringForRegion(self.region)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.startButton.setTitle("Start", forState: .Normal)
    }

    //Clear our 'textView'
    @IBAction func clearTextViewBtnPressed(sender: AnyObject) {
        self.textView.text = " "
    }
    
    
    //MARK: - CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        var nextColor = UIColor()
        
        switch(peripheral.state){
        case .PoweredOn:
            //Bluetooth is on
            nextColor = UIColor(red:102.0/255.0, green: 204.0/255.0, blue: 153.0/255.0, alpha: 1.0)
            //update our status label
            self.statusLabel.text = "Broadcasting..."
            self.startButton.setTitle("Stop", forState: .Normal)
            //start broadcasting
            peripheral.startAdvertising(self.beaconData)
        case .PoweredOff:
             //Bluetooth is on
            nextColor = UIColor(red:102.0/255.0 , green: 204.0/255.0, blue: 153.0/255.0, alpha: 1.0)
            //update our status label
            self.statusLabel.text = "Stopped..."
            self.startButton.setTitle("Start", forState: .Normal)
            //Bluetooth isn't on. Stop broadcasting
            self.peripheralManager.stopAdvertising()
        case .Unsupported:
            nextColor = UIColor.darkGrayColor()
            //update our status label
            self.statusLabel.text = "Unsupported Device"
            self.startButton.setTitle("Disabled", forState: .Normal)
        case .Resetting:
            self.statusLabel.text = "Resetting..."
        default:
            break
        }
        
        UIView.animateWithDuration(0.4, animations:{() -> Void in
            self.view.backgroundColor = nextColor
        })
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        if beacons.count > 0 {
            println("\(beacons.count) beacons in range")
            
            var beaconInfo = self.textView.text
            for beacon in beacons {
                println("Ranged beacon \(beacon)")
                beaconInfo = "\(beacon.description)\n\(beaconInfo)"
            }
            self.textView.text = beaconInfo
        }
    }
    
    func locationManager(manager: CLLocationManager!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        self.textView.text = ("rangingBeaconsDidFailForRegion \(region)")
    }
    
    // Region Monitoring
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        self.textView.text = ("didStartMonitoringForRegion \(region)")
        self.locationManager.requestStateForRegion(self.yourbeaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println("monitoringDidFailForRegion \(region) \(error.localizedDescription)")
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        self.textView.text = "didEnterRegion \(region)\n\(self.textView.text)"
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        self.textView.text = "didExitRegion \(region)\n\(self.textView.text)"
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        println("didDetermineState \(state) \(region)")
        switch (state) {
        case .Inside:
            self.textView.text = ("didDetermineState Inside\n\(self.textView.text)")
            //            self.locationManager.startRangingBeaconsInRegion(self.beeconRegion)
        case .Outside:
            self.textView.text = ("didDetermineState Outside\n\(self.textView.text)")
            //            self.locationManager.stopRangingBeaconsInRegion(self.beeconRegion)
        case .Unknown:
            self.textView.text = ("didDetermineState Unknown\n\(self.textView.text)")
        }
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

