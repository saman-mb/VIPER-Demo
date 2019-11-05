//
//  Comment.swift
//  BabylonApiService
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public struct Comment: Codable, Equatable
{
    public let postId: Int
    public let id: Int
    public let name: String
    public let email: String
    public let body: String
}
