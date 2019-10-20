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
    let id: String
    let name: String
    let username: String
    let email: String
    let address: String
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: GeoLocation
    let phone: String
    let website: String
    let company: Company
}

