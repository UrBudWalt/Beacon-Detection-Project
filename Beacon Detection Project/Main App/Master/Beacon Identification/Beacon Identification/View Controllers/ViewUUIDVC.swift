//
//  ViewUUIDVC.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 25/07/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit
import SQLite

class ViewUUIDVC: UIViewController {
    
    @IBOutlet weak var txtUUID: UITextField!
    @IBOutlet weak var txtComments: UITextView!
    
    var rawID = ""
    var searchData = ""
    var searchArray = [String]()
    var CSVArray = [String]()
    
    // Database veribles
    var database: Connection!
    let UUIDsTable = Table("uuidTable")
    let id = Expression<Int>("id")
    let uuid = Expression<String>("uuid")
    let comments = Expression<String>("comments")
    
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
        
        txtUUID.text = uuidName[uuidIndex]
        txtComments.text = uuidComment[uuidIndex]
        rawID = uuidID[uuidIndex]
    }
    
    // MARK: UPDATE ENTRY
    @IBAction func btnUpdatePressed(_ sender: UIButton) {
        let UUIDInfoID:Int? = Int(rawID)
        let UpdateComment = UUIDsTable.filter(id == UUIDInfoID!)
        try! database.run(UpdateComment.update(comments <- txtComments.text))

        for showUpdate in try! database.prepare(UUIDsTable.select(id, uuid, comments).filter(id == UUIDInfoID!)) {
            txtUUID.text = ((showUpdate[self.uuid]))
            txtComments.text = ((showUpdate[self.comments]))
        }

    }
    

}
