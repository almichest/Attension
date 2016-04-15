//
//  AttentionAnnotation.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/16.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit
import MapKit

class AttentionAnnotation: MKPointAnnotation {

    let attentionItem: AttentionItem

    init(attentionItem: AttentionItem) {
        self.attentionItem = attentionItem
    }

}
