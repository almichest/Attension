//
//  PostItemRequest.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/21.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import APIKit

class PostItemRequest: AttentionRequestType {
    
    let item: AttentionItem
    
    init(item: AttentionItem) {
        self.item = item
    }
    
    typealias Response = PostResult
    
    var method: HTTPMethod {
        return .POST
    }
    
    var path: String {
        return "add/"
    }
    
    var requestBodyBuilder: RequestBodyBuilder {
        return .JSON(writingOptions: .PrettyPrinted)
    }
    
    var parameters: [String : AnyObject] {
        return item.toDictionary()
    }
    
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        guard let result = object as? [String : AnyObject] else {
            return nil
        }
        
        return try? PostResult.decodeValue(result)
    }
}
