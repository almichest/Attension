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
import RealmSwift

class RootViewController: UIViewController {
    
    @IBOutlet private weak var mapView: AttentionMapView!
    @IBOutlet private weak var searchBar: GeoLocationSearchBar!
    @IBOutlet private weak var currentLocationButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    
    private var currentAnnotation: MKAnnotation?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer.bk_recognizerWithHandler {[weak self] (sender, state, location) in
            
            guard self != nil && state == .Began else {return}
            
            let coordinater = self!.mapView.convertPoint(location, toCoordinateFromView: self!.mapView)
            let annotation = AttentionAnnotation()
            annotation.coordinate = coordinater
            self?.mapView.addAnnotation(annotation)
            self?.currentAnnotation = annotation
            self?.showPopupForAddingAttentionItem(location, annotation: annotation)
            
            } as! UILongPressGestureRecognizer
        
        mapView.addGestureRecognizer(longPress)
        mapView.attentionDelegate = self

        let tap = UITapGestureRecognizer.bk_recognizerWithHandler {[weak self] (recognizer, state, point) in
            self?.hideMapItems(true)
            self?.searchBar.resignFirstResponder()
        } as! UITapGestureRecognizer
        mapView.addGestureRecognizer(tap)

        mapView.showsUserLocation = true

        searchBar.searchHandler = {(searchBar) in
            guard let text = searchBar.text else {return}
            self.searchLocation(text)
        }

        searchBar.startHandler = {(searchBar) in self.showLocationSearchResultView()}
        
        AttentionItemDataSource.sharedInstance.subscribe(self)

        currentLocationButton.bk_addEventHandler({[weak self] (button) in
            self?.focusOnUserLocation()
        }, forControlEvents: .TouchUpInside)

        zoomInButton.bk_addEventHandler({[weak self] (button) in
            self?.zoom(true)
        }, forControlEvents: .TouchUpInside)

