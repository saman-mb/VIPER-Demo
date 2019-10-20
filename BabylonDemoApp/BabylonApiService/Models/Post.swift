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
    let id: String
    let userId: String
    let title: String
    let body: String
}
