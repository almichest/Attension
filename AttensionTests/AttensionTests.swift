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
    
    func testAddingItem() {
        let item = AttentionItem()
        item.latitude = 0.5
        item.glatitude = 0.1
        item.attentionBody = "test"
        AttentionItemDataSource.sharedInstance.addAttentionItem(item)
        
        let items = AttentionItemDataSource.sharedInstance.attentionItems
        XCTAssert(items.count == 1)
        XCTAssert(items[0] == item)
    }
}
