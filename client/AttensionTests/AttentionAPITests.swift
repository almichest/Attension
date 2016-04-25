//
//  AttentionAPITests.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/19.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import XCTest
import SwiftTask
@testable import Attention

class AttentionAPITests: XCTestCase {
    
    func testGetAPI() {
        let expectation = self.expectationWithDescription("Wait for API response")
        AttentionAPIClient.sharedClient.fetchItems(0, longitude: 0, radius: 0).on(success: { (items) in
            XCTAssert(0 < items.count)
            expectation.fulfill()
            
        }) { (error, isCancelled) in
            XCTFail()
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testPostAPI() {
        let expectation = self.expectationWithDescription("Wait for API response")
        let item = AttentionItem()
        let date = NSDate()
        item.identifier = "hogehoge\(UInt(date.timeIntervalSince1970))"
        AttentionAPIClient.sharedClient.createNewItem(item).on(success: { (item) in
            XCTAssert(0 < item.identifier.characters.count)
            expectation.fulfill()
        }) { (error, isCancelled) in
            XCTFail()
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testUpdateAPI() {
        let expectation = self.expectationWithDescription("Wait for API response")
        let item = AttentionItem()
        item.attentionBody = "before"
        var key = ""
        AttentionAPIClient.sharedClient.createNewItem(item).then { (item,error) -> Task<Float, AttentionItem, NSError> in
            XCTAssertEqual(item?.attentionBody, "before")
            item?.attentionBody = "after"
            key = item!.identifier
            return AttentionAPIClient.sharedClient.updateItem(item!)
        }.on(success: {(item) in
            XCTAssertEqual(item.attentionBody, "after")
            XCTAssertEqual(item.identifier, key)
            expectation.fulfill()
        }) { (error, isCancelled) in
            XCTFail()
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
}
