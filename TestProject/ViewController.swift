//
//  ViewController.swift
//  TestProject
//
//  Created by NohEunTae on 2020/05/21.
//  Copyright © 2020 NohEunTae. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController {
    
    private let purchaseButton: UIButton = {
        let button = UIButton()
        button.setTitle("구매", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setTitle("❤️", for: .selected)
        button.setTitle("💔", for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    private let filterButtons: [FilterButton] = [
        .init(filter: .newest),
        .init(filter: .oldest),
        .init(filter: .popular)
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellClass: Cell.self)
        return tableView
    }()
    
    private var disposeBag = DisposeBag()
    private var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bindUserInteractions()
        bindOutput()
    }
    
    private func setupViews() {
        for (idx, button) in filterButtons.enumerated() {
            view.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.width.height.equalTo(100)
                make.top.equalToSuperview().inset(50)
                make.leading.equalToSuperview().inset(idx * 90)
            }
        }
        
        view.addSubview(likeButton)
        likeButton.snp.makeConstraints { (make) in
            make.bottom.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(50)
        }
        
        view.addSubview(purchaseButton)
        purchaseButton.snp.makeConstraints { (make) in
            make.bottom.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(likeButton.snp.leading).offset(-20)
            make.height.equalTo(50)
        }
        
        let button = filterButtons.first!
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(button.snp.bottom).offset(-20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(purchaseButton.snp.top).offset(-20)
        }
    }
    
    private func bindUserInteractions() {
        purchaseButton.rx.tap
            .bind(to: viewModel.purchaseTap)
            .disposed(by: disposeBag)
        
        likeButton.rx.tap
            .bind(to: viewModel.likeTap)
            .disposed(by: disposeBag)
        
        filterButtons.forEach { item in
            let filter = item.rx.tap.map { _ in item.filter }
            filter.bind(to: viewModel.filter).disposed(by: disposeBag)
        }
        
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] (_, indexPath) in
                self?.viewModel.updatePageIfNeeded(row: indexPath.row)
            }).disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        viewModel.error.subscribe(onNext: { error in
            print("Error : \(error.localizedDescription)")
        }).disposed(by: disposeBag)
        
        viewModel.itemFetchFinished
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.filter
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, self.tableView.visibleCells.isNotEmpty else { return }
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }).disposed(by: disposeBag)

        viewModel.like.subscribe(onNext: { [weak self] value in
            let alert = UIAlertController(title: "좋아요 변경 \(value)", message: "성공", preferredStyle: .alert)
            alert.addAction(.init(title: "확인", style: .cancel, handler: { _ in
                self?.likeButton.isSelected = value
            }))
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.purchaseTap.subscribe(onNext: { [weak self] _ in
            let alert = UIAlertController(title: "구매하기", message: "성공", preferredStyle: .alert)
            alert.addAction(.init(title: "확인", style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.className(), for: indexPath) as? Cell else {
            return UITableViewCell()
        }
        
        cell.configure(item: viewModel.items[indexPath.row])
        return cell
    }
}
