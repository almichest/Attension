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
    @IBOutlet weak var searchBar: GeoLocationSearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UILongPressGestureRecognizer.bk_recognizerWithHandler {[weak self] (sender, state, location) in
            guard self != nil else {return}
            let coordinater = self!.mapView.convertPoint(location, toCoordinateFromView: self!.mapView)
            let annotation1 = MKPointAnnotation()
            annotation1.coordinate = coordinater
            annotation1.title = "Test1"
            self!.mapView.addAnnotation(annotation1)
        
        } as! UILongPressGestureRecognizer
        mapView.addGestureRecognizer(tap)
        
        searchBar.searchButtonHandler = {(searchBar) in
            guard let text = searchBar.text else {return}
            self.searchLocation(text)
        }
        searchBar.showsCancelButton = true
    }
    
    private func searchLocation(locationName: String) {
        GeoLocationProvider.sharedInstance.searchLocation(locationName).on(success: { (mapItem) in
            print(mapItem)
        }) { (error, isCancelled) in
            print("Error")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        LocationManager.sharedInstance.requestLocation().on(success: { (location) in
            var region = self.mapView.region
            region.center = location.coordinate
            region.span = MKCoordinateSpanMake(0.005, 0.005)
            self.mapView.setRegion(region, animated: true)
            
        }, failure: nil)
    }
}

