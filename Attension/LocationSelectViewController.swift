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
        guard let vc = R.storyboard.locationSelectViewController.initialViewController() else {
            fatalError()
        }
        
        vc.mapItems = mapItems
        return vc
    }
    
    private var mapItems: [MKMapItem]?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension LocationSelectViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let mapItems = mapItems else {return 0}
        return mapItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.locationCell) else {
            fatalError()
        }
        if let item = mapItems?[indexPath.row] {
            cell.textLabel?.text = item.name
        }
        
        return cell
    }
}

extension LocationSelectViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
}