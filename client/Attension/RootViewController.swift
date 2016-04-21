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
    
    private var currentAnnotation: MKAnnotation?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UILongPressGestureRecognizer.bk_recognizerWithHandler {[weak self] (sender, state, location) in
            
            guard self != nil && state == .Began else {return}
            
            let coordinater = self!.mapView.convertPoint(location, toCoordinateFromView: self!.mapView)
            let annotation = AttentionAnnotation()
            annotation.coordinate = coordinater
            self?.mapView.addAnnotation(annotation)
            self?.currentAnnotation = annotation
            self?.showPopupForAddingAttentionItem(location, annotation: annotation)
            
            } as! UILongPressGestureRecognizer
        
        mapView.addGestureRecognizer(tap)
        mapView.delegate = self
        
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
        
        AttentionItemDataSource.sharedInstance.subscribe(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        AttentionAPIClient.sharedInstance.getAttentionItems(0, longitude: 0, radius: 0).on(success: { response in
            let items = response.map({ (resItem) -> AttentionItem in
                let item = AttentionItem()
                item.identifier = resItem.identifier
                item.latitude = resItem.latitude
                item.longtitude = resItem.longitude
                item.attentionBody = resItem.attentionBody
                item.placeName = resItem.placeName
                item.onServer = true
                return item
            })
            AttentionItemDataSource.sharedInstance.addAttentionItems(items)
            
        }) { (error, isCancelled) in
            debugPrint("fail")
        }
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
                self.searchItems()
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
    
    private func searchItems() {
        //        AttentionAPIClient.sharedInstance.getAttentionItems(0, longitude: 0, radius: 0).on(success: { response in
        //            let items = response.map({ (resItem) -> AttentionItem in
        //                let item = AttentionItem()
        //                item.identifier = resItem.identifier
        //                item.latitude = resItem.latitude
        //                item.longtitude = resItem.longitude
        //                item.attentionBody = resItem.attentionBody
        //                item.placeName = resItem.placeName
        //                return item
        //            })
        //            AttentionItemDataSource.sharedInstance.addAttentionItems(items)
        //
        //        }) { (error, isCancelled) in
        //            debugPrint("fail")
        //        }
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

//MARK: Popover
extension RootViewController: UIPopoverPresentationControllerDelegate {
    
    private func showPopupForAddingAttentionItem(location: CGPoint, annotation: AttentionAnnotation) {
        let vc = AddingItemViewController.viewController()
        
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.permittedArrowDirections = [.Up, .Down]
        vc.popoverPresentationController?.sourceRect = CGRect(x: location.x, y: location.y, width: 0, height: 0)
        vc.popoverPresentationController?.sourceView = mapView
        vc.popoverPresentationController?.delegate = self
        vc.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
        
        presentViewController(vc, animated: true) {
            // viewがloadされてからじゃないとエラーになる
            vc.doneButton.bk_addEventHandler({[weak self] (sender) in
                let item = AttentionItem()
                if let coordinater = self?.mapView.convertPoint(location, toCoordinateFromView: self!.mapView) {
                    item.latitude = coordinater.latitude
                    item.longtitude = coordinater.longitude
                    if let whereText = vc.whereTextField.text {
                        item.placeName = whereText
                    }
                    if let whatText = vc.whatTextView.text {
                        item.attentionBody = whatText
                    }
                    annotation.attentionItem = item
                    self?.registerItem(item)
                }
                
                self?.dismissViewControllerAnimated(true, completion: nil)
                }, forControlEvents: .TouchUpInside)
        }
    }
    
    private func registerItem(item: AttentionItem) {
        AttentionItemDataSource.sharedInstance.addAttentionItems([item])
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        if let annotation = self.currentAnnotation {
            self.mapView.removeAnnotation(annotation)
        }
    }
}

extension RootViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let attentionAnnotation = view.annotation as? AttentionAnnotation else { return }
        
        let vc = AnnotationBodyViewController.viewController()
        let _ = vc.view
        if let item = attentionAnnotation.attentionItem {
            vc.titleLabel.text = item.placeName
            vc.bodyLabel.text = item.attentionBody
        } else {
            vc.titleLabel.text = "No information"
            vc.bodyLabel.text = "No information"
        }
        
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.permittedArrowDirections = [.Up, .Down]
        vc.popoverPresentationController?.sourceRect = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: 0, height: 0)
        vc.popoverPresentationController?.sourceView = mapView
        vc.popoverPresentationController?.delegate = self
        vc.preferredContentSize = CGSize(width: self.view.bounds.width, height: 200)
        
        presentViewController(vc, animated: true) {
            self.mapView.deselectAnnotation(attentionAnnotation, animated: true)
        }
    }
}

extension RootViewController: AttentionItemDataSourceReceiver {
    func datasetDidChange(dataSource: AttentionItemDataSource) {
        dataSource.query(0, longtitude: 0, radius: 0).on(success: { (items) in
            items.forEach({ (item) in
                let coordinate = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longtitude)
                let annotation = AttentionAnnotation()
                annotation.attentionItem = item
                annotation.coordinate = coordinate
                self.mapView.addAnnotation(annotation)
            })
            }, failure: nil)
    }
}