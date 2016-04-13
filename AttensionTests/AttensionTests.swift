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
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        
        XCTAssert(AttentionItemDataSource.sharedInstance.attentionItems.count == 1)
    }
}
