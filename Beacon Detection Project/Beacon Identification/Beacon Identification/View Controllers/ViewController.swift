//
//  ViewController.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 15/06/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit
import CoreLocation
import SQLite

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    // Shared Database veribles
    var database: Connection!
    let resultsTable = Table("results")
    let TestInfoTable = Table("testInfo")
    let UUIDsTable = Table("uuidTable")
    let id = Expression<Int>("id")
    var test: Connection!
    var testTime = 0
    let uuid = Expression<String>("uuid")
    let comments = Expression<String>("comments")
    
    
    // Table testInfo varibles
    let testName = Expression<String>("testName")
    let timeLimit = Expression<String>("timeLimit")
    let date = Expression<String>("date")
    
    // Table results veribles
    let testID = Expression<Int>("testID")
    let major = Expression<String>("major")
    let minor = Expression<String>("minor")
    let rssi = Expression<String>("rssi")
    let accuracy = Expression<String>("accuracy")
    let distance = Expression<String>("distance")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For location Approval
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // Create Database
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("Beacon").appendingPathExtension("sqlite3")
            let db = try Connection(fileUrl.path)
            self.database = db
            test = db
            print("DB is Live!")
            
            try db.run(TestInfoTable.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                table.column(self.id, primaryKey: true)
                table.column(self.testName)
                table.column(self.timeLimit)
                table.column(self.uuid)
                table.column(self.comments)
                table.column(self.date)
            }))
            
            try db.run(resultsTable.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                table.column(self.id, primaryKey: true)
                table.column(self.testID)
                table.column(self.major)
                table.column(self.minor)
                table.column(self.rssi)
                table.column(self.accuracy)
                table.column(self.distance)
                table.column(self.date)
            }))
            
            try db.run(UUIDsTable.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                table.column(self.id, primaryKey: true)
                table.column(self.uuid)
                table.column(self.comments)
            }))
            
        } catch {
            print("An Error occoured :(")
            print(error)
        }
    }
    
    //Removes Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
}

