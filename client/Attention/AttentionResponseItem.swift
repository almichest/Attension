//
//  AttentionResponseItem.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/19.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import Himotoki

struct AttentionResponseItem: Decodable {
    let identifier:String
    let latitude:Double
    let longitude:Double
    let attentionBody:String
    let placeName:String

    static func decode(e: Extractor) throws -> AttentionResponseItem {
        return try AttentionResponseItem(
            identifier: e <| "identifier",
            latitude: e <| "latitude",
            longitude: e <| "longitude",
            attentionBody: e <| "attention_body",
            placeName: e <| "place_name"
        )
    }

    var description: String {
        return "\(identifier) - \(placeName)"
    }
}
