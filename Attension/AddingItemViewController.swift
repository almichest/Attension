//
//  AddingItemViewController.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/14.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit

class AddingItemViewController: UIViewController {

    @IBOutlet weak private(set) var doneButton: UIButton!
    
    @IBOutlet weak private(set) var whereTextField: UITextField!
    @IBOutlet weak private(set) var whatTextView: UITextView!
    
    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = "ex) めっちゃ人多い"
        label.sizeToFit()
        label.font = UIFont.systemFontOfSize(14)
        label.alpha = 0.2
        return label
    }()
    
    static func viewController() -> AddingItemViewController {
        guard let vc = R.storyboard.addingItemViewController.initialViewController() else {
            fatalError()
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        whatTextView.layer.borderColor = UIColor(red: 225.0 / 255.0, green: 225.0 / 255.0, blue: 225.0 / 255.0, alpha: 1.0).CGColor
        whatTextView.layer.borderWidth = 1.0
        whatTextView.layer.cornerRadius = 5.0
        whatTextView.delegate = self
        
        whatTextView.addSubview(placeHolderLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        placeHolderLabel.frame.origin.x = 8
        placeHolderLabel.frame.origin.y = 4
    }
}

extension AddingItemViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        placeHolderLabel.hidden = (0 < textView.text.characters.count)
    }
}
