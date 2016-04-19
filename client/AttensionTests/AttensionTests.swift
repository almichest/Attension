//
//  AttensionTests.swift
//  AttensionTests
//
//  Created by Hiraku Ohno on 2016/04/03.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import XCTest
@testable import Attension

class AttensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        AttentionItemDataSource.sharedInstance.deleteAll()
    }
    
    override func tearDown() {
        super.tearDown()
        
    }

    private var notified: Bool = false
    
    func testAddingItem() {
        let expectation = self.expectationWithDescription("fetch")
        let item = AttentionItem()
        item.latitude = 0.5
        item.longtitude = 0.1
        item.attentionBody = "test"

        AttentionItemDataSource.sharedInstance.subscribe(self)
        AttentionItemDataSource.sharedInstance.addAttentionItems([item])

        AttentionItemDataSource.sharedInstance.query(0, longtitude: 0, radius: 0).on(success: { (items) in
            XCTAssert(items.count == 1)
            XCTAssert(items[0] == item)
            XCTAssertTrue(self.notified, "Realm notification is not received.")
            expectation.fulfill()
        }, failure: nil)

        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
}

extension AttensionTests: AttentionItemDataSourceReceiver {
    func datasetDidChange(dataSource: AttentionItemDataSource) {
        notified = true
    }
}