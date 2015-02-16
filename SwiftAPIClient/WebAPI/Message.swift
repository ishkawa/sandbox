import Foundation

class Message {
    let status: String!
    let body: String!
    let date: String!
    
    init?(dictionary: NSDictionary) {
        status = dictionary["status"] as? String
        body = dictionary["body"] as? String
        date = dictionary["created_on"] as? String
        
        if status == nil || body == nil || date == nil {
            return nil
        }
    }
}
