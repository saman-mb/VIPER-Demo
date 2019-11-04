//
//  URLSession+Loading.swift
//  StarlingService
//
//  Created by Saman Badakhshan on 18/08/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public typealias JsonObject = [String:Any]
public typealias JsonRequestCompletionBlock = (RequestResult<JsonObject>) -> Void
public typealias DataRequestCompletionBlock = (RequestResult<Data>) -> Void

public enum HTTPMethod: String
{
    case GET, POST, PUT, DELETE
}

public enum URLSessionError: Error
{
    case unexpectedJsonFormat(Data)
    case unexpectedNilData
    case jsonParsingFailed(Error)
    case networkError(HTTPURLResponse?, Data?, Error?)
    
    public static func makeNetworkError(urlResponse: URLResponse?, data: Data?, error: Error?) -> URLSessionError
    {
        return URLSessionError.networkError((urlResponse as? HTTPURLResponse), data, error)
    }
}

public extension URLSessionType
{
    @discardableResult func downloadData(from url: URL,
                                         headers: [String: String],
                                         method: HTTPMethod = .GET,
                                         body: Data? = nil,
                                         completion: @escaping DataRequestCompletionBlock) -> URLSessionDataTaskType?
    {
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        urlRequest.timeoutInterval = 5.0
        
        return downloadData(from: urlRequest, completion: completion)
    }
    
    //MARL:- Private Helpers
    @discardableResult private func downloadData(from urlRequest: URLRequest, completion: @escaping DataRequestCompletionBlock) -> URLSessionDataTaskType?
    {
        let task = dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error
            {
                completion(.error(URLSessionError.makeNetworkError(urlResponse: response, data: data, error: error)))
            }
            else if URLSession.isErrorResponse(response as? HTTPURLResponse)
            {
                completion(.error(URLSessionError.makeNetworkError(urlResponse: response, data: data, error: nil)))
            }
            else if let data = data
            {
                completion(.success(data))
            }
            else
            {
                completion(.error(URLSessionError.unexpectedNilData))
            }
        }
        
        task.resume()
        return task
    }
    
    private static func isErrorResponse(_ response: HTTPURLResponse?) -> Bool {
        guard let urlResponse = response else {
            return false
        }
        return isStatusCode(urlResponse.statusCode, inRange: 400...599)
    }
    
    private static func isStatusCode(_ statusCode: Int, inRange range: ClosedRange<Int>) -> Bool {
        return range.contains(statusCode)
    }
}
