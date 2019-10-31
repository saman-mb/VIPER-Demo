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
    
    @discardableResult public func asyncAfter(seconds delay: TimeInterval, execute block: @escaping ()->Void) -> DispatchWorkItem
    {
        let dispatchWorkItem = DispatchWorkItem(block: block)
        let deadlineTime = DispatchTime.now() + delay
        self.asyncAfter(deadline: deadlineTime, execute: dispatchWorkItem)
        return dispatchWorkItem
    }
}
