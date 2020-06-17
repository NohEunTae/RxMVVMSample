//
//  Views.swift
//  TestProject
//
//  Created by NohEunTae on 2020/06/08.
//  Copyright © 2020 NohEunTae. All rights reserved.
//

import UIKit
import SnapKit

final class Cell: UITableViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    func configure(item: Data) {
        label.text = "name: \(item.name)\n\nage: \(item.age) value: \(item.value)"
    }
}

final class FilterButton: UIButton {
    let filter: Filter
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = filter.rawValue
        label.layer.cornerRadius = 5
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 2
        label.textAlignment = .center

        return label
    }()
    
    init(filter: Filter) {
        self.filter = filter
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(35)
        }
    }
}
