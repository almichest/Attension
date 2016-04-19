//
//  GetItemsRequestType.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/19.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import APIKit

class GetItemsRequest: AttentionRequestType {
    typealias Response = [AttentionResponseItem?]

    var method: HTTPMethod {
        return .GET
    }

    var path: String {
        return ""
    }

    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        guard let result = object as? [[String : AnyObject]] else {
            return nil
        }

        return result.map {(dictionary) in
            try? AttentionResponseItem.decodeValue(dictionary)
        }
    }
}

