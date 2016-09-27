import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import CloudFoundryEnv
import CloudFoundryDeploymentTracker

do {
    // HeliumLogger disables all buffering on stdout
    HeliumLogger.use(LoggerMessageType.info)
    let controller = try Controller()
    Log.info("Server will be started on '\(controller.url)'.")
    CloudFoundryDeploymentTracker(repositoryURL: "https://github.com/siavashalipour/Microservice1.git", codeVersion: nil).track()
    Kitura.addHTTPServer(onPort: controller.port, with: controller.router)
    // Start Kitura-Starter-Bluemix server
    Kitura.run()
} catch let error {
    Log.error(error.localizedDescription)
    Log.error("Oops... something went wrong. Server did not start!")
}
