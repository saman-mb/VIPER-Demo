//
//  User.swift
//  BabylonApiService
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public struct Address: Codable, Equatable
{
    public let street: String
    public let suite: String
    public let city: String
    public let zipcode: String
    public let geo: GeoLocation
}

public struct User: Codable, Equatable
{
    public let id: Int
    public let name: String
    public let username: String
    public let email: String
    public let address: Address
    public let phone: String
    public let website: String
    public let company: Company
}

