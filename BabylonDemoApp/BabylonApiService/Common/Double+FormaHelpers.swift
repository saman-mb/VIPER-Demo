//
//  Double+FormaHelpers.swift
//  StarlingService
//
//  Created by Saman Badakhshan on 18/08/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation

extension Double
{
    public func currencyString() -> String?
    {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.numberStyle = .currency
        return formatter.string(from: self as NSNumber)
    }
}
