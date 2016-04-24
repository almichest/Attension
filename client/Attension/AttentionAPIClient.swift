//
//  AttentionAPIClient.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/19.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import SwiftTask
import Firebase

let APIErrorDomain = "APIError"
enum APIErrorCode: Int {
    case GeneralError
}

public class AttentionAPIClient: NSObject {

    public static let sharedClient = AttentionAPIClient()

    private let firebase = Firebase(url: FIRE_BASE_URL)

    func getAttentionItems(latitude: Double, longitude: Double, radius: Double) -> Task<Float, [AttentionResponseItem], NSError> {
        print("fetch - \(latitude), \(longitude), \(radius)")
        return Task<Float, [AttentionResponseItem], NSError>(promiseInitClosure: { (fulfill, reject) in
            self.firebase.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                print("fetch result - \(snapshot.value)")
                guard let value = snapshot.value as? Dictionary<String, Dictionary<String, AnyObject>> else {
                    reject(NSError(domain: APIErrorDomain, code: APIErrorCode.GeneralError.rawValue, userInfo: nil))
                    return
                }

                guard let dic = value["attentions"] else {
                    reject(NSError(domain: APIErrorDomain, code: APIErrorCode.GeneralError.rawValue, userInfo: nil))
                    return
                }
                let items = Array(dic.keys).map({ (key) -> AttentionResponseItem? in
                    guard var copy = dic[key] as? [String : AnyObject] else {
                        return nil
                    }
                    copy["identifier"] = key

                    return try? AttentionResponseItem.decodeValue(copy)

                }).filter{$0 != nil}.map{$0!}

                fulfill(items)

            })
        })
    }

    func createNewAttentionItem(item: AttentionItem) -> Task<Float, AttentionItem, NSError> {
        return Task<Float, AttentionItem, NSError>(promiseInitClosure: { (fulfill, reject) in
            let attentionsRef = self.firebase.childByAppendingPath("attentions/")
            let dic = item.toDictionary(false)
            attentionsRef.childByAutoId().setValue(dic) { (error, firebase) in
                print("create complete. key = \(firebase.key)")
                if let key = firebase.key {
                    item.identifier = key
                    item.shared = true
                    fulfill(item)
                } else {
                    reject(NSError(domain: APIErrorDomain, code: APIErrorCode.GeneralError.rawValue, userInfo: nil))
                }
            }
        })
    }
}
