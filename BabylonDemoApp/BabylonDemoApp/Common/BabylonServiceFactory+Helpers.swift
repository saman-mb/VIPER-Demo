//
//  BabylonServiceFactory+Helpers.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 28/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import BabylonApiService

extension BabylonServiceFactory
{
    static func makeApi() -> BabylonApi
    {
        return BabylonServiceFactory.makeApi(configration: BabylonApiConfiguration())
    }
}
