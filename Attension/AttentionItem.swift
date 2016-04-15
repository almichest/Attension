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
    dynamic var latitude: CLLocationDegrees = 0.0
    dynamic var longtitude: CLLocationDegrees = 0.0
    dynamic var attentionBody: String = ""
    dynamic var placeName: String = ""
}

func ==(left: AttentionItem, right: AttentionItem) -> Bool {
    return left.latitude == right.latitude &&
           left.longtitude == right.longtitude &&
           left.attentionBody == right.attentionBody &&
           left.placeName == right.placeName
}

func !=(left: AttentionItem, right: AttentionItem) -> Bool {
    return !(right == left)
}