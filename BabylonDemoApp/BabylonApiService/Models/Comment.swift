//
//  Comment.swift
//  BabylonApiService
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public struct Comment: Codable
{
    let postId: String
    let id: String
    let name: String
    let email: String
    let body: String
}
