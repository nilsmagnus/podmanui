import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
        FlutterMethodChannel.init(name: "no.nils.podmanui/desktop", binaryMessenger: controller.engine.binaryMessenger).setMethodCallHandler({
            (_ call: FlutterMethodCall, _ result: FlutterResult) -> Void in
            result(call.method.runCmd())
        })
    }
}

extension String {
    func runCmd() -> String? {
        let pipe = Pipe()
        let process = Process()
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", self]
        process.standardOutput = pipe
        let fileHandle = pipe.fileHandleForReading
        process.launch()
        
        return String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
    }
}
