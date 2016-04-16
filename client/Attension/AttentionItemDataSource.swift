//
//  AttentionItemDataSource.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/13.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftTask

class AttentionItemDataSource: NSObject {
    
    static let sharedInstance = AttentionItemDataSource()
    private let realm = try! Realm()
    
    func query(latitude: CLLocationDegrees, longtitude: CLLocationDegrees, radius: Double) -> Task<Float, [AttentionItem], NSError> {
        return Task<Float, [AttentionItem], NSError>{ fulfill, reject in
            let result = Array(self.realm.objects(AttentionItem))
            fulfill(result)
        }
    }

    func addAttentionItem(item: AttentionItem) {
        try! realm.write {
            realm.add(item)
        }
    }
    
    func deleteAttentionItem(item: AttentionItem) {
        try! realm.write {
            realm.delete(item)
        }
    }
    
    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }

    func nextIdentifier() -> Int {
        if let item = realm.objects(AttentionItem).last {
            return item.identifier + 1
        } else {
            return 0
        }
    }
}
