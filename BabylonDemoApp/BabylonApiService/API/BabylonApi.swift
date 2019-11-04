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
    typealias GenericCompletion<T> = (RequestResult<T>) -> Void
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

final class BabylonApiImplementation
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
    func posts(_ completion: @escaping (RequestResult<[Post]>) -> Void)
    {
        guard let url = URL(string: configration.postsEndpoont) else {
            completion(.error(BabylonApiError.invalidUrl))
            return
        }
        executeRequest(withUrl: url, completion)
    }
    
    func users(_ completion: @escaping (RequestResult<[User]>) -> Void)
    {
        guard let url = URL(string: configration.usersEndpoint) else {
            completion(.error(BabylonApiError.invalidUrl))
            return
        }
        executeRequest(withUrl: url, completion)
    }
    
    func comments(_ completion: @escaping (RequestResult<[Comment]>) -> Void)
    {
        guard let url = URL(string: configration.commentsEndpoint) else {
            completion(.error(BabylonApiError.invalidUrl))
            return
        }
        executeRequest(withUrl: url, completion)
    }
    
    
    //MARK:- Helpers
    private func executeRequest<T: Decodable>(withUrl url: URL, _ completion: @escaping (RequestResult<T>) -> Void)
    {
        urlSession.downloadData(from: url, headers: configration.headers, method: .GET) { dataResult in
            self.handleResult(dataResult, completion)
        }
    }
    
    // using generics here in order to avoid having a different result handling function for every API call above
    private func handleResult<T: Decodable>(_ dataResult: RequestResult<Data>, _ completion: @escaping (RequestResult<T>)-> Void)
    {
        switch dataResult
        {
        case .success(let data):
            processResponseData(data, completion)
        case .error(let error):
            completion(.error(BabylonApiError.requestFailed(error)))
        }
    }
    
    private func processResponseData<T: Decodable>(_ data: (Data), _ completion: (RequestResult<T>) -> Void)
    {
        let accountsResult: RequestResult<T> = data.decodeJson()
        switch accountsResult {
        case .success(let accountsResponse):
            completion(.success(accountsResponse))
        case .error(let error):
            completion(.error(BabylonApiError.failedToDecodeJson(error)))
        }
    }
}
