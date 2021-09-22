//
//  ViewTestDataVC.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 03/07/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

// Show cells of test

import UIKit
import SQLite

class ViewTestDataVC: UIViewController {
    
    
    //    DB Variables
    var database: Connection!
    let id = Expression<Int>("id")
    let resultsTable = Table("results")
    let testID = Expression<Int>("testID")
    let major = Expression<String>("major")
    let minor = Expression<String>("minor")
    let rssi = Expression<String>("rssi")
    let accuracy = Expression<String>("accuracy")
    let distance = Expression<String>("distance")
    
    // Database veribles
    let TestInfoTable = Table("testInfo")
    let testName = Expression<String>("testName")
    let timeLimit = Expression<String>("timeLimit")
    let uuid = Expression<String>("uuid")
    let comments = Expression<String>("comments")
    
    // Search Varibles
    var testInfo = false
    var results = false
    var searchArray = [String]()
    var searchData = ""
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var txtSearchResults: UITextView!
    @IBOutlet weak var switchSearch: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func searchIndexChanged(_ sender: UISegmentedControl) {
        switch switchSearch.selectedSegmentIndex
        {
        case 0: // Sets testInfo to true when switchSearch is set on Test Info
            testInfo = true
            results =  false
        case 1:// Sets results to true when switchSearch is set on Results
            results = true
            testInfo = false
        default:
            break
        }
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchArray.removeAll()
        
        if results == true {
            do {
                let results = try self.database.prepare(self.resultsTable)
                for result in results {
                    searchData = ("ID: \(result[self.id]), TestID: \(result[self.testID]), \(result[self.major])/ \(result[self.minor]), \(result[self.rssi]), \(result[self.accuracy]), \(result[self.distance])")
                    searchArray.append(searchData)
                }
                let string = searchArray.joined(separator: "\n")
                txtSearchResults.text = string
            } catch {
                print(error)
            }
            
        } else if testInfo == true {
            do {
                let tests = try self.database.prepare(self.TestInfoTable)
                for test in tests {
                    searchData = ("Test ID: \(test[self.id]) \nTest Name: \(test[self.testName])\nTime Limit: \(test[self.timeLimit])\nUUID: \(test[self.uuid])\nComments: \(test[self.comments])\n")
                    searchArray.append(searchData)
                }
                let string = searchArray.joined(separator: "\n")
                txtSearchResults.text = string
            } catch {
                print(error)
            }
            
        }
        
    }
    
}
