//
//  LocationSelectViewController.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/09.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit
import MapKit

class LocationSelectViewController: UIViewController {
    static func viewController(mapItems: [MKMapItem]) -> LocationSelectViewController {
        return R.storyboard.locationSelectViewController().instantiateInitialViewController() as! LocationSelectViewController
    }
}
