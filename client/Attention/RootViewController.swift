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
import SVProgressHUD

class RootViewController: UIViewController {
    
    @IBOutlet private weak var mapView: AttentionMapView!
    @IBOutlet private weak var searchBar: GeoLocationSearchBar!
    @IBOutlet private weak var currentLocationButton: UIButton!
    @IBOutlet private weak var zoomInButton: UIButton!
    @IBOutlet private weak var zoomOutButton: UIButton!
    @IBOutlet private weak var menuButton: UIButton!
    @IBOutlet private weak var guideButton: UIButton!

    private var locationSelectViewController: LocationSelectViewController?
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

        NSNotificationCenter.defaultCenter().bnd_notification(UIKeyboardWillShowNotification, object: nil).observe {[weak self] (notification) in
            guard let userInfo = notification.userInfo else {return}
            guard let vc = self?.locationSelectViewController else {return}
            guard let frame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() else {return}
            guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double else {return}

            UIView.animateWithDuration(duration, animations: {
                guard let originalFrame = self?.locationSelectViewOriginalFrame else {return}
                vc.view.frame = originalFrame
                vc.view.frame.origin.y -= frame.size.height
            })
        }.disposeIn(bnd_bag)
        NSNotificationCenter.defaultCenter().bnd_notification(UIKeyboardWillHideNotification, object: nil).observe {[weak self] (notification) in
            guard let userInfo = notification.userInfo else {return}
            guard let vc = self?.locationSelectViewController else {return}
            guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double else {return}

            UIView.animateWithDuration(duration, animations: {
                guard let originalFrame = self?.locationSelectViewOriginalFrame else {return}
                vc.view.frame = originalFrame
            })
        }.disposeIn(bnd_bag)

        guideButton.bk_addEventHandler({[weak self] (button) in
            self?.showGuideView()
        }, forControlEvents: .TouchUpInside)

        menuButton.bk_addEventHandler({[weak self] (button) in
            self?.showMenu()
        }, forControlEvents: .TouchUpInside)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        focusOnUserLocation()
        searchItemsIfNeeded()
    }

    private func showGuideView() {
        if let vc = R.storyboard.guideViewController.initialViewController() {
            vc.view.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(view.bounds), height: CGRectGetHeight(view.bounds))

            let tap = UITapGestureRecognizer.bk_recognizerWithHandler({(recognizer, state, point) in
                if state == .Ended {
                    UIView.animateWithDuration(0.5, animations: {
                        vc.view.alpha = 0.0
                    }, completion: { (completed) in
                        vc.willMoveToParentViewController(nil)
                        vc.view.removeFromSuperview()
                    })
                }
            }) as! UITapGestureRecognizer
            view.addGestureRecognizer(tap)

            view.addSubview(vc.view)
            addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            vc.view.alpha = 0.0
            UIView.animateWithDuration(0.5, animations: {
                vc.view.alpha = 1.0
            })
        }
    }

    private func showMenu() {
        let vc = UIAlertController(title: NSLocalizedString("menu.title", comment: ""), message: nil , preferredStyle: .ActionSheet)
        vc.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        vc.addAction(UIAlertAction(title: NSLocalizedString("refresh.items", comment: ""), style: .Default) {[weak self] (action) in
            self?.searchItems()
            self?.dismissViewControllerAnimated(true, completion: nil)
        })
        presentViewController(vc, animated: true, completion: nil)

    }

    private static let mininumFetchInterval: NSTimeInterval = 60 * 60 * 24
    private func searchItemsIfNeeded() {
        let now = NSDate().timeIntervalSince1970
        let last = Settings.lastSavedTime
        if RootViewController.mininumFetchInterval < now - last {
            searchItems()
        } else {
            datasetDidChange(AttentionItemDataSource.sharedInstance)
        }
    }

    private static let zoomMagnification = 1.5
    private func zoom(zoomIn: Bool) {
        var region = self.mapView.region
        let span = region.span
        let magnification = RootViewController.zoomMagnification
        if zoomIn {
            region.span = MKCoordinateSpan(latitudeDelta: span.latitudeDelta / magnification, longitudeDelta: span.longitudeDelta / magnification)
        } else {
            region.span = MKCoordinateSpan(latitudeDelta: span.latitudeDelta * magnification, longitudeDelta: span.longitudeDelta * magnification)
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
    
    private lazy var locationSelectViewOriginalFrame: CGRect = {
        CGRect(x: 0, y: self.view.bounds.size.height - 150, width: self.view.bounds.size.width, height: 150)
    }()

    private func searchItems() {
        showProgess(NSLocalizedString("search.items", comment: ""))
        AttentionAPIClient.sharedClient.fetchItems(0, longitude: 0, radius: 0).on(success: {[weak self] response in
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
            self?.dismissProgress()
            Settings.lastSavedTime = NSDate().timeIntervalSince1970

        }) {[weak self] (error, isCancelled) in
            self?.showError(NSLocalizedString("search.items.failed", comment: ""))
            self?.datasetDidChange(AttentionItemDataSource.sharedInstance)
        }
    }
}

//MARK: - Search places
extension RootViewController {
    private func showLocationSearchResultView() {
        if locationSelectViewController != nil {
            hideMapItems(false)
        }

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
            vc.view.frame = self.locationSelectViewOriginalFrame
        })
    }

    private func searchLocation(locationName: String) {
        GeoLocationProvider.sharedInstance.searchLocation(locationName).on(success: {[weak self] (items) in
            self?.updateMapItems(items)
        }) {[weak self] (error, isCancelled) in
            self?.updateMapItems([])
        }
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

}

