//
//  UUIDTCV.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 25/07/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit
import SQLite


var uuidID = uuidInfo
var uuidName = searchUUIDNames
var uuidComment = searchUUIDComments
var UUIDInfoID = searchuuuidIDs

var uuidInfo = [String]()
var searchUUIDNames = [String]()
var searchUUIDComments = [String]()
var searchuuuidIDs = [String]()

var uuidIndex = 0

class UUIDTCV: UITableViewController {
    
    // Shared Database veribles
    var database: Connection!
    let UUIDsTable = Table("uuidTable")
    let id = Expression<Int>("id")
    let uuid = Expression<String>("uuid")
    let comments = Expression<String>("comments")
    var refresher: UIRefreshControl!
    
    var UUIDInfoID = ""
    var searchUUIDName = ""
    var searchUUIDComment = ""
    var rawName = ""
    
    //Removes Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("Beacon").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
            print("Reloaded")
            
        } catch {
            print(error)
        }
        
        for uuidID in try! database.prepare(UUIDsTable.select(id, uuid, comments)) {
            UUIDInfoID = String(uuidID[id])
            searchUUIDName = (uuidID[uuid])
            searchUUIDComment = (uuidID[comments])
            
            uuidInfo.append(UUIDInfoID)
            searchUUIDNames.append(searchUUIDName)
            searchUUIDComments.append(searchUUIDComment)
            searchuuuidIDs.append(UUIDInfoID)
        }
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(TableViewController.endUpdate), for: UIControl.Event.valueChanged)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(uuidID)
        return uuidID.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let UUIDInfoID:Int? = Int(uuidID[indexPath.row])
        
        for uuidName in try! database.prepare(UUIDsTable.select(id, uuid, comments).filter(id == UUIDInfoID!)) {
            rawName = ("\(uuidName[self.uuid])")
        }
        cell.textLabel?.text = rawName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        uuidIndex = indexPath.row
        performSegue(withIdentifier: "segueUUID", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            let UUIDInfoID:Int? = Int(uuidID[indexPath.row])
            print(uuidID[indexPath.row])
            uuidID.remove(at: indexPath.row)
            
            let deleteTest = UUIDsTable.filter(id == UUIDInfoID!)
            try! database.run(deleteTest.delete())
            
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
