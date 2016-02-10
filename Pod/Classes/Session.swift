//
//  Session.swift
//  Pods
//
//  Created by Erez Haim on 1/4/16.
//
//

import Foundation


class Session {
    
    static let sharedInstance = Session()
    
    var currentCall: Dictionary<String, AnyObject>?
    private var socket: Socket?
    private var callbacks : Dictionary<String, Array<((message: Dictionary<String, AnyObject>) -> Void)>> = [:]
    
    init() {
    }
    
    func handleMessage(message: Dictionary<String, AnyObject>){
        if let type = message["_type"] as? String{
            if let typeCallbacks = callbacks[type]{
                for callback in typeCallbacks{
                    callback(message: message)
                }
            }
        }
        
    }
    
    
    func connect(id: String, completion: (result: Dictionary<String, AnyObject>) -> Void) -> Void{
        RemoteAPI.sharedInstance.getCallById( id, completion: {result -> Void in
            if let session = result["session"] as? String{
                self.currentCall = result
                self.socket = Socket(fromString: session)
                self.socket?.connect({ (result) -> Void in
                    self.sendMessage("connection_created", data: ["firstTime": true])
                })
                self.socket?.onMessage(self.handleMessage)
                completion(result: [:])
            }

        })
    }
    
    func disconnect(){
        socket?.disconnect()
        socket = nil
        currentCall = nil
        callbacks = [:]
    }
    
    func sendMessage(type: String, data: Dictionary<String, AnyObject>){
        var message = data
        message["_type"] = type
        self.socket?.sendMessage(message)
        
    }
    
    func sendMessage(type: String, string: String){
        var message = ["string": string]
        message["_type"] = type
        self.socket?.sendMessage(message)
        
    }
    
    func onMessage(type: String, completion: (message: Dictionary<String, AnyObject>?) -> Void) -> Void{
        if nil == callbacks[type]{
            callbacks[type] = []
        }
        callbacks[type]?.append(completion)
    }
}