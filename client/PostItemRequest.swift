//
//  PostItemRequest.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/21.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import APIKit

class PostItemRequest: AttentionRequestType {
    typealias Response = PostResult
    
    var method: HTTPMethod {
        return .POST
    }
    
    var path: String {
        return ""
    }
    
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        guard let result = object as? [String : AnyObject] else {
            return nil
        }
        
        return try? PostResult.decodeValue(result)
    }
}
