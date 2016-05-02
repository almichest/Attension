//
//  GeoLocationSearchBar.swift
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/07.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

import UIKit

class GeoLocationSearchBar: UISearchBar {
    
    var searchHandler: ((UISearchBar) -> Void)?
    var startHandler: ((UISearchBar) -> Void)?
    var determineHandler: ((UISearchBar) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
}

extension GeoLocationSearchBar: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if let handler = startHandler {
            handler(searchBar)
        }
        
        if let handler = searchHandler {
            handler(searchBar)
        }
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let handler = searchHandler {
            handler(searchBar)
        }
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let handler = determineHandler {
            handler(searchBar)
        }
    }
}