//
//  LabelAPI.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 8/13/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//

import Foundation


// MARK : Get messages part
public class GetLabelsRequest<T : ApiResponse> : ApiRequest<T> {
    
    override init() {
    }
    
    override func getAPIMethod() -> APIService.HTTPMethod {
        return .GET
    }
    
    override public func getRequestPath() -> String {
        return LabelAPI.Path + AppConstants.getDebugOption
    }
    
    override public func getVersion() -> Int {
        return LabelAPI.V_LabelFetchRequest
    }
}

public class GetLabelsResponse : ApiResponse {
    var labels : [Dictionary<String,AnyObject>]?
    override func ParseResponse(response: Dictionary<String, AnyObject>!) -> Bool {
        
        PMLog.D(response.JSONStringify(true))
        self.labels =  response["Labels"] as? [Dictionary<String,AnyObject>]
        
        return true
    }
}


// MARK : apply label to message
public class ApplyLabelToMessageRequest<T : ApiResponse> : ApiRequest<T> {
    var labelID: String!
    var messages:[String]!
    
    init(labelID:String!, messages: [String]!) {
        self.labelID = labelID
        self.messages = messages
    }
    
    override func toDictionary() -> Dictionary<String, AnyObject>? {
        var out : [String : AnyObject] = [String : AnyObject]()
        out["MessageIDs"] = messages;
        PMLog.D(self.JSONStringify(out, prettyPrinted: true))
        return out
    }
    
    
    override func getAPIMethod() -> APIService.HTTPMethod {
        return .PUT
    }
    
    override public func getRequestPath() -> String {
        return LabelAPI.Path + "/apply/" + self.labelID + AppConstants.getDebugOption
    }
    
    override public func getVersion() -> Int {
        return LabelAPI.V_ApplyLabelToMessageRequest
    }
}

// MARK : remove label from message
public class RemoveLabelFromMessageRequest<T : ApiResponse> : ApiRequest<T> {
    
    var labelID: String!
    var messages:[String]!
    
    init(labelID:String!, messages: [String]!) {
        self.labelID = labelID
        self.messages = messages
    }
    
    override func toDictionary() -> Dictionary<String, AnyObject>? {
        var out : [String : AnyObject] = [String : AnyObject]()
        out["MessageIDs"] = messages;
        
        PMLog.D(self.JSONStringify(out, prettyPrinted: true))
        return out
    }
    
    
    override func getAPIMethod() -> APIService.HTTPMethod {
        return .PUT
    }
    
    override public func getRequestPath() -> String {
        return LabelAPI.Path + "/remove/" + self.labelID + AppConstants.getDebugOption
    }
    
    override public func getVersion() -> Int {
        return LabelAPI.V_RemoveLabelFromMessageRequest
    }
}


// MARK : create label
public class CreateLabelRequest<T : ApiResponse> : ApiRequest<T> {
    
    var labelName: String!
    var color:String!
    var exclusive : Bool = false
    
    init(name:String!, color:String!, exclusive : Bool) {
        self.labelName = name
        self.color = color
        self.exclusive = exclusive
    }
    
    override func toDictionary() -> Dictionary<String, AnyObject>? {
        
        let out : [String : AnyObject] = [
            "Name": self.labelName,
            "Color": self.color,
            "Display": 0,
            "Exclusive" : self.exclusive
        ]

        return out
    }
    
    override func getAPIMethod() -> APIService.HTTPMethod {
        return .POST
    }
    
    override public func getRequestPath() -> String {
        return LabelAPI.Path + AppConstants.getDebugOption
    }
    
    override public func getVersion() -> Int {
        return LabelAPI.V_CreateLabelRequest
    }
}

public class CreateLabelRequestResponse : ApiResponse {
    var label:Dictionary<String,AnyObject>?
    
    override func ParseResponse(response: Dictionary<String, AnyObject>!) -> Bool {
        
        PMLog.D(response.JSONStringify(true))
        
        self.label = response["Label"] as? Dictionary<String,AnyObject>
        
        return true
    }
}


// MARK : create label
public class DeleteLabelRequest<T : ApiResponse> : ApiRequest<T> {
    
    var labelID: String!
    
    init(lable_id:String) {
        labelID = lable_id
    }
    
    override func getAPIMethod() -> APIService.HTTPMethod {
        return .DELETE
    }
    
    override public func getRequestPath() -> String {
        return LabelAPI.Path + "/\(labelID)" + AppConstants.getDebugOption
    }
    
    override public func getVersion() -> Int {
        return LabelAPI.V_DeleteLabelRequest
    }
}


