//
//  DispatchQueue+Helpers.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 28/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

extension DispatchQueue
{
    static var userIntiatedGlobal: DispatchQueue
    {
        return DispatchQueue.global(qos: .userInitiated)
    }
}
