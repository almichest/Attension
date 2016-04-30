//
//  Settings.swift
//  Attention
//
//  Created by Hiraku Ohno on 2016/04/30.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit

class Settings: NSObject {

    private static let LAST_FETCHED_TIME = "lastFetchedTime"

    static var lastSavedTime: NSTimeInterval {
        get {
            return NSUserDefaults.standardUserDefaults().doubleForKey(LAST_FETCHED_TIME)
        }
        set {
            NSUserDefaults.standardUserDefaults().setDouble(newValue, forKey: LAST_FETCHED_TIME)
        }
    }
}
