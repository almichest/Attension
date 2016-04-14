//
//  AddingItemViewController.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/14.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit

class AddingItemViewController: UIViewController {

    static func viewController() -> AddingItemViewController {
        guard let vc = R.storyboard.addingItemViewController.initialViewController() else {
            fatalError()
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didPushCancelButton(sender: UIButton) {
    }

    @IBAction func didPushDoneButton(sender: UIButton) {
    }
}
