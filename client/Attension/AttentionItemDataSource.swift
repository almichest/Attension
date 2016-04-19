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
    private var realmToken: NotificationToken?

    deinit {
        realmToken?.stop()
    }

    private var receivers: [AttentionItemDataSourceReceiver] = []

    func subscribe(receiver: AttentionItemDataSourceReceiver) {
        if receivers.count == 0 {
            realmToken = self.realm.addNotificationBlock {[weak self] (notification, realm) in
                guard self != nil else {return}
                self?.receivers.forEach { (receiver) in
                    receiver.datasetDidChange(self!)
                }
            }
        }

        guard !receivers.contains({$0 === receiver}) else {return}
        receivers.append(receiver)
    }

    func unsubscribe(receiver: AttentionItemDataSourceReceiver) {
        if let index = receivers.indexOf({$0 === receiver}) {
            receivers.removeAtIndex(index)
        }

        if receivers.count == 0 {
            realmToken?.stop()
        }
    }

    //TODO: filter
    func query(latitude: CLLocationDegrees, longtitude: CLLocationDegrees, radius: Double) -> Task<Float, [AttentionItem], NSError> {
        return Task<Float, [AttentionItem], NSError>{ fulfill, reject in
            let result = Array(self.realm.objects(AttentionItem))
            fulfill(result)
        }
    }

    func addAttentionItems(items: [AttentionItem]) {
        try! realm.write {
            items.forEach({ (item) in
                item.identifier = createIdentifier(item)
                realm.add(item)
            })
        }
    }
    
    func deleteAttentionItems(items: [AttentionItem]) {
        try! realm.write {
            items.forEach({ (item) in
                realm.delete(item)
            })
        }
    }
    
    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }

    private func createIdentifier(item: AttentionItem) -> String {
        return String(item.latitude) + String(item.longtitude)
    }
}

protocol AttentionItemDataSourceReceiver: class {
    func datasetDidChange(dataSource: AttentionItemDataSource)
}

