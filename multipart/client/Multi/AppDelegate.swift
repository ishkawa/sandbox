import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let path = NSBundle.mainBundle().pathForResource("input", ofType: "png")!
        let stream = PKMultipartInputStream()
        stream.addPartWithName("input.png", path: path)

        let url = NSURL(string: "http://localhost:3000")!
        let request = NSMutableURLRequest(URL: url)
        request.setValue("multipart/form-data; boundary=\(stream.boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(stream.length)", forHTTPHeaderField: "Content-Length")
        request.HTTPBodyStream = stream
        request.HTTPMethod = "POST"

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                println("error: \(error)")
            } else {
                println("done.")
            }
        }

        task.resume()

        return true
    }
}
