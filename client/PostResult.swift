//
//  PostResult.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/21.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit
import Himotoki

enum PostError: Int {
    case OK = 0
    case Duplicate = 1
    case GeneralError = 2
}

struct PostResult: Decodable {
    private let errorCode: Int
    
    var error: PostError {
        return PostError(rawValue: errorCode) ?? .GeneralError
    }
    
    static func decode(e: Extractor) throws -> PostResult {
        return try PostResult (
            errorCode: e <| "error_code"
        )
    }
}
