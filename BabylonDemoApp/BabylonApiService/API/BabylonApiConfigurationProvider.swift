//
//  StarlingApiConfigurationProvider.swift
//  StarlingService
//
//  Created by Saman Badakhshan on 18/08/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public protocol BabylonApiConfigurationProvider
{
    var headers: [String: String] { get}
    var postsEndpoont: String { get}
    var usersEndpoint: String { get }
    var commentsEndpoint: String { get }
}

