//
//  SimultaneousRecognizerHandler.swift
//  Attention
//
//  Created by Hiraku Ohno on 2016/05/09.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit

class SimultaneousRecognizerHandler: NSObject {

    init(recognizers: [UIGestureRecognizer]) {
        super.init()
        recognizers.forEach { (recognizer) in
            recognizer.delegate = self
        }
    }
}

extension SimultaneousRecognizerHandler: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}