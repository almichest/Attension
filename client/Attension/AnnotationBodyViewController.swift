//
//  AnnotationBodyViewController.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/16.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit

class AnnotationBodyViewController: UIViewController {

    @IBOutlet weak var titleContainerScrollView: UIScrollView!
    @IBOutlet weak var bodyContainerScrollView: UIScrollView!

    static func viewController() -> AnnotationBodyViewController {
        guard let vc = R.storyboard.annotationBodyViewController.initialViewController() else {
            fatalError()
        }

        return vc
    }

    var placeName: String? {
        didSet {
            titleContainerScrollView.subviews.forEach{$0.removeFromSuperview()}
            let label = UILabel()
            label.text = placeName
            label.font = UIFont.boldSystemFontOfSize(14)
            label.numberOfLines = 1
            label.sizeToFit()
            label.frame.origin.x = 0
            label.frame.origin.y = 0
            titleContainerScrollView.addSubview(label)
            titleContainerScrollView.contentSize = label.bounds.size
        }
    }

    var bodyText: String? {
        didSet {
            bodyContainerScrollView.subviews.forEach{$0.removeFromSuperview()}
            let label = UILabel()
            label.text = bodyText
            label.font = UIFont.systemFontOfSize(14)
            label.bounds.size.width = bodyContainerScrollView.bounds.width
            label.numberOfLines = 0
            label.sizeToFit()
            label.frame.origin.x = 0
            label.frame.origin.y = 0
            bodyContainerScrollView.addSubview(label)
            bodyContainerScrollView.contentSize = label.bounds.size
        }
    }
}
