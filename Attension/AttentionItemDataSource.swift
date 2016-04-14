//
//  AttentionItemDataSource.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/13.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit
import RealmSwift

class AttentionItemDataSource: NSObject {
    
    static let sharedInstance = AttentionItemDataSource()
    private let realm = try! Realm()
    
    var attentionItems: [AttentionItem] {
        return Array(realm.objects(AttentionItem))
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
}
