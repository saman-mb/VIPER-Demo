//
//  User.swift
//  BabylonApiService
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public struct User: Codable
{
    public let id: String
    public let name: String
    public let username: String
    public let email: String
    public let address: String
    public let street: String
    public let suite: String
    public let city: String
    public let zipcode: String
    public let geo: GeoLocation
    public let phone: String
    public let website: String
    public let company: Company
}

