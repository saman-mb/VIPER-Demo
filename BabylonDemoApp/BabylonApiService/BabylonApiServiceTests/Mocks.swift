//
//  Mocks.swift
//  BabylonApiServiceTests
//
//  Created by Saman Badakhshan on 05/11/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
@testable import BabylonApiService

class MockConfiguration: BabylonApiConfigurationProvider
{
    var headers: [String : String] = ["test": "123"]
    var postsEndpoont: String = "https://saman.com/posts"
    var usersEndpoint: String = "https://saman.com/abcd/users"
    var commentsEndpoint: String = "https://saman.com/abcd/comments"
}

class MockDataTask: URLSessionDataTaskType
{
    func cancel() {}
    func resume() {}
}

class MockUrlSession: URLSessionType
{
    var dataTaskClosure: ((URLRequest, DataTaskCompletionBlock) -> URLSessionDataTaskType)?
    
    init() {}
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletionBlock) -> URLSessionDataTaskType
    {
        return dataTaskClosure?(request, completionHandler) ?? MockDataTask()
    }
}
