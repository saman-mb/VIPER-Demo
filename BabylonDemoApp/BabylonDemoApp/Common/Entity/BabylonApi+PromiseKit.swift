//
//  BabylonApi+PromiseKit.swift
//  BabylonApiService
//
//  Created by Saman Badakhshan on 26/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import BabylonApiService
import PromiseKit

public extension BabylonApi
{
    func posts() -> Promise<[Post]>
    {
        return Promise { seal in
            posts { result in
                self.handleResult(result, seal)
            }
        }
    }
    
    func users() -> Promise<[User]>
    {
        return Promise { seal in
            users { result in
                self.handleResult(result, seal)
            }
        }
    }
    
    func comments() -> Promise<[Comment]>
    {
        return Promise { seal in
            comments { result in
                self.handleResult(result, seal)
            }
        }
    }
    
    //MARK:- Helpers
    private func handleResult<T>(_ result: BabylonApiService.RequestResult<T>, _ seal: Resolver<T>)
    {
        switch result
        {
        case .success(let posts):
            seal.fulfill(posts)
        case .error(let error):
            seal.reject(error)
        }
    }
}
