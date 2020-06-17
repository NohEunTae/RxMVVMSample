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

    let currentPage = BehaviorRelay<Int>(value: 1)
    let filter = BehaviorRelay<Filter>(value: .newest)

    let itemFetchFinished = PublishSubject<Void>()
    private(set) var items: [Data] = []
    
    let purchaseTap = PublishSubject<Void>()
    let likeTap = PublishSubject<Void>()
    let like = BehaviorRelay<Bool>(value: false)
    
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
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                response.meta.next_page == 2 || response.meta.next_page == 0
                    ? self.items = response.data
                    : self.items.append(contentsOf: response.data)
                
                self.nextPage = response.meta.next_page
                self.itemFetchFinished.onNext(())
            }, onError: { [weak self] (error) in
                self?.itemFetchFinished.onError(error)
            }).disposed(by: disposeBag)

        purchaseTap
            .flatMapLatest(NetworkManager.shared.purchaseItem)
            .subscribe()
            .disposed(by: disposeBag)
        
        likeTap
            .flatMapLatest(NetworkManager.shared.like)
            .subscribe({ [weak self] _ in
                guard let self = self else {return }
                self.like.accept(!self.like.value)
            })
            .disposed(by: disposeBag)
    }
    
    func availableNextPageIfCan() -> Int? {
        (isNextPageExist && !isFetchingNextPage) ? nextPage : nil
    }
}
