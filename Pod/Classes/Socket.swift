//
//  Socket.swift
//  Pods
//
//  Created by Erez Haim on 1/5/16.
//
//

import Foundation

class Socket: NSObject {
    
    private let name: String
    private let sender: String
    private var socket: Int?
    private var timer: NSTimer?
    private let DEFAULT_INTERVAL = 1
    private var callbacks : Array<((message: Dictionary<String, AnyObject>) -> Void)> = []
    
    init(fromString name: NSString) {
        self.name = name as String
        self.sender = NSUUID().UUIDString
        super.init()
    }
    
    convenience override init() {
        self.init(fromString:"") // calls above mentioned controller with default name
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            var json: [String:AnyObject]?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as? [String : AnyObject]
            } catch let error as NSError {
                print (error)
                json = nil
            } catch {
                fatalError()
            }
            return json
        }
        return nil
    }

    
    func requestForMessages(){
        RemoteAPI.sharedInstance.getMessagesFromSocket(["socket": socket!, "sender": sender]) { (result) -> Void in
            for message in result{
                for callback in self.callbacks{
                    if let dataStr = message["data"] as? String{
                        if let data = self.convertStringToDictionary(dataStr){
                            callback(message: data)
                        }
                    } else {
                        //print(message["data"])
                    }
                    
                }
                
            }
        }
    }
    
    func registerForMessages(){
        timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(DEFAULT_INTERVAL), target: self, selector: Selector("requestForMessages"), userInfo: AnyObject?(), repeats: true)
    }
    
    
    func connect(completion: (result: Bool) -> Void) -> Void{
        RemoteAPI.sharedInstance.connectToSocket(["name": self.name]) { (result) -> Void in
            if let socket = result["id"] as? Int{
                self.socket = socket
                self.registerForMessages()
                self.sendMessage(["_type": "connected" ,"connected":true])
                completion(result: true)
            } else {
                completion(result: false)
            }
        }
    }
    
    func disconnect(){
        timer?.invalidate()
        socket = nil
        callbacks = []
    }
    
    func sendMessage(message: Dictionary<String, AnyObject>){
        if nil != socket {
            RemoteAPI.sharedInstance.sendMessageToSocket(["sender": sender, "socket": socket!, "data": message]) { (result) -> Void in
                //
            }
        }
        
    }
    
    func onMessage(completion: (message: Dictionary<String, AnyObject>) -> Void) -> Void{
        callbacks.append(completion)
    }
}
