//
//  AnnotationBodyViewController.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/16.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit

class AnnotationBodyViewController: UIViewController {

    @IBOutlet private weak var titleContainerScrollView: UIScrollView!
    @IBOutlet private weak var bodyContainerScrollView: UIScrollView!
    @IBOutlet private weak var sharedStatusLabel: UILabel!
    @IBOutlet private(set) weak var editButton: UIButton!

    private var item: AttentionItem!

    static func viewController(item: AttentionItem?) -> AnnotationBodyViewController {
        guard let vc = R.storyboard.annotationBodyViewController.initialViewController() else {
            fatalError()
        }

        vc.item = item
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateSharedState()
        setupPlaceName()
        setupBody()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bodyLabel.bounds.size.width = bodyContainerScrollView.bounds.width
        bodyLabel.sizeToFit()
        bodyLabel.frame.origin.x = 0
        bodyLabel.frame.origin.y = 0

        placeNameLabel.sizeToFit()
        placeNameLabel.frame.origin.x = 0
        placeNameLabel.frame.origin.y = 0

        titleContainerScrollView.contentSize = placeNameLabel.bounds.size
        bodyContainerScrollView.contentSize = bodyLabel.bounds.size

    }

    private var placeNameLabel: UILabel!
    private func setupPlaceName() {
        titleContainerScrollView.subviews.forEach{$0.removeFromSuperview()}
        let label = UILabel()
        label.text = item.placeName
        label.font = UIFont.boldSystemFontOfSize(14)
        label.numberOfLines = 1
        placeNameLabel = label
        titleContainerScrollView.addSubview(label)
    }


    private var bodyLabel: UILabel!
    private func setupBody() {
        let label = UILabel()
        label.text = item.attentionBody
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 0

        bodyLabel = label
        bodyContainerScrollView.addSubview(label)
    }

    private func updateSharedState() {
        if item.shared {
            sharedStatusLabel.text = NSLocalizedString("shared", comment: "")
            sharedStatusLabel.textColor = UIColor.blueColor()
        } else {
            sharedStatusLabel.text = NSLocalizedString("notshared", comment: "")
            sharedStatusLabel.textColor = UIColor.orangeColor()
        }
    }
}
