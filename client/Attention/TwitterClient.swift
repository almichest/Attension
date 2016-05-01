//
//  TwitterClient.swift
//  Attention
//
//  Created by Hiraku Ohno on 2016/04/30.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import SwifteriOS
import SwiftTask

class TwitterClient: NSObject {

    static let sharedClient = TwitterClient()

    private let swifter: Swifter

    override init() {
        swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET, oauthToken: TWITTER_ACCESS_TOKEN, oauthTokenSecret: TWITTER_ACCESS_TOKEN_SECRET)
        super.init()
    }

    func post(text: String) -> Task<Float, Bool, NSError> {
        return Task<Float, Bool, NSError>(promiseInitClosure: { (fulfill, reject) in
            self.swifter.postStatusUpdate(text, success: { status in
                fulfill(true)
            }, failure: { error in
                debugPrint(error)
                reject(error)
            })
        })
    }
}