        zoomOutButton.bk_addEventHandler({[weak self] (button) in
            self?.zoom(false)
        }, forControlEvents: .TouchUpInside)

    }

    private func zoom(zoomIn: Bool) {
        var region = self.mapView.region
        let span = region.span
        if zoomIn {
            region.span = MKCoordinateSpan(latitudeDelta: span.latitudeDelta / 1.25, longitudeDelta: span.longitudeDelta / 1.25)
        } else {
            region.span = MKCoordinateSpan(latitudeDelta: span.latitudeDelta * 1.25, longitudeDelta: span.longitudeDelta * 1.25)

        }

        UIView.animateWithDuration(0.1) { 
            self.mapView.setRegion(region, animated: true)
        }
    }

    private func focusOnUserLocation() {
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        focusOnUserLocation()
        searchItems()
    }

    private func searchLocation(locationName: String) {
        GeoLocationProvider.sharedInstance.searchLocation(locationName).on(success: {[weak self] (items) in
            self?.updateMapItems(items)
        }) {[weak self] (error, isCancelled) in
            self?.updateMapItems([])
        }
    }

    private var locationSelectViewController: LocationSelectViewController?
    private func showLocationSearchResultView() {

        let vc = LocationSelectViewController.viewController()
        vc.mapItemSelectionHandler = {(mapItem) in
            var region = self.mapView.region
            region.center = mapItem.placemark.coordinate
            region.span = MKCoordinateSpanMake(0.005, 0.005)
            self.mapView.setRegion(region, animated: true)
        }

        vc.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        view.addSubview(vc.view)
        addChildViewController(vc)
        vc.didMoveToParentViewController(self)
        locationSelectViewController = vc

        vc.view.frame = CGRect(x: 0, y: view.bounds.size.height, width: view.bounds.size.width, height: 150)
        UIView.animateWithDuration(0.5, animations: {
            vc.view.frame = CGRect(x: 0, y: self.view.bounds.size.height - 150, width: self.view.bounds.size.width, height: 150)
        })
    }

    private func updateMapItems(mapItems: [MKMapItem]) {
        guard let vc = locationSelectViewController else {return}
        vc.mapItems = mapItems
    }

    private func hideMapItems(animated: Bool) {
        guard let vc = locationSelectViewController else {return}
        if animated {
            UIView.animateWithDuration(0.5, animations: {
                vc.view.frame =  CGRect(x: 0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: 150)
            }, completion: { (finised) in
                vc.willMoveToParentViewController(nil)
                vc.removeFromParentViewController()
                vc.view.removeFromSuperview()
                self.locationSelectViewController = nil
            })

        } else {
            vc.willMoveToParentViewController(nil)
            vc.removeFromParentViewController()
            vc.view.removeFromSuperview()
            locationSelectViewController = nil
        }
    }
    
    private func searchItems() {
        AttentionAPIClient.sharedClient.fetchItems(0, longitude: 0, radius: 0).on(success: { response in
            let items = response.map({ (resItem) -> AttentionItem in
                let item = AttentionItem()
                item.identifier = resItem.identifier
                item.latitude = resItem.latitude
                item.longtitude = resItem.longitude
                item.attentionBody = resItem.attentionBody
                item.placeName = resItem.placeName
                item.shared = true
                return item
            })
            AttentionItemDataSource.sharedInstance.addAttentionItems(items)
            
        }) { (error, isCancelled) in
            debugPrint("fail")
        }
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
                let completion: (() -> Void)
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
                    completion = {self?.registerItem(item)}
                } else {
                    completion = {}
                }
                
                self?.dismissViewControllerAnimated(true, completion: completion)

            }, forControlEvents: .TouchUpInside)
        }
    }

    private func registerItem(item: AttentionItem) {

        if MAX_PLACENAME_LENGTH < item.placeName.characters.count || MAX_ATTENTION_LENGTH < item.attentionBody.characters.count {
            let vc = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("alert.textlength", comment: ""), preferredStyle: .Alert)
            presentViewController(vc, animated: true, completion: {
                vc.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel) { (action) in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    self.showAddingItemPopoverWithItem(item)
                })
            })
            return
        }

        if item.shared {
            AttentionAPIClient.sharedClient.updateItem(item).on(success: { (item) in
                AttentionItemDataSource.sharedInstance.addAttentionItems([item])
            }, failure: nil)
        } else {
            let vc = UIAlertController(title: NSLocalizedString("please.share.title", comment: ""), message: NSLocalizedString("please.share.body", comment: ""), preferredStyle: .Alert)

            vc.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .Default) { (action) in
                AttentionAPIClient.sharedClient.createNewItem(item).on(success: { (item) in
                    AttentionItemDataSource.sharedInstance.query(item.identifier).on(success: { (result) in
                        if let result = result {
                            AttentionItemDataSource.sharedInstance.deleteAttentionItems([result])
                            AttentionItemDataSource.sharedInstance.addAttentionItems([item])
                        } else {
                            AttentionItemDataSource.sharedInstance.addAttentionItems([item])
                        }
                    }, failure: { (error, isCancelled) in
                            AttentionItemDataSource.sharedInstance.addAttentionItems([item])
                    })
                }, failure: { (error, isCancelled) in

                })
            })

            vc.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .Default) { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)
                /* 新規作成時はidentifierが空文字列 */
                if item.identifier == "" {
                    item.identifier = AttentionItemDataSource.createLocalIdentifier(item)
                }
                AttentionItemDataSource.sharedInstance.addAttentionItems([item])
            })

            vc.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel) { (action) in
                self.dismissViewControllerAnimated(false, completion: nil)
                self.showAddingItemPopoverWithItem(item)
            })
            presentViewController(vc, animated: true, completion: nil)
        }
    }

    private func showAddingItemPopoverWithItem(item: AttentionItem) {
        let vc = AddingItemViewController.viewController()
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.permittedArrowDirections = [.Up, .Down]
        let coordinate = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longtitude)
        let location = mapView.convertCoordinate(coordinate, toPointToView: mapView)
        vc.popoverPresentationController?.sourceRect = CGRect(x: location.x, y: location.y, width: 0, height: 0)
        vc.popoverPresentationController?.sourceView = mapView
        vc.popoverPresentationController?.delegate = self
        vc.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
        presentViewController(vc, animated: true) {
            // viewがloadされてからじゃないとエラーになる
            vc.whatTextView.insertText(item.attentionBody)
            vc.whereTextField.text = item.placeName
            vc.doneButton.bk_addEventHandler({[weak self] (sender) in
                let completion: (() -> Void)
                if let coordinater = self?.mapView.convertPoint(location, toCoordinateFromView: self!.mapView) {
                    let newItem = AttentionItem()
                    newItem.latitude = coordinater.latitude
                    newItem.longtitude = coordinater.longitude
                    if let whereText = vc.whereTextField.text {
                        newItem.placeName = whereText
                    }
                    if let whatText = vc.whatTextView.text {
                        newItem.attentionBody = whatText
                    }
                    newItem.identifier = item.identifier
                    newItem.shared = item.shared
                    completion = {self?.registerItem(newItem)}
                } else {
                    completion = {}
                }
                
                self?.dismissViewControllerAnimated(true, completion: completion)

            }, forControlEvents: .TouchUpInside)
        }
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

extension RootViewController: AttentionMapViewDelegate {
    func mapView(mapView: AttentionMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let attentionAnnotation = view.annotation as? AttentionAnnotation else { return }
        guard let item = attentionAnnotation.attentionItem else {return}
        
        var region = self.mapView.region
        region.center = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longtitude)
        let completion = {[weak self] in
            guard self != nil else {return}
            let vc = AnnotationBodyViewController.viewController(item)
            let point = self!.mapView.convertCoordinate(CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longtitude), toPointToView: self!.mapView)

            vc.modalPresentationStyle = .Popover
            vc.popoverPresentationController?.permittedArrowDirections = [.Up, .Down]
            vc.popoverPresentationController?.sourceRect = CGRect(x: point.x, y: point.y, width: 0, height: 0)
            vc.popoverPresentationController?.sourceView = mapView
            vc.popoverPresentationController?.delegate = self
            vc.preferredContentSize = CGSize(width: self!.view.bounds.width, height: 200)

            self?.presentViewController(vc, animated: true) {
                self?.mapView.deselectAnnotation(attentionAnnotation, animated: true)
                vc.editButton.bk_addEventHandler({[weak self] (button) in
                    self?.dismissViewControllerAnimated(true, completion: {
                        self?.showAddingItemPopoverWithItem(item)
                    })
                }, forControlEvents: .TouchUpInside)
            }
        }

        guard 0.01 < region.span.latitudeDelta && 0.01 < region.span.longitudeDelta else {
            completion()
            return
        }

        region.span = MKCoordinateSpanMake(0.005, 0.005)

        self.mapView.setRegion(region, animated: true, completion: completion)
    }
}

extension RootViewController: AttentionItemDataSourceReceiver {
    func datasetDidChange(dataSource: AttentionItemDataSource) {
        mapView.removeAnnotations(mapView.annotations)
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