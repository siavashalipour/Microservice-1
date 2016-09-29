//
//  ProfileDatabase.swift
//  Microservice1
//
//  Created by Siavash Abbasalipour on 28/9/16.
//
//

import Foundation
import PostgreSQL

enum DBError: Error {
    case fileError(String)
}
struct ProfileDatabase {
    
    let dbHost = "sl-us-dal-9-portal.3.dblayer.com"
    let dbName = "compose"
    let dbUsername = "admin"
    let dbPassword = "QZKXGSDVRFDSKZNQ"
    let dbPort = 15348
    init() {
        
    }
    
    func addToDB(fname: String, lname: String) throws -> Bool {
        
        //open postgre db
        let pgsl = PostgreSQL.PGConnection()
        _ = pgsl.connectdb("host='\(dbHost)' port='\(dbPort)' dbname='\(dbName)' user='\(dbUsername)' password='\(dbPassword)'")
        
        defer {
            pgsl.close()
        }
        
        guard pgsl.status() != .bad else {
            throw DBError.fileError("Internal Server Error - failed to connect to db")
        }
        
        let query: String = "INSERT INTO account (fname, lname) VALUES ('\(fname)','\(lname)');"
        //execute query
        let queryResult = pgsl.exec(statement: query)
        
        guard queryResult.status() == .commandOK else {
            throw DBError.fileError("Internal Server Error - db query error")
        }
        
        return true
    }
    
}
