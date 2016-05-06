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
    case GeneralError           = 0
    case PermissionDeniedError  = 1
    case LoginError             = 2

    func createError() -> NSError {
        return NSError(domain: APIErrorDomain, code: self.rawValue, userInfo: nil)
    }
}

typealias LoginTask = Task<Float, Bool, NSError>
typealias FetchTask = Task<Float, [AttentionResponseItem], NSError>
typealias PushTask = Task<Float, AttentionItem, NSError>

public class AttentionAPIClient: NSObject {

    public static let sharedClient = AttentionAPIClient()

    private let firebase = Firebase(url: FIRE_BASE_URL)
    private var authTask: LoginTask!

    override init() {
        super.init()
        auth()
    }

    private func auth() {
        authTask = LoginTask(value: true)
    }


    func fetchItems(latitude: Double, longitude: Double, radius: Double) -> FetchTask {
        return authTask.then{(token, errorInfo) -> FetchTask in
            guard let _ = token else {
                return FetchTask(error: APIErrorCode.LoginError.createError())
            }
            debugPrint("fetch - \(latitude), \(longitude), \(radius)")
            return FetchTask(promiseInitClosure: { (fulfill, reject) in
                self.firebase.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    debugPrint("fetch result - \(snapshot.value)")
                    guard let value = snapshot.value as? Dictionary<String, Dictionary<String, AnyObject>> else {
                        reject(APIErrorCode.GeneralError.createError())
                        return
                    }

                    guard let dic = value["attentions"] else {
                        reject(APIErrorCode.GeneralError.createError())
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

    func createNewItem(item: AttentionItem) -> PushTask {
        return authTask.then{(token, errorInfo) -> PushTask in
            guard let _ = token else {
                return PushTask(error: APIErrorCode.LoginError.createError())
            }
            debugPrint("create item: \(item)")
            return PushTask(promiseInitClosure: { (fulfill, reject) in
                let attentionsRef = self.firebase.childByAppendingPath("attentions/")
                let dic = item.toDictionary(false)
                attentionsRef.childByAutoId().setValue(dic) { (error, firebase) in
                    debugPrint("create complete. key = \(firebase.key)")
                    if let key = firebase.key where error == nil {
                        let newItem = AttentionItem()
                        newItem.latitude = item.latitude
                        newItem.longtitude = item.longtitude
                        newItem.placeName = item.placeName
                        newItem.attentionBody = item.attentionBody
                        newItem.identifier = key
                        newItem.shared = true

                        fulfill(newItem)
                    } else if let error = error where error.code == APIErrorCode.PermissionDeniedError.rawValue {
                        reject(APIErrorCode.PermissionDeniedError.createError())
                    } else {
                        reject(APIErrorCode.GeneralError.createError())
                    }
                }
            })
        }
    }

    func updateItem(item: AttentionItem) -> PushTask {
        return authTask.then{(token, errorInfo) -> Task<Float, AttentionItem, NSError> in
            guard let _ = token else {
                return PushTask(error: APIErrorCode.LoginError.createError())
            }
            debugPrint("update item: \(item)")
            return PushTask(promiseInitClosure: { (fulfill, reject) in
                let attentionsRef = self.firebase.childByAppendingPath("attentions/" + item.identifier)
                let dic = item.toDictionary(false)
                attentionsRef.updateChildValues(dic, withCompletionBlock: { (error, firebase) in
                    if let error = error where error.code == APIErrorCode.PermissionDeniedError.rawValue {
                        reject(APIErrorCode.PermissionDeniedError.createError())
                    } else if let _ = error {
                        reject(APIErrorCode.GeneralError.createError())
                    } else {
                        fulfill(item)
                    }
                })
            })
        }
    }
}
