//
//  TwitterTest.swift
//  Attention
//
//  Created by Hiraku Ohno on 2016/04/30.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import XCTest

class TwitterTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    //TODO: 動くようにする
    func testPostTweet() {
        let expectation = self.expectationWithDescription("Wait for API response")

        TwitterClient.sharedClient.post("Test \(NSDate())").on(success: { (result) in
            XCTAssert(result)
            expectation.fulfill()
        }) { (error, isCancelled) in
            XCTFail()
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
}
