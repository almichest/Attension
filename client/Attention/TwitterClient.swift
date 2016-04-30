//
//  TwitterClient.swift
//  Attention
//
//  Created by Hiraku Ohno on 2016/04/30.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import TwitterKit
import SwiftTask

class TwitterClient: NSObject {

    static let sharedClient = TwitterClient()

    private let authTask: Task<Float, TWTRAuthSession, NSError>

    override init() {
        Twitter.sharedInstance().startWithConsumerKey(TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET)

        authTask = Task<Float, TWTRAuthSession, NSError>(promiseInitClosure: { (fulfill, reject) in
            let newSession = TWTRSession(authToken: TWITTER_ACCESS_TOKEN, authTokenSecret: TWITTER_ACCESS_TOKEN_SECRET, userName: TWITTER_USER_NAME, userID: TWITTER_USER_ID)
            Twitter.sharedInstance().sessionStore.saveSession(newSession) { (session, error) in
                if let session = session {
                    fulfill(session)
                } else if let error = error {
                    reject(error)
                }
            }
        })
    }

    func post(text: String) -> Task<Float, Bool, NSError> {
        return authTask.then { (session, errorInfo) -> Task<Float, Bool, NSError> in
            return Task<Float, Bool, NSError>(promiseInitClosure: { (fulfill, reject) in
                guard let userID = session?.userID else {return}
                let client = TWTRAPIClient(userID: userID)
                var error: NSError?

                let endPoint = "https://api.twitter.com/1.1/statuses/update.json"

                let params = ["status" : text]

                let request = client.URLRequestWithMethod("POST", URL: endPoint, parameters: params, error: &error)
                client.sendTwitterRequest(request) { (response, data, error) in
                    if let error = error {
                        reject(error)
                    } else {
                        fulfill(true)
                    }
                }
            })
        }}
}
