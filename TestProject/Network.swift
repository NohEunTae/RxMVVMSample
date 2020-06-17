//
//  Network.swift
//  TestProject
//
//  Created by NohEunTae on 2020/06/08.
//  Copyright © 2020 NohEunTae. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

final class Meta: Equatable {
    static func == (lhs: Meta, rhs: Meta) -> Bool {
        lhs.next_page == rhs.next_page
    }
    
    var next_page: Int
    
    init(next_page: Int = 0) {
        self.next_page = next_page
    }
}

final class Response: Equatable {
    static func == (lhs: Response, rhs: Response) -> Bool {
        lhs.data == rhs.data && lhs.meta == rhs.meta
    }
    
    var data: [Data]
    private(set) var meta: Meta
    
    init(data: [Data] = [], meta: Meta = Meta()) {
        self.data = data
        self.meta = meta
    }
}

func request(url: String, parameters: Alamofire.Parameters?) -> Single<Response> {
    return Single<Response>.create { single -> Disposable in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            var response = Response()
            /* ---------------------------- for test ---------------------------- */
            if let page = parameters?["page"] as? Int,
                let orderBy = parameters?["order_by"] as? String,
                let filter = Filter(rawValue: orderBy) {

                var data: [Data] = []
                
                let name = filter.rawValue
                print("\(name) called page: \(page)")
                
                for i in 1..<21 {
                    data.append(Data(value: (page - 1) * 20 + i, name: name, age: Int.random(in: 20..<40)))
                }
                
                response = Response(data: data, meta: Meta(next_page: page + 1))
            }
            /* ------------------------------------------------------------------- */

            DispatchQueue.main.async {
                single(.success(response))
            }
        }
        return Disposables.create()
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchItems(page: Int, filter: Filter) -> Single<Response> {
        let url = ""
        let params: [String: Any] = [
            "page" : page,
            "per_page" : 20,
            "order_by" : filter.rawValue,
        ]

        return request(url: url, parameters: params)
    }
    
    func purchaseItem() -> Single<Response> {
        return request(url: "", parameters: nil)
    }
    
    func like() -> Single<Response> {
        return request(url: "", parameters: nil)
    }
}
