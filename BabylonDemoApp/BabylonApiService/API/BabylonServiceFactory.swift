//
//  BabylonServiceFactory.swift
//  BabylonApiService
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public final class BabylonServiceFactory
{
    public static func makeApi(configration: BabylonApiConfigurationProvider, urlSession: URLSessionType = URLSession.shared) -> BabylonApi
    {
        return BabylonApiImplementation(configration: configration, urlSession: urlSession)
    }
}
