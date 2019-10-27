//
//  Post.swift
//  BabylonApiService
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public struct Post: Codable
{
    public let id: Int
    public let userId: Int
    public let title: String
    public let body: String
}
