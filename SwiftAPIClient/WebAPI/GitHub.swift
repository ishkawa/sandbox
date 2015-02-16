import Foundation

class Box<T> {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

protocol Request {
    var method: String { get }
    var path: String { get }

    typealias Response: Any

    func convertJSONObject(object: AnyObject) -> Response?
}

// adopt Box to avoid "unimplemented IR generation feature non-fixed multi-payload enum layout"
enum Response<T> {
    case Success(Box<T>)
    case Failure(Box<NSError>)
    
    init(_ value: T) {
        self = .Success(Box(value))
    }
        
    init(_ error: NSError) {
        self = .Failure(Box(error))
    }
}

class GitHub {
    let scheme = "https"
    let host = "status.github.com"
    let URLSession = NSURLSession.sharedSession()
    
    func call<T: Request>(request: T, handler: (Response<T.Response>) -> Void = { r in }) {
        let URL = NSURL(scheme: scheme, host: host, path: request.path)!
        let URLRequest = NSURLRequest(URL: URL)
        let task = URLSession.dataTaskWithRequest(URLRequest) { data, URLResponse, connectionError in
            if let error = connectionError {
                handler(Response(error))
                return
            }

            var parseError: NSError?
            let JSONObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(data,
                options: nil,
                error: &parseError)

            if let error = parseError {
                handler(Response(error))
                return
            }

            let statusCode = (URLResponse as? NSHTTPURLResponse)?.statusCode
            switch (statusCode, request.convertJSONObject(JSONObject)) {
            case (.Some(200..<300), .Some(let response)):
                handler(Response(response))

            default:
                let userInfo = [NSLocalizedDescriptionKey: "unresolved error occurred."]
                let error = NSError(domain: "WebAPIErrorDomain", code: 0, userInfo: userInfo)
                handler(Response(error))
            }
        }

        task.resume()
    }
}

extension GitHub {
    class LastMessageRequest: Request {
        let method = "GET"
        let path = "/api/last-message.json"

        typealias Response = Message

        func convertJSONObject(object: AnyObject) -> Response? {
            var message: Message?

            if let dictionary = object as? NSDictionary {
                message = Message(dictionary: dictionary)
            }

            return message
        }
    }
    
    class MessagesRequest: Request {
        let method = "GET"
        let path = "/api/messages.json"
        
        typealias Response = [Message]

        func convertJSONObject(object: AnyObject) -> Response? {
            var messages = [Message]()

            if let dictionaries = object as? [NSDictionary] {
                for dictionary in dictionaries {
                    if let message = Message(dictionary: dictionary) {
                        messages.append(message)
                    }
                }
            }

            return messages
        }
    }
}
