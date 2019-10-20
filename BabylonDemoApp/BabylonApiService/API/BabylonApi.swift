//
//  StarlingApi.swift
//  StarlingService
//
//  Created by Saman Badakhshan on 18/08/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public protocol BabylonApi
{
    typealias GenericCompletion<T> = (Result<T>) -> Void
    func posts(_ completion: @escaping GenericCompletion<[Post]>)
    func users(_ completion: @escaping GenericCompletion<[User]>)
    func comments(_ completion: @escaping GenericCompletion<[Comment]>)
}

public enum BabylonApiError: Error
{
    case requestFailed(Error)
    case invalidUrl
    case failedToDecodeJson(Error)
}

final internal class BabylonApiImplementation
{
    private let urlSession: URLSessionType
    private let configration: BabylonApiConfigurationProvider
    
    init(configration: BabylonApiConfigurationProvider,
         urlSession: URLSessionType = URLSession.shared)
    {
        self.urlSession = urlSession
        self.configration = configration
    }
}

extension BabylonApiImplementation: BabylonApi
{
    func posts(_ completion: @escaping (Result<[Post]>) -> Void)
    {
        guard let url = URL(string: configration.postsEndpoont) else {
            completion(.error(BabylonApiError.invalidUrl))
            return
        }

        executeRequeast(withUrl: url, completion)
    }
    
    func users(_ completion: @escaping (Result<[User]>) -> Void)
    {
        guard let url = URL(string: configration.usersEndpoint) else {
            completion(.error(BabylonApiError.invalidUrl))
            return
        }

        executeRequeast(withUrl: url, completion)
    }
    
    func comments(_ completion: @escaping (Result<[Comment]>) -> Void)
    {
        guard let url = URL(string: configration.commentsEndpoint) else {
            completion(.error(BabylonApiError.invalidUrl))
            return
        }

        executeRequeast(withUrl: url, completion)
    }
    
    
    //MARK:- Helpers
    @discardableResult
    private func executeRequeast<T: Decodable>(withUrl url: URL, _ completion: @escaping (Result<T>) -> Void) -> URLSessionDataTaskType?
    {
        return urlSession.downloadData(from: url, headers: configration.headers, method: .GET) { dataResult in
            self.handleResult(dataResult, completion)
        }
    }
    
    // using generics here in order to avoid having a different result handling function for every API call above
    private func handleResult<T: Decodable>(_ dataResult: Result<Data>, _ completion: @escaping (Result<T>)-> Void)
    {
        switch dataResult
        {
        case .success(let data):
            let accountsResult: Result<T> = data.decodeJson()
            switch accountsResult {
            case .success(let accountsResponse):
                completion(.success(accountsResponse))
            case .error(let error):
                completion(.error(BabylonApiError.failedToDecodeJson(error)))
            }
            
        case .error(let error):
            completion(.error(BabylonApiError.requestFailed(error)))
        }
    }
}
