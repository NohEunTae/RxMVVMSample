//
//  Protocols.swift
//  TestProject
//
//  Created by NohEunTae on 2020/06/08.
//  Copyright © 2020 NohEunTae. All rights reserved.
//

import UIKit

protocol AnyNameable {
    static func className() -> String
}

extension AnyNameable {
    static func className() -> String {
        return String(describing: self)
    }
}

extension NSObject: AnyNameable {}

protocol Registrable {
    func register(cellClass: AnyClass)
    func registerCellXib(cellClass: AnyClass)
}

extension UICollectionView: Registrable {
    func register(cellClass: AnyClass) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }

    func registerCellXib(cellClass: AnyClass) {
        let nib = UINib(nibName: String(describing: cellClass), bundle: nil)
        register(nib, forCellWithReuseIdentifier: String(describing: cellClass))
    }
}

extension UITableView: Registrable {
    func register(cellClass: AnyClass) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }

    func registerCellXib(cellClass: AnyClass) {
        let nib = UINib(nibName: String(describing: cellClass), bundle: nil)
        register(nib, forCellReuseIdentifier: String(describing: cellClass))
    }
}
