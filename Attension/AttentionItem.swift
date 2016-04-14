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
    dynamic var latitude: Double = 0.0
    dynamic var glatitude: Double = 0.0
    dynamic var attentionBody: String = ""
    
}

func ==(left: AttentionItem, right: AttentionItem) -> Bool {
    return left.latitude == right.latitude &&
           left.glatitude == right.glatitude &&
           left.attentionBody == right.attentionBody
}

func !=(left: AttentionItem, right: AttentionItem) -> Bool {
    return !(right == left)
}