//MARK: - Add Item
extension RootViewController {
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
                if item.identifier.characters.count == 0 {
                    item.identifier = AttentionItemDataSource.createLocalIdentifier(item)
                }
                
                self?.dismissViewControllerAnimated(true, completion: completion)

            }, forControlEvents: .TouchUpInside)
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

    private func registerItem(item: AttentionItem) {

        let errorText: String? = {
            if item.placeName.characters.count == 0 || item.attentionBody.characters.count == 0 {
                return NSLocalizedString("alert.notext", comment: "")
            } else if MAX_PLACENAME_LENGTH < item.placeName.characters.count || MAX_ATTENTION_LENGTH < item.attentionBody.characters.count {
                return NSLocalizedString("alert.textlength", comment: "")
            } else {
                return nil
            }

        }()

        if let errorText = errorText {
            let vc = UIAlertController(title: NSLocalizedString("error", comment: ""), message: errorText, preferredStyle: .Alert)
            vc.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel) { (action) in
                self.dismissViewControllerAnimated(false, completion: nil)
                self.showAddingItemPopoverWithItem(item)
            })
            presentViewController(vc, animated: true, completion: nil)
            return
        }

        if item.shared {
            self.updateItem(item)
        } else {
            self.createItem(item)
        }
    }

    private func updateItem(item: AttentionItem) {
        self.showProgess(NSLocalizedString("update.item", comment: ""))
        AttentionAPIClient.sharedClient.updateItem(item).on(success: {[weak self] (item) in
            AttentionItemDataSource.sharedInstance.addAttentionItems([item])
            self?.dismissProgress()
        }, failure:{[weak self] (error, canceld) in
            self?.showError("update.item.failed")
        })
    }

    private func createItem(item: AttentionItem) {
            let vc = UIAlertController(title: NSLocalizedString("please.share.title", comment: ""), message: NSLocalizedString("please.share.body", comment: ""), preferredStyle: .Alert)

            vc.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .Default) { (action) in
                self.showProgess(NSLocalizedString("create.item", comment: ""))
                AttentionAPIClient.sharedClient.createNewItem(item).on(success: { (newItem) in
                    AttentionItemDataSource.sharedInstance.query(item.identifier).on(success: {[weak self] (result) in
                        if let result = result where 0 < result.identifier.characters.count {
                            print(result.identifier)
                            AttentionItemDataSource.sharedInstance.deleteAttentionItems([result])
                            AttentionItemDataSource.sharedInstance.addAttentionItems([newItem])
                        } else {
                            AttentionItemDataSource.sharedInstance.addAttentionItems([newItem])
                        }
                        self?.dismissProgress()
                    }, failure: {[weak self] (error, isCancelled) in
                        AttentionItemDataSource.sharedInstance.addAttentionItems([newItem])
                        self?.dismissProgress()
                    })
                }, failure: {[weak self] (error, isCancelled) in
                    /* 通信に失敗しても、とりあえずローカルのデータベースには保存しておく */
                    AttentionItemDataSource.sharedInstance.addAttentionItems([item])
                    self?.showError(NSLocalizedString("create.item.failed", comment: ""))
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

//MARK: Popover
extension RootViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        if let annotation = self.currentAnnotation {
            self.mapView.removeAnnotation(annotation)
        }
    }
}

//MARK: - AttentionMapViewDelegate
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

                vc.reportButton.bk_addEventHandler({[weak self] (button) in
                    self?.dismissViewControllerAnimated(true, completion: {
                        self?.reportItem(item)
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

    private func reportItem(item: AttentionItem) {
        let vc = UIAlertController(title: NSLocalizedString("report.title", comment: ""), message: NSLocalizedString("report.body", comment: ""), preferredStyle: .ActionSheet)
        vc.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Cancel) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        vc.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .Default) {[weak self] (action) in
            self?.showProgess(NSLocalizedString("reporting", comment: ""))
            TwitterClient.sharedClient.post(AttentionUtil.makeReportText(item)).on(success: { (result) in
                self?.showStatus(NSLocalizedString("report.done", comment: ""))
            }, failure: { (error, isCancelled) in
                self?.showError(NSLocalizedString("report.failed", comment: ""))
            })

            self?.dismissViewControllerAnimated(true, completion: nil)
        })
        presentViewController(vc, animated: true, completion: nil)
    }
}

//MARK: - AttentionItemDataSourceReceiver
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

//MARK: - Progress
extension RootViewController {
    private func showProgess(message: String) {
        SVProgressHUD.setDefaultMaskType(.Clear)
        SVProgressHUD.showWithStatus(message)
    }

    private func showStatus(status: String) {
        SVProgressHUD.setDefaultMaskType(.Clear)
        SVProgressHUD.showInfoWithStatus(status)
    }

    private func showError(message: String) {
        SVProgressHUD.showErrorWithStatus(message)
    }

    private func dismissProgress() {
        SVProgressHUD.dismiss()
    }
}
