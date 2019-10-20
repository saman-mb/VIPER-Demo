//
//  UrlSessionType.swift
//  StarlingService
//
//  Created by Saman Badakhshan on 18/08/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public protocol URLSessionDataTaskType
{
    func cancel()
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskType {
}

public protocol URLSessionType {
    
    typealias DataTaskCompletionBlock = (Data?, URLResponse?, Error?) -> Void
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletionBlock) -> URLSessionDataTaskType
}

extension URLSession: URLSessionType {
    
    public func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletionBlock) -> URLSessionDataTaskType {
        
        return dataTask(with:request, completionHandler:completionHandler) as URLSessionDataTask
    }
}
