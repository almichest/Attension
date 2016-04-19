//
//  AttentionRequestType.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/19.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import APIKit

protocol AttentionRequestType: RequestType {
}

extension AttentionRequestType {
    var baseURL: NSURL {
        return NSURL(string: "http://localhost:8000/api/")!
    }
}
