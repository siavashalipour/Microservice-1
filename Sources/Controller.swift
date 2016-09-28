//
//  Controller.swift
//  Microservice2
//
//  Created by Siavash on 26/9/16.
//
//

import Foundation
import Kitura
import SwiftyJSON
import LoggerAPI
import CloudFoundryEnv
import KituraNet
import SimpleHttpClient

public class Controller {
    
    let router: Router
    let appEnv: AppEnv

    var port: Int {
        get { return appEnv.port }
    }
    
    var url: String {
        get { return appEnv.url }
    }
    
    init() throws {
        appEnv = try CloudFoundryEnv.getAppEnv()
        
        // All web apps need a Router instance to define routes
        router = Router()
        
        // Serve static content from "public"
        //router.all("/", middleware: StaticFileServer())
        router.all("/*", middleware: BodyParser())
        // Basic GET request
        router.get("/hello", handler: getHello)
        
        // Basic POST request
        router.post("/hello", handler: postHello)
        
        // JSON Get request
        router.get("/json", handler: getJSON)
        
        router.get("/service", handler: { (request, response, next) in

            let resource = HttpResource.init(schema: "https", host: "Microservice2.mybluemix.net", port: nil, path: "/json")
            HttpClient.get(resource: resource, headers: nil, completionHandler: { (erro, int, dic, data) in
                let jsonResponse = JSON(data: data!)
                response.status(HTTPStatusCode.OK).send(json: jsonResponse)
                next()

            })
        })
        
        router.get("/dev", handler: getDev)
        router.get("/master", handler: getMaster)
        router.post("/addtodb", handler: postToDB)
    }
    
    public func postToDB(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("POST - /addtodb route handler...")
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        var jsonResponse = JSON([:])
        if let body = request.body {
            switch body {
            case .json(let json):
                let fname = json["fname"].stringValue
                let lname = json["lname"].stringValue
                do {
                    if try ProfileDatabase().addToDB(fname: fname, lname: lname) {
                        jsonResponse["message"].stringValue = "Success"
                        try response.status(.OK).send(json: jsonResponse).end()
                    } else {
                        jsonResponse["message"].stringValue = "Fail"
                        try response.status(.methodFailure).send(json: jsonResponse).end()
                    }

                } catch DBError.fileError(let s) {
                    jsonResponse["message"].stringValue = s
                    try response.status(.methodFailure).send(json: jsonResponse).end()
                }
            default:
                break
            }
        }
        jsonResponse["message"].stringValue = "Empty Body"
        try response.status(.badRequest).send(json: jsonResponse).end()
    }
    
    public func getMaster(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("GET - /json route handler...")
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        var jsonResponse = JSON([:])
        jsonResponse["framework"].stringValue = "Microservice1-Master"
        jsonResponse["applicationName"].stringValue = "Microservice1-Master"
        try response.status(.OK).send(json: jsonResponse).end()
    }
    
    public func getDev(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("GET - /json route handler...")
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        var jsonResponse = JSON([:])
        jsonResponse["framework"].stringValue = "Microservice1-DEV"
        jsonResponse["applicationName"].stringValue = "Microservice1-DEV"
        try response.status(.OK).send(json: jsonResponse).end()
    }
    
    public func getHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("GET - /hello route handler...")
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        try response.status(.OK).send("Hello from Kitura-Starter-Bluemix!").end()
    }
    
    public func postHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("POST - /hello route handler...")
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        if let name = try request.readString() {
            try response.status(.OK).send("Hello \(name), from Kitura-Starter-Bluemix!").end()
        } else {
            try response.status(.OK).send("Kitura-Starter-Bluemix received a POST request!").end()
        }
    }
    
    public func getJSON(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("GET - /json route handler...")
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        var jsonResponse = JSON([:])
        jsonResponse["framework"].stringValue = "Microservice1"
        jsonResponse["applicationName"].stringValue = "Microservice1"
        jsonResponse["company"].stringValue = "Siavash"
        jsonResponse["organization"].stringValue = "Swift @ Siavash"
        jsonResponse["location"].stringValue = "Sydney, NSW"
        try response.status(.OK).send(json: jsonResponse).end()
    }
    
}
