//
//  TestVC.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 15/06/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

// Add time stamp UTC

import UIKit
import CoreLocation
import SQLite

class TestVC: UIViewController, CLLocationManagerDelegate {
    // UI IBOutlet
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var txtResults: UITextView!
    @IBOutlet weak var lblTestName: UILabel!
    @IBOutlet weak var lblIsRunning: UILabel!
    
    // Count Down Vairiables
    var testTime = 1
    var testName = ""
    var testPassedID = 0
    var sendTestID = 0
    var countdownTimer: Timer!
    var isCountDownRunning = false
    var resumeTapped = false
    
    var locationManager : CLLocationManager!
    var results = [String]()
    var cleanResults = [String]()
    var exportResultsData = [String]()
    var lineArray = [String]()
    var testLine = ""
    var endResults = ""
    var running = false
    var activeUUID = ""
    var outliners = 0
    
    //    DB Variables
    var database: Connection!
    let TestInfoTable = Table("testInfo")
    let resultsTable = Table("results")
    let testID = Expression<Int>("testID")
    let major = Expression<String>("major")
    let minor = Expression<String>("minor")
    let rssi = Expression<String>("rssi")
    let accuracy = Expression<String>("accuracy")
    let distance = Expression<String>("distance")
    let date = Expression<String>("date")
    let countSecond = Expression<Int>("countSecond")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("Hey UUID is: " + activeUUID)
        locationManager = CLLocationManager.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        lblTestName.text = testName
        lblTimer.text = "\(timeFormatted(testTime))"
        
        print("Hey look at me" + testName)
        
        // DB Check
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("Beacon").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
    }
    
    // MARK: House Cleaning Code
    
    //Removes Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: Countdown Timer
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        lblTimer.text = "\(timeFormatted(testTime))"
        
        if testTime != 0 {
            testTime -= 1
            //            print("Clock tick")
        } else {
            endTimer()
            lblIsRunning.text = "Finished"
            stopScanningForBeaconRegion(beaconRegion: getBeaconRegion())
        }
    }
    
    
    
    func endTimer() {
        countdownTimer.invalidate()
        print(outliners)
        sendTestID = testPassedID
        performSegue(withIdentifier: "testOver", sender: self)
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    @IBAction func StartButtonPressed(_ sender: UIButton) {
        startTimer()
        running = true
        lblIsRunning.text = "RUNNING"
        results.removeAll()
        cleanResults.removeAll()
        outliners = 0
        startScanningForBeaconRegion(beaconRegion: getBeaconRegion())
        
    }
    
    
    
    // MARK: CSV File Saving Functions
    // MARK: Test Functions
    func getBeaconRegion() -> CLBeaconRegion {
        let beaconRegion = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: activeUUID)!, identifier: "com.llamaDigital.myRegion")
        return beaconRegion
    }
    
    func startScanningForBeaconRegion(beaconRegion: CLBeaconRegion) {
        //        print(beaconRegion)
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopScanningForBeaconRegion(beaconRegion: CLBeaconRegion) {
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    // Delegate Methods
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.YYYY HH:mm:ss"
            
            let testID = testPassedID
            let major = (beacon.major.stringValue)
            let minor = (beacon.minor.stringValue)
            let rssi = String(describing: beacon.rssi)
            let accuracy = String(format: "%.2f", (beacon.accuracy))
            var distance = ""
            let date = (formatter.string(from: currentDateTime))
            
            if beacon.proximity == CLProximity.unknown {
                print("OUTLINER LOCATION")
                outliners += 1
            } else if beacon.proximity == CLProximity.immediate {
                distance = "Immediate"
            } else if beacon.proximity == CLProximity.near {
                distance = "Near"
            } else if beacon.proximity == CLProximity.far {
                distance = "Far"
            }
            
//            if rssi == "0" {
//                print("OUTLINER RSSI")
//                outliners += 1
//            } else {
                testLine = major + "/" + minor + ", " + rssi + ", " + accuracy + ", " + distance
                
                cleanResults.append(testLine)
                
                
                let insertReading = self.resultsTable.insert(self.testID <- testID, self.major <- major, self.minor <- minor, self.rssi <- rssi, self.accuracy <- accuracy, self.distance <- distance, self.date <- date)
                
                do {
                    try self.database.run(insertReading)
                    print("INSERTED Reading")
                } catch {
                    print(error)
                }
//            }
            
        }
        cleanResults.append("----------------------------------")
        results = cleanResults.reversed()
        let string = results.joined(separator: "\n")
        txtResults.text = string
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TestOverVC
        {
            let vc = segue.destination as? TestOverVC
            vc?.readPassedID = self.sendTestID
        }
    }
    
}
