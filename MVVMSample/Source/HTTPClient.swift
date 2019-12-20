//
//  HTTPClient.swift
//  MVVMSample
//
//  Created by Fumiya Tanaka on 2019/12/19.
//  Copyright © 2019 FumiyaTanaka. All rights reserved.
//

import Foundation

protocol HTTPRepository {
    func read(request: URLRequest, completion: @escaping (Result<Data, HTTPClient.HTTPError>) -> ())
    func read(session: URLSession, request: URLRequest, completion: @escaping (Result<Data, HTTPClient.HTTPError>) -> ())
    func persist(request: URLRequest, completion: @escaping (HTTPClient.HTTPError?) -> ())
    func persist(session: URLSession, request: URLRequest, completion: @escaping (HTTPClient.HTTPError?) -> ())
}

extension HTTPRepository {
    func read(request: URLRequest, completion: @escaping (Result<Data, HTTPClient.HTTPError>) -> ()) {
        self.read(session: .shared, request: request, completion: completion)
    }
    
    func persist(request: URLRequest, completion: @escaping (HTTPClient.HTTPError?) -> ()) {
        self.persist(session: .shared, request: request, completion: completion)
    }
}

class HTTPClient: HTTPRepository {
    
    enum HTTPError: Error {
        case incorrectHTTPMethod
        case emptyBody
        case serverError(Error)
    }
    
    func read(session: URLSession, request: URLRequest, completion: @escaping (Result<Data, HTTPError>) -> ()) {
        
        if request.httpMethod != "GET" {
            completion(.failure(.incorrectHTTPMethod))
            return
        }
        
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.serverError(error)))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data else { fatalError() }
            completion(.success(data))
        }.resume()
    }
    
    func persist(session: URLSession, request: URLRequest, completion: @escaping (HTTPError?) -> ()) {
        
        if request.httpMethod != "POST" {
            completion(.incorrectHTTPMethod)
            return
        }
        
        if request.httpBody == nil {
            completion(.emptyBody)
            return
        }
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                completion(.serverError(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                fatalError()
            }
            completion(nil)
            
        }.resume()
    }
    
}
