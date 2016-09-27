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
        router.all("/", middleware: StaticFileServer())
        
        // Basic GET request
        router.get("/hello", handler: getHello)
        
        // Basic POST request
        router.post("/hello", handler: postHello)
        
        // JSON Get request
        router.get("/json", handler: getJSON)
        
        router.get("/service", handler: { (request, response, next) in

            let resource = HttpResource.init(schema: "https", host: "microservicetwo.mybluemix.net", port: nil, path: "/json")
            HttpClient.get(resource: resource, headers: nil, completionHandler: { (erro, int, dic, data) in
                let jsonResponse = JSON(data: data!)
                response.status(HTTPStatusCode.OK).send(json: jsonResponse)
                next()

            })
        })
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
        jsonResponse["framework"].stringValue = "Microservice2"
        jsonResponse["applicationName"].stringValue = "Microservice2"
        jsonResponse["company"].stringValue = "Siavash"
        jsonResponse["organization"].stringValue = "Swift @ Siavash"
        jsonResponse["location"].stringValue = "Sydney, NSW"
        try response.status(.OK).send(json: jsonResponse).end()
    }
    
}
