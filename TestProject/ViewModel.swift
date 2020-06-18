//
//  ViewModel.swift
//  TestProject
//
//  Created by NohEunTae on 2020/06/08.
//  Copyright © 2020 NohEunTae. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum Filter: String {
    case newest, oldest, popular
}

final class Data: Equatable {
    static func == (lhs: Data, rhs: Data) -> Bool {
        lhs.age == rhs.age && lhs.name == rhs.name && lhs.value == rhs.value
    }
    
    var value: Int
    let name: String
    let age: Int
    
    init(value: Int, name: String, age: Int) {
        self.value = value
        self.name = name
        self.age = age
    }
}

final class ViewModel {
    private let initalPage = 1
    private(set) var nextPage: Int?
    
    private var isNextPageExist: Bool {
        nextPage != nil && nextPage != 1
    }
    
    private var isFetchingNextPage: Bool {
        nextPage == currentPage.value
    }
    
    private var isFirstPage: Bool {
        currentPage.value == initalPage
    }
    
    private func resetPage() {
        self.currentPage.accept(initalPage)
    }
    
    private func availableNextPageIfCan() -> Int? {
        (isNextPageExist && !isFetchingNextPage) ? nextPage : nil
    }

    let currentPage = BehaviorRelay<Int>(value: 1)
    let filter = BehaviorRelay<Filter>(value: .newest)

    let itemFetchFinished = PublishSubject<Void>()
    private(set) var items: [Data] = []
    
    let purchaseTap = PublishRelay<Void>()
    let likeTap = PublishRelay<Void>()
    let like = BehaviorRelay<Bool>(value: false)
    
    let error = PublishRelay<Error>()
    
    private var disposeBag = DisposeBag()
    
    init() {
        bind()
    }
    
    private func bind() {
        filter
            .skip(initalPage)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.resetPage()
            })
            .disposed(by: disposeBag)
        
        currentPage
            .withUnretained(self)
            .map { `self`, page -> (Int, Filter) in (page, self.filter.value) }
            .flatMapLatest(NetworkManager.shared.fetchItems)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let response):
                    self?.setItems(using: response.meta.next_page, data: response.data)
                    self?.nextPage = response.meta.next_page
                    self?.itemFetchFinished.on(.next(()))
                case .failure(let error):
                    self?.error.accept(error)
                }
                
            }).disposed(by: disposeBag)

        purchaseTap
            .flatMapLatest(NetworkManager.shared.purchaseItem)
            .subscribe(onNext: { [weak self] result in
                if case .failure(let error) = result {
                    self?.error.accept(error)
                }
            })
            .disposed(by: disposeBag)
        
        likeTap
            .flatMapLatest(NetworkManager.shared.like)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else {return }
                switch result {
                case .success:
                    self.like.accept(!self.like.value)
                case .failure(let error):
                    self.error.accept(error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setItems(using nextPage: Int, data: [Data]) {
        nextPage == 2 || nextPage == 0
            ? self.items = data
            : self.items.append(contentsOf: data)
    }
    
    func updatePageIfNeeded(row: Int) {
        if let nextPage = availableNextPageIfCan(),
            items.count - 1 == row {
            currentPage.accept(nextPage)
        }
    }
}
