//
//  Model.swift
//  MVVMSample
//
//  Created by Fumiya Tanaka on 2019/12/19.
//  Copyright © 2019 FumiyaTanaka. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class Model {
    
    let client: HTTPRepository
    
    init(client: HTTPRepository = HTTPClient()) {
        self.client = client
    }
    
    func persist<T: Encodable>(value: T) -> Single<Void> {
        .create { [weak self] singleEvent -> Disposable in
            
            guard let self = self else { return Disposables.create() }
            
            var request = URLRequest(url: URL(string: "http://localhost:8080/ramen")!)
            request.httpBody = try? JSONEncoder().encode(value)
            request.httpMethod = "POST"
            
            self.client.persist(request: request) { error in
                if let error = error {
                    singleEvent(.error(error))
                    return
                }
                singleEvent(.success(()))
            }
            
            return Disposables.create()
        }
    }
}
