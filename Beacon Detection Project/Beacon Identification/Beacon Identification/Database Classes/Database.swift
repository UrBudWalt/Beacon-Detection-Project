//
//  Database.swift
//  Beacon Identification
//
//  Created by Walter Bassage on 11/07/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import Foundation
import SQLite

class Database {
    static let shared = Database()
    public let connection: Connection?
    public let databaseFileName = ".sqlite3"
    private init() {
        let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as String?
        do {
            connection = try Connection("\(dbPath!)/(databaseFileName)")
        } catch {
            connection = nil
            let nserror = error as NSError
            print("Cannot connect to Database. Error is: \(nserror), \(nserror.userInfo)")
        }
    }
}
