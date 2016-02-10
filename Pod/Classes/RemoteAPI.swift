//
//  RemoteAPI.swift
//  Pods
//
//  Created by Erez Haim on 1/4/16.
//
//

import Foundation
import AFNetworking


class RemoteAPI {
    //private let SERVER_URL = "http://10.0.0.4:8000"
    //private let SERVER_URL = "http://172.20.11.86:8000"
    //private let SERVER_URL = "http://127.0.0.1:8000"
    //private let SERVER_URL = "http://172.20.9.243:8000"
    //private let SERVER_URL = "http://livemed-front-dev.elasticbeanstalk.com"
    private let SERVER_URL: String
    private var token = ""
    static let sharedInstance = RemoteAPI()
    
    enum RequestType{
        case POST
        case GET
        case DELETE
        case PATCH
        case PUT
    }
    
    
    init() {
        print("hello")
        
        if let url = NSBundle.mainBundle().infoDictionary?["LiveMedURL"] as? String{
            SERVER_URL = url
        } else {
            SERVER_URL = "http://127.0.0.1:8000"
        }
        
    }
    
    private func getArrayResult(result: AnyObject) ->Array<Dictionary<String, AnyObject>> {
        if let res = result as? Array<Dictionary<String, AnyObject>> {
            return res
        } else {
            return []
        }
    }
    
    private func getDictionaryResult(result: AnyObject) ->Dictionary<String, AnyObject> {
        if let res = result as? Dictionary<String, AnyObject> {
            return res
        } else {
            return [:]
        }
    }
    
    private func getStringResult(result: AnyObject) ->NSString {
        if let data = result as? NSData{
            if let res = NSString(data: data, encoding: NSUTF8StringEncoding){
                return res.stringByReplacingOccurrencesOfString("\"", withString: "", options: [], range: NSMakeRange(0,res.length))
            } else {
                return ""
            }
        }
        return ""
    }
    
    private func getBoolResult(result: AnyObject) ->Bool {
        if let res = result as? Bool {
            return res
        } else {
            return false
        }
    }
    
    func getCallById (id: String, completion: (result: Dictionary<String, AnyObject>) -> Void) -> Void{
        self.http("/calls/\(id)/", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    
    func connectToSocket(data: Dictionary<String, AnyObject>, completion: (result: Dictionary<String, AnyObject>) -> Void) -> Void{
        self.http("/sockets/connect/", message: data, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    func sendMessageToSocket(data: Dictionary<String, AnyObject>, completion: (result: Dictionary<String, AnyObject>) -> Void) -> Void{
        self.http("/sockets/messages/", message: data, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    func getMessagesFromSocket(data: Dictionary<String, AnyObject>, completion: (result: Array<Dictionary<String, AnyObject>>) -> Void) -> Void{
        self.http("/sockets/messages/", message: data, completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    func newSignature(data: Dictionary<String, AnyObject>, completion: (result: Dictionary<String, AnyObject>) -> Void) -> Void{
        self.http("/signatures/", message: data, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    func getAFManager(isJSONRequest: Bool) -> AFHTTPSessionManager{
        let manager = AFHTTPSessionManager()
        if (isJSONRequest){
            manager.requestSerializer = AFJSONRequestSerializer()
            manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
            manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        } else {
            manager.responseSerializer = AFHTTPResponseSerializer()
        }
        if (self.token != ""){
            manager.requestSerializer.setValue("Token", forHTTPHeaderField: "WWW-Authenticate")
            manager.requestSerializer.setValue("Token \(self.token)", forHTTPHeaderField: "Authorization")
        }
        return manager
    }
    
    func getResponseHandler(completion: (result: AnyObject) -> Void) -> (operation: NSURLSessionDataTask, responseObject: AnyObject?) -> Void{
        return {(operation: NSURLSessionDataTask ,responseObject: AnyObject?) in
            if responseObject != nil{
                completion(result: responseObject!)
            } else {
                completion(result: false)
            }
        }
    }
    
    func getErrorHandler(completion: (result: AnyObject) -> Void) -> (operation: NSURLSessionDataTask?, error: NSError) -> Void{
        return {(operation: NSURLSessionDataTask?, error: NSError) in
            completion(result: false)
            self.printError(error)
            print("Error: " + error.localizedDescription)
        }
    }
    
    func printError(error:NSError){
        if let info = error.userInfo as? Dictionary<String, AnyObject>{
            if let data = info["com.alamofire.serialization.response.error.data"] as? NSData{
                if let res = NSString(data: data, encoding: NSUTF8StringEncoding){
                    print(res)
                    res.stringByReplacingOccurrencesOfString("\"", withString: "", options: [], range: NSMakeRange(0,res.length))
                } else {
                }
            }
        }
    }
    
    func http(url: String, message: Dictionary<String, AnyObject>? = nil, isJSONRequest: Bool = true, method: RequestType = .GET, useURLPrefix: Bool = true, completion: (result: AnyObject) -> Void) -> Void{
        let manager = getAFManager(isJSONRequest)
        let requestUrl = useURLPrefix ? SERVER_URL + url : url
        
        switch method{
        case .POST:
            manager.POST(requestUrl, parameters: message, progress: nil, success: getResponseHandler(completion), failure: getErrorHandler(completion))
            break
        case .GET:
            manager.GET(requestUrl, parameters: message, progress: nil, success: getResponseHandler(completion),failure: getErrorHandler(completion))
            break
        case .PATCH:
            manager.PATCH(requestUrl, parameters: message, success: getResponseHandler(completion),failure: getErrorHandler(completion))
            break
        case .PUT:
            manager.PUT(requestUrl, parameters: message, success: getResponseHandler(completion),failure: getErrorHandler(completion))
            break
        case .DELETE:
            manager.DELETE(requestUrl, parameters: message, success: getResponseHandler(completion),failure: getErrorHandler(completion))
            break
        }
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func uploadFile(data: NSData, filename:String, mimetype: String = "image/jpeg", completion: (result: AnyObject) -> Void) -> Void{
        let request = NSMutableURLRequest(URL: NSURL(string: SERVER_URL + "/resources/upload/")!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "PUT"
        let boundary = generateBoundaryString()
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()
        let mimetype = mimetype
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(data)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        request.HTTPBody = body
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if (response == nil || (response as! NSHTTPURLResponse).statusCode > 299){
                completion(result: [:])
                return
            }
        })
        task.resume()
    }
}

extension NSMutableData {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}