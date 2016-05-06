//
//  AttentionMapView.swift
//  Attention
//
//  Created by Hiraku Ohno on 2016/04/25.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit
import MapKit

class AttentionMapView: MKMapView {

    private var zoomCompletion: (() -> Void)?
    weak var attentionDelegate: AttentionMapViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }

    func setRegion(region: MKCoordinateRegion, animated: Bool, completion: (() -> Void)?) {
        zoomCompletion = completion
        self.setRegion(region, animated: animated)
    }
}

extension AttentionMapView: MKMapViewDelegate {

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        zoomCompletion?()
        zoomCompletion = nil
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        attentionDelegate?.mapView(self, didSelectAnnotationView: view)
    }
}

protocol AttentionMapViewDelegate: class {
    func mapView(mapView: AttentionMapView, didSelectAnnotationView view: MKAnnotationView)
}