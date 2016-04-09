//
//  GeoLocationProvider.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/08.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit
import MapKit
import SwiftTask

enum GeoLocationError: Int {
    case NoResult
    case Error
}

let GeoLocationErrorDomain = "GeoLocationError"


class GeoLocationProvider: NSObject {
    
    static let sharedInstance = GeoLocationProvider()
    
    func searchLocation(locationName: String) -> Task<Float, [MKMapItem], NSError> {
        return Task<Float, [MKMapItem], NSError>(promiseInitClosure: { (fulfill, reject) in
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = locationName
            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler({ (response, error) in
                if let mapItems = response?.mapItems {
                    fulfill(mapItems)
                } else if let response = response where response.mapItems.count == 0 {
                    reject(NSError(domain:GeoLocationErrorDomain, code: GeoLocationError.NoResult.rawValue, userInfo: nil))
                } else {
                    reject(NSError(domain:GeoLocationErrorDomain, code: GeoLocationError.Error.rawValue, userInfo: nil))
                }
            })
        })
    }
}
