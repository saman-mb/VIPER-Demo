//
//  Data+Decoding.swift
//  StarlingService
//
//  Created by Saman Badakhshan on 18/08/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

public extension Data {
    
    func decodeJson<D: Decodable>() -> RequestResult<D>
    {
        do
        {
            let object = try JSONDecoder().decode(D.self, from: self)
            return .success(object)
        }
        catch
        {
            return .error(error)
        }
    }
}

public extension Data
{
    func decoded<T: Decodable>() -> T?
    {
        return try? JSONDecoder().decode(T.self, from: self)
    }
}
