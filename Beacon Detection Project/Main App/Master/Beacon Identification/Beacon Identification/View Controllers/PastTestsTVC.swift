//
//  PastTestsTVC.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 06/08/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit
import SQLite

var pastTest = pastTestInfo
var pastTestName = pastSearchNames
var pastTestInfoID = pastSearchIDs
var pastTestTimeLimit = pastSearchTimeLimits
var pastTestUUID = pastSearchUUIDs
var pastTestComment = pastSearchComments
var pastTestDate = pastSearchDates

var pastTestInfo = [String]()
var pastSearchNames = [String]()
var pastSearchIDs = [String]()
var pastSearchTimeLimits = [String]()
var pastSearchComments = [String]()
var pastSearchUUIDs = [String]()
var pastSearchDates = [String]()
var sendTestID = 0

var myPastTestIndex = 0

class PastTestsTVC: UITableViewController {
    
    // Database veribles
    var database: Connection!
    let id = Expression<Int>("id")
    let TestInfoTable = Table("testInfo")
    let resultsTable = Table("results")
    let testID = Expression<Int>("testID")
    let testName = Expression<String>("testName")
    let timeLimit = Expression<String>("timeLimit")
    let uuid = Expression<String>("uuid")
    let comments = Expression<String>("comments")
    let date = Expression<String>("date")
    var refresher: UIRefreshControl!
    
    // Search veribles
    var pastSearchData = ""
    var pastSearchName = ""
    var pastSearchID = ""
    var pastSearchTimeLimit = ""
    var pastSearchComment = ""
    var pastSearchUUID = ""
    var pastSearchDate = ""
    var rawName = ""
    
    //Removes Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("Beacon").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
            print("Reloaded")
            
        } catch {
            print(error)
        }
        for pastTest in try! database.prepare(TestInfoTable.select(id, testName, timeLimit, uuid, comments, date)) {
            pastSearchID = String(pastTest[id])
            pastSearchData = String(pastTest[id])
            pastSearchName = (pastTest[testName])
            pastSearchTimeLimit = (pastTest[timeLimit])
            pastSearchComment = (pastTest[comments])
            pastSearchUUID = (pastTest[uuid])
            pastSearchDate = (pastTest[date])
            pastTestInfo.append(pastSearchData)
            pastSearchIDs.append(pastSearchID)
            pastSearchNames.append(pastSearchName)
            pastSearchTimeLimits.append(pastSearchTimeLimit)
            pastSearchComments.append(pastSearchComment)
            pastSearchUUIDs.append(pastSearchUUID)
            pastSearchDates.append(pastSearchDate)
        }
        // SELECT "id", "testName" FROM "testInfo"
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(TableViewController.endUpdate), for: UIControl.Event.valueChanged)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(pastTest)
        return pastTest.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let searchID:Int? = Int(pastTest[indexPath.row])
        
        for testName in try! database.prepare(TestInfoTable.select(id, testName, date).filter(id == searchID!)) {
            rawName = ("\(testName[self.testName]): \(testName[self.date])")
        }
        cell.textLabel?.text = rawName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myPastTestIndex = indexPath.row
        performSegue(withIdentifier: "pastTestSegue", sender: self)
    }
    
}
