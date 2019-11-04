//
//  Result.swift
//  StarlingService
//
//  Created by Saman Badakhshan on 18/08/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public enum RequestResult<T>
{
    case success(T)
    case error(Error)
}
