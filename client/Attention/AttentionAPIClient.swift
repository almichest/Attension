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

typealias LoginTask = Task<Float, FAuthData, NSError>
typealias FetchTask = Task<Float, [AttentionResponseItem], NSError>
typealias PushTask = Task<Float, AttentionItem, NSError>

public class AttentionAPIClient: NSObject {

    public static let sharedClient = AttentionAPIClient()

    private let firebase = Firebase(url: FIRE_BASE_URL)
    private var authTask: Task<Float, FAuthData, NSError>!

    override init() {
        super.init()
        auth()
    }

    private static let maxLoginTry = 5
    private var loginTryCount = 0
    private func auth() {
        authTask = LoginTask(promiseInitClosure:{[weak self] (fulfill, reject) in
            let firebase = Firebase(url: FIRE_BASE_URL)
            firebase.authWithCustomToken(FIRE_BASE_AUTH_TOKEN) { (error, data) in
                if let data = data {
                    debugPrint("***** Log in complete *****")
                    fulfill(data)
                } else {
                    if self?.loginTryCount < AttentionAPIClient.maxLoginTry {
                        debugPrint("***** Log in Failed ***** : \(self?.loginTryCount)")
                        self?.loginTryCount += 1
                        self?.auth()
                    } else {
                        debugPrint("***** Log in Completely Failed ... *****")
                        reject(APIErrorCode.LoginError.createError())
                    }
                }
            }
        })
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
                    if let key = firebase.key {
                        let newItem = AttentionItem()
                        newItem.latitude = item.latitude
                        newItem.longtitude = item.longtitude
                        newItem.placeName = item.placeName
                        newItem.attentionBody = item.attentionBody
                        newItem.identifier = key
                        newItem.shared = true

                        fulfill(newItem)
                    } else {
                        reject(NSError(domain: APIErrorDomain, code: APIErrorCode.GeneralError.rawValue, userInfo: nil))
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
