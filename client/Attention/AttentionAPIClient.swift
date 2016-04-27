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
    case LoginError

    func createError() -> NSError {
        return NSError(domain: APIErrorDomain, code: self.rawValue, userInfo: nil)
    }
}

public class AttentionAPIClient: NSObject {

    public static let sharedClient = AttentionAPIClient()

    private let firebase = Firebase(url: FIRE_BASE_URL)
    private let authTask: Task<Float, AnyObject, NSError>

    override init() {
        self.authTask = Task<Float, AnyObject, NSError>(promiseInitClosure: { (fulfill, reject) in
            let firebase = Firebase(url: FIRE_BASE_URL)
            firebase.authWithCustomToken(FIRE_BASE_AUTH_TOKEN) { (error, data) in
                if let data = data {
                    debugPrint("Log in complete")
                    fulfill(data)
                } else {
                    debugPrint("Log in Failed")
                    reject(APIErrorCode.LoginError.createError())
                }
            }
        })
        super.init()
    }

    func fetchItems(latitude: Double, longitude: Double, radius: Double) -> Task<Float, [AttentionResponseItem], NSError> {
        return authTask.then{(token, errorInfo) -> Task<Float, [AttentionResponseItem], NSError> in
            debugPrint("fetch - \(latitude), \(longitude), \(radius)")
            return Task<Float, [AttentionResponseItem], NSError>(promiseInitClosure: { (fulfill, reject) in
                self.firebase.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    debugPrint("fetch result - \(snapshot.value)")
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
    }

    func createNewItem(item: AttentionItem) -> Task<Float, AttentionItem, NSError> {
        return authTask.then{(token, errorInfo) -> Task<Float, AttentionItem, NSError> in
            debugPrint("create item: \(item)")
            return Task<Float, AttentionItem, NSError>(promiseInitClosure: { (fulfill, reject) in
                let attentionsRef = self.firebase.childByAppendingPath("attentions/")
                let dic = item.toDictionary(false)
                attentionsRef.childByAutoId().setValue(dic) { (error, firebase) in
                    debugPrint("create complete. key = \(firebase.key)")
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

    func updateItem(item: AttentionItem) -> Task<Float, AttentionItem, NSError> {
        return authTask.then{(token, errorInfo) -> Task<Float, AttentionItem, NSError> in
            debugPrint("update item: \(item)")
            return Task<Float, AttentionItem, NSError>(promiseInitClosure: { (fulfill, reject) in
                let attentionsRef = self.firebase.childByAppendingPath("attentions/" + item.identifier)
                let dic = item.toDictionary(false)
                attentionsRef.updateChildValues(dic, withCompletionBlock: { (error, firebase) in
                    if let _ = error {
                        reject(NSError(domain: APIErrorDomain, code: APIErrorCode.GeneralError.rawValue, userInfo: nil))
                    } else {
                        fulfill(item)
                    }
                })
            })
        }
    }
}
