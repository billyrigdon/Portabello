import UIKit
import Flutter
import Foundation
import Network

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    
    private func scanPorts(ipAddress: String, startPort: Int, endPort: Int, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .background).async {
            var openPorts: [Int] = []

            for port in startPort...endPort {
                let semaphore = DispatchSemaphore(value: 0)
                let nwConnection = NWConnection(host: NWEndpoint.Host(ipAddress), port: NWEndpoint.Port(rawValue: UInt16(port))!, using: .tcp)

                nwConnection.stateUpdateHandler = { state in
                    switch state {
                    case .ready:
                        openPorts.append(port)
                        nwConnection.cancel()
                    default:
                        break
                    }
                    semaphore.signal()
                }

                nwConnection.start(queue: .global())
                semaphore.wait(timeout: .now() + 1) // Timeout of 1 second for each port
            }

            DispatchQueue.main.async {
                result(openPorts.map(String.init).joined(separator: ", "))
            }
        }
    }

    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let portScannerChannel = FlutterMethodChannel(name: "com.example.portabello/channel",
                                                      binaryMessenger: controller.binaryMessenger)
        
        portScannerChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Handle method call from Flutter
            if call.method == "scanPorts" {
                guard let args = call.arguments as? [String: Any],
                      let ipAddress = args["ipAddress"] as? String,
                      let startPort = args["startPort"] as? Int,
                      let endPort = args["endPort"] as? Int else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid iOS arguments", details: nil))
                    return
                }
                self.scanPorts(ipAddress: ipAddress, startPort: startPort, endPort: endPort, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
