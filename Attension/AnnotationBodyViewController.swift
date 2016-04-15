//
//  AnnotationBodyViewController.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/16.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit

class AnnotationBodyViewController: UIViewController {

    static func viewController() -> AnnotationBodyViewController {
        guard let vc = R.storyboard.annotationBodyViewController.initialViewController() else {
            fatalError()
        }

        return vc
    }

    @IBOutlet weak private(set) var titleLabel: UILabel!
    @IBOutlet weak private(set) var bodyLabel: UILabel!
}
