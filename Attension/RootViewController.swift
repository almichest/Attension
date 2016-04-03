//
//  ViewController.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/03.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit
import MapKit
import BlocksKit

class RootViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer.bk_recognizerWithHandler {[weak self] (sender, state, location) in
            guard self != nil else {return}
            let coordinater = self!.mapView.convertPoint(location, toCoordinateFromView: self!.mapView)
            print(coordinater)
        } as! UITapGestureRecognizer
        mapView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var region = mapView.region
        region.center = CLLocationCoordinate2DMake(35.71, 139.81)
        region.span = MKCoordinateSpanMake(0.01, 0.01)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = region.center
        annotation.title = "Test"
        mapView.addAnnotation(annotation)
        
    }
}

