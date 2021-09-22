//
//  TableViewController.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 17/07/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit
import SQLite

var test = testInfo
var testName = searchNames
var testInfoID = searchIDs
var testTimeLimit = searchTimeLimits
var testUUID = searchUUIDs
var testComment = searchComments
var testDate = searchDates
//var lookupName = lookUpNames

var testInfo = [String]()
var searchNames = [String]()
var searchIDs = [String]()
var searchTimeLimits = [String]()
var searchComments = [String]()
var searchUUIDs = [String]()
var searchDates = [String]()

var myIndex = 0

class TableViewController: UITableViewController {
    
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
    var searchData = ""
    var searchName = ""
    var searchID = ""
    var searchTimeLimit = ""
    var searchComment = ""
    var searchUUID = ""
    var searchDate = ""
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
        for test in try! database.prepare(TestInfoTable.select(id, testName, timeLimit, uuid, comments, date)) {
            searchID = String(test[id])
            searchData = String(test[id])
            searchName = (test[testName])
            searchTimeLimit = (test[timeLimit])
            searchComment = (test[comments])
            searchUUID = (test[uuid])
            searchDate = (test[date])
            testInfo.append(searchData)
            searchIDs.append(searchID)
            searchNames.append(searchName)
            searchTimeLimits.append(searchTimeLimit)
            searchComments.append(searchComment)
            searchUUIDs.append(searchUUID)
            searchDates.append(searchDate)
        }
        // SELECT "id", "testName" FROM "testInfo"
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(TableViewController.endUpdate), for: UIControl.Event.valueChanged)
    }
    
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(test)
        return test.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let searchID:Int? = Int(test[indexPath.row])
        
        for testName in try! database.prepare(TestInfoTable.select(id, testName, date).filter(id == searchID!)) {
            rawName = ("\(testName[self.testName]): \(testName[self.date])")
        }
        cell.textLabel?.text = rawName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        performSegue(withIdentifier: "segue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            let searchID:Int? = Int(test[indexPath.row])
            print(test[indexPath.row])
            test.remove(at: indexPath.row)
            
            let deleteTest = TestInfoTable.filter(id == searchID!)
            try! database.run(deleteTest.delete())
            
            let deleteResults = resultsTable.filter(testID == searchID!)
            try! database.run(deleteResults.delete())
            
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    @objc func endUpdate(){
        tableView.reloadData()
        refresher.endRefreshing()
    }
    
}
