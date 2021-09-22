//
//  TableVC.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 17/07/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit
import MessageUI
import SQLite

class TableVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtResults: UITextView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblUUID: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var txtComments: UITextView!
    @IBOutlet weak var lblTestID: UILabel!
    
    var rawID = ""
    var searchData = ""
    var searchArray = [String]()
    var CSVArray = [String]()
    
    // Database veribles
    var database: Connection!
    var csvFile: Connection!
    var test: Connection!
    let id = Expression<Int>("id")
    let TestInfoTable = Table("testInfo")
    let resultsTable = Table("results")
    let testID = Expression<Int>("testID")
    let major = Expression<String>("major")
    let minor = Expression<String>("minor")
    let rssi = Expression<String>("rssi")
    let accuracy = Expression<String>("accuracy")
    let distance = Expression<String>("distance")
    let date = Expression<String>("date")
    let comments = Expression<String>("comments")
    let countSecond = Expression<Int>("countSecond")
    
    
    
    
    //Removes Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("Beacon").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        lblTitle.text = testName[myIndex]
        lblTime.text = testTimeLimit[myIndex]
        lblUUID.text = testUUID[myIndex]
        txtComments.text = testComment[myIndex]
        rawID = testInfoID[myIndex]
        lblTestID.text = rawID
        lblDate.text = testDate[myIndex]
        let searchID:Int? = Int(rawID)
        
        for result in try! database.prepare(resultsTable.select(id, major, minor, rssi, accuracy, distance, testID, date, countSecond).filter(testID == searchID!)) {
            searchData = ("\(result[self.major])/ \(result[self.minor]), \(result[self.rssi]), \(result[self.accuracy]), \(result[self.distance]), \(result[self.date])")
            searchArray.append(searchData)
        }
        let string = searchArray.joined(separator: "\n")
        txtResults.text = string
    }
    
    
    // MARK: UPDATE ENTRY
    @IBAction func btnUpdatePressed(_ sender: UIButton) {
        let searchID:Int? = Int(rawID)
        let UpdateComment = TestInfoTable.filter(id == searchID!)
        try! database.run(UpdateComment.update(comments <- txtComments.text))
        
        for showUpdate in try! database.prepare(TestInfoTable.select(id, comments).filter(id == searchID!)) {
            txtComments.text = ((showUpdate[self.comments]))
        }
        
    }
    
    //MARK: EXPORT AND EMAIL FILE
    @IBAction func btnExportPressed(_ sender: UIButton) {
            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent(testName[myIndex]).appendingPathExtension("csv")
            let csvFile = try! Connection(fileUrl.path)
            self.csvFile = csvFile
            test = csvFile
            print("I Can see the File")

            // Writing to File
            let csvText = "major,minor,rssi,accuracy,distance,date,second"
            CSVArray.append(csvText)
            if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil {
                let searchID:Int? = Int(rawID)
                for result in try! database.prepare(resultsTable.select(major, minor, rssi, accuracy, distance, testID, date, countSecond).filter(testID == searchID!)) {
                    let newLine = ("\(result[self.major]),\(result[self.minor]),\(result[self.rssi]),\(result[self.accuracy]),\(result[self.distance]),\(result[self.date])")
                    CSVArray.append(newLine)
                }
                let fileData = CSVArray.joined(separator: "\n")
                

                //writing
                do {
                    try fileData.write(to: fileUrl, atomically: false, encoding: .utf8)
                    if MFMailComposeViewController.canSendMail() {
                        let mail = MFMailComposeViewController()
                        mail.mailComposeDelegate = self
                        mail.addAttachmentData(NSData(contentsOf: fileUrl)! as Data, mimeType: "text/csv", fileName: "\(testName[myIndex]).csv")
                        present(mail, animated: true)
                    } else {
                        print("Error")
                    }
                    print("All Done")
                }
                catch {
                    print(error)
                }
            }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,error: Error?) {
        switch (result) {
        case .cancelled:
            self.dismiss(animated: true, completion: nil)
        case .sent:
            self.dismiss(animated: true, completion: nil)
        case .failed:
            self.dismiss(animated: true, completion: {
                let sendMailErrorAlert = UIAlertController.init(title: "Failed", message: "Unable to send email. Please check your email " + "settings and try again.", preferredStyle: .alert)
                sendMailErrorAlert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                self.present(sendMailErrorAlert, animated: true, completion: nil)
            })
        default: break
        }
    }
}
