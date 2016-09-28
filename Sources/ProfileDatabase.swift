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
    case fileError(Int, description: String)
}
struct ProfileDatabase {
    
    let dbHost = "localhost"
    let dbName = "profile"
    let dbUsername = "siavashabbasalipour"
    let dbPassword = ""
    
    init() {
        
    }
    
    func addToDB(fname: String, lname: String) throws -> Bool {
        
        //open postgre db
        let pgsl = PostgreSQL.PGConnection()
        _ = pgsl.connectdb("host='\(dbHost)' dbname='\(dbName)' user='\(dbUsername)' password='\(dbPassword)'")

        defer {
            pgsl.close()
        }
        
        guard pgsl.status() != .bad else {
            throw DBError.fileError(500, description: "Internal Server Error - failed to connect to db")
        }
        
        let query: String = "INSERT INTO account (fname, lname) VALUES ('\(fname)','\(lname)')"
        //execute query
        let queryResult = pgsl.exec(statement: query)
        
        guard queryResult.status() == .commandOK || queryResult.status() == .tuplesOK else {
            throw DBError.fileError(500, description: "Internal Server Error - db query error")
        }
        
        guard case let numberOfFields = queryResult.numFields() , numberOfFields != 0 else {
            throw DBError.fileError(500, description: "Internal Server Error - db returned nothing")
        }

        guard case let numberOfRows = queryResult.numTuples() , numberOfRows != 0 else {
            throw DBError.fileError(204, description: "Internal Server Error - query returned empty result")
        }
        return true
        
//        INSERT INTO films (code, title, did, date_prod, kind)
//        VALUES ('T_601', 'Yojimbo', 106, '1961-06-16', 'Drama');
    }
    
}
