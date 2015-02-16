import UIKit

class ViewController: UIViewController {
    let github = GitHub()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        github.call(GitHub.LastMessageRequest()) { response in
            var title: String
            var message: String
            
            switch response {
            case .Success(let box):
                title = "Status: \(box.value.status)"
                message = box.value.body
                
            case .Failure(let box):
                title = "Error"
                message = box.value.localizedDescription
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
