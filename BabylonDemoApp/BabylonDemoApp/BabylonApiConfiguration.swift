//
//  BabylonApiConfiguration.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import BabylonApiService

public struct BabylonApiConfiguration: BabylonApiConfigurationProvider
{
    public var headers: [String : String]
    {
        return ["Accept": "application/json",
                "Content-Type": "application/json"]
    }
    
    public var postsEndpoont: String
    {
        return "\(host)/posts"
    }
    
    public var usersEndpoint: String
    {
        return "\(host)/users"
    }
    
    public var commentsEndpoint: String
    {
        return "\(host)/comments"
    }
    
    private var host: String
    {
        return "http://jsonplaceholder.typicode.com"
    }
}

