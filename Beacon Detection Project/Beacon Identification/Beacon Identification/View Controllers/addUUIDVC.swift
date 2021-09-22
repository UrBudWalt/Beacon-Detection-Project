//
//  addUUIDVC.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 26/07/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit
import SQLite

class addUUIDVC: UIViewController {
    @IBOutlet weak var txtUUID: UITextField!
    @IBOutlet weak var txtComment: UITextView!
    
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
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("Beacon").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
    }
    @IBAction func SaveNewUUID(_ sender: Any) {
        
        let uuid = txtUUID.text
        let comments = txtComment.text
        
        let insertReading = self.UUIDsTable.insert(self.uuid <- uuid!, self.comments <- comments!)
        
        do {
            try self.database.run(insertReading)
            print("INSERTED Test Details")
            performSegue(withIdentifier: "goBacktoUUID", sender: self)
            
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "goBacktoUUID", sender: self)
    }
    
    

}
