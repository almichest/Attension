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
            annotation1.title = "Test"
            self!.mapView.addAnnotation(annotation1)
        
        } as! UILongPressGestureRecognizer
        mapView.addGestureRecognizer(tap)
        
        searchBar.searchButtonHandler = {(searchBar) in
            guard let text = searchBar.text else {return}
            self.searchLocation(text)
        }
        
        LocationManager.sharedInstance.requestLocation().on(success: { (location) in
            var region = self.mapView.region
            region.center = location.coordinate
            region.span = MKCoordinateSpanMake(0.005, 0.005)
            self.mapView.setRegion(region, animated: true)
            
            }, failure: {(error, cancelled) in
                debugPrint(error)
            }
        )
        
    }
    
    private func searchLocation(locationName: String) {
        GeoLocationProvider.sharedInstance.searchLocation(locationName).on(success: {[weak self] (mapItems) in
            self?.showMapItems(mapItems)
        }) {[weak self] (error, isCancelled) in
            self?.showNoResultError()
        }
    }
    
    private func showMapItems(mapItems: [MKMapItem]) {
        let vc = LocationSelectViewController.viewController(mapItems)
        vc.mapItemSelectionHandler = {(mapItem) in
            self.dismissViewControllerAnimated(true, completion: {
                var region = self.mapView.region
                region.center = mapItem.placemark.coordinate
                region.span = MKCoordinateSpanMake(0.005, 0.005)
                self.mapView.setRegion(region, animated: true)
            })
        }
        let nav = UINavigationController(rootViewController: vc)
        let cancelButton = UIBarButtonItem(systemItem: .Cancel) { (sender) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        cancelButton.title = "Cancel"
        vc.navigationItem.rightBarButtonItem = cancelButton
        vc.navigationItem.title = "Search Result"
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    private func showNoResultError() {
        let alert = UIAlertController(title: "No Result", message: "No result found. Please try for another location name.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        )
            
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

