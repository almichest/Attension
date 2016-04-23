//
//  AttentionAPIClient.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/19.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import SwiftTask
import Firebase

public class AttentionAPIClient: NSObject {

    static let sharedClient = AttentionAPIClient()

    private let firebase = Firebase(url: firebaseUrl)

    public static let sharedInstance = AttentionAPIClient()
    
    func getAttentionItems(latitude: Double, longitude: Double, radius: Double) -> Task<Float, [AttentionResponseItem], NSError> {
        print("fetch - \(latitude), \(longitude), \(radius)")
        return Task<Float, [AttentionResponseItem], NSError>(promiseInitClosure: { (fulfill, reject) in
            self.firebase.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                print("fetch result - \(snapshot.value)")
                guard let value = snapshot.value as? Dictionary<String, Dictionary<String, AnyObject>>else {
                    fulfill([])
                    return
                }

                let items = value.map({ (key, dic) -> AttentionResponseItem? in
                    var copy = dic
                    copy["identifier"] = key

                    return try? AttentionResponseItem.decodeValue(copy)

                }).filter({ $0 != nil }).map({$0!})

                fulfill(items)
            })
        })
    }

    func createNewAttentionItem(item: AttentionItem) -> Task<Float, PostResult, NSError> {
        return Task<Float, PostResult, NSError>(promiseInitClosure: { (fulfill, reject) in
            let attentionsRef = self.firebase.childByAppendingPath("attentions/")
            let item = item.toDictionary(false)
            attentionsRef.childByAutoId().setValue(item) { (error, firebase) in
                if let error = error {
                    reject(error)
                } else {
                    fulfill(.OK)
                }
            }
        })
    }
}
