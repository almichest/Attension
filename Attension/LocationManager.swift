//
//  LocationManager.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/05.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit
import SwiftTask

typealias LocationTask = Task<Float, CLLocation, NSError>

class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    
    private var manager:INTULocationManager {
        return INTULocationManager.sharedInstance()
    }
    
    func requestLocation() -> LocationTask {
        return LocationTask(promiseInitClosure: {(fulfill, reject) in
            self.manager.requestLocationWithDesiredAccuracy(.City, timeout: 5) { (location, accuracy, status) in
                switch status {
                case .Success:
                    fulfill(location)
                case .TimedOut:
                    reject(NSError(domain: "", code: 0, userInfo: nil))
                default:
                    reject(NSError(domain: "", code: 0, userInfo: nil))
                }
            }
        })
    }
}
