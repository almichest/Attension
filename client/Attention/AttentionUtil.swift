//
//  AttentionUtil.swift
//  Attention
//
//  Created by Hiraku Ohno on 2016/05/01.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit

class AttentionUtil: NSObject {
    static func makeReportText(item: AttentionItem) -> String {
        return "@" + TWITTER_REPORT_DESTINATION + " 通報 " + "id: \(item.identifier), " + "body: \(item.attentionBody)"
    }
}
