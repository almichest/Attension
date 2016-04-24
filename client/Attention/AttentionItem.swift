//
//  AttentionItem.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/13.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit
import RealmSwift

class AttentionItem: Object {
    dynamic var identifier: String = ""
    dynamic var latitude: CLLocationDegrees = 0.0
    dynamic var longtitude: CLLocationDegrees = 0.0
    dynamic var attentionBody: String = ""
    dynamic var placeName: String = ""
    dynamic var shared: Bool = false
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
}

extension AttentionItem {
    /* onServer should be in response only. */
    func toDictionary(includeIdentifier: Bool = true) -> [String : AnyObject] {
        var ret: [String : AnyObject] = ["latitude"       : latitude,
                                         "longitude"      : longtitude,
                                         "attention_body" : attentionBody,
                                         "place_name"     : placeName]

        if includeIdentifier {
            ret["identifier"] = identifier
        }
        return ret
    }
}

func ==(left: AttentionItem, right: AttentionItem) -> Bool {
    return left.identifier == right.identifier
}

func !=(left: AttentionItem, right: AttentionItem) -> Bool {
    return !(right == left)
}