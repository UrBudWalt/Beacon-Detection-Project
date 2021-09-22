//
//  TestSetupVC.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 02/07/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//
//Ad date stamp


import UIKit
import SQLite

class TestSetupVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // Database veribles
    var database: Connection!
    let UUIDsTable = Table("uuidTable")
    let id = Expression<Int>("id")
    let TestInfoTable = Table("testInfo")
    let testName = Expression<String>("testName")
    let timeLimit = Expression<String>("timeLimit")
    let uuid = Expression<String>("uuid")
    let comments = Expression<String>("comments")
    let date = Expression<String>("date")
    var sendTime = 0
    var sentName = ""
    var sendUUID = ""
    var searchUUIDName = ""
    var goHome = true
    var errorType = ""
    var sendTestID = 0
    var pickerData: [String] = [String]()
    var selectedUUID: String = ""
    
    @IBOutlet weak var txtTestName: UITextField!
    @IBOutlet weak var txtTimeLimit: UITextField!
    @IBOutlet weak var txtComments: UITextView!
    @IBOutlet weak var UUIDPickerView: UIPickerView!
    
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
        
        pickerData.append("Select Test UUID: ")
        for uuidID in try! database.prepare(UUIDsTable.select(id, uuid, comments)) {
            searchUUIDName = (uuidID[uuid])
            pickerData.append(searchUUIDName)
            print(pickerData)
        }
        self.UUIDPickerView.delegate = self
        self.UUIDPickerView.dataSource = self
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUUID = (pickerData[row])
        print("selected: \(pickerData[row])")
        
    }
    
    @IBAction func SaveTestSetup(_ sender: UIButton) {
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY HH:mm:ss"
        print(formatter.string(from: currentDateTime))
        
        let testName = txtTestName.text
        sentName = txtTestName.text!
        let timeLimit = txtTimeLimit.text
        let uuid = selectedUUID
        let comments = txtComments.text
        let testDate = (formatter.string(from: currentDateTime))
        
        if txtTestName.text == "" {
            errorType = "Test Name is empty"
            alert()
        } else if txtTimeLimit.text == "" {
            errorType = "Time Limit Text box is empty"
            alert()
        } else if txtComments.text == "" {
            errorType = "Comments Text box is empty"
            alert()
        } else {
            let insertReading = self.TestInfoTable.insert(self.testName <- testName!, self.timeLimit <- timeLimit!, self.uuid <- uuid, self.comments <- comments!, self.date <- testDate)
            do {
                try self.database.run(insertReading)
                
                for testIDLookUp in try! database.prepare(TestInfoTable.select(id, date).filter(date == testDate)) {
                    sendTestID = ((testIDLookUp[self.id]))
                }
                
                let cleanTime:Int = Int(txtTimeLimit.text!)!
                sendTime = cleanTime
                print("INSERTED Test Details")
                performSegue(withIdentifier: "toTest", sender: self)
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toMainSegue", sender: self)
    }
    
    func alert(){
        let alert = UIAlertController(title: "Alert", message: errorType, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TestVC
        {
            let vc = segue.destination as? TestVC
            vc?.testTime = self.sendTime
            vc?.testName = self.sentName
            vc?.testPassedID = self.sendTestID
            vc?.activeUUID = self.selectedUUID
        }
    }
    
}
