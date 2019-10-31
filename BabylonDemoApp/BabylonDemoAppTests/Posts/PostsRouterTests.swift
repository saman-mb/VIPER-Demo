//
//  PostsRouterTests.swift
//  BabylonDemoAppTests
//
//  Created by Saman Badakhshan on 30/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import XCTest
import PromiseKit
@testable import BabylonApiService
@testable import BabylonDemoApp

class PostsRouterTests: XCTestCase {

    var router: PostsRouter!
    var mockNvigator: MockPostsNavigator!
    
    override func setUp()
    {
        mockNvigator = MockPostsNavigator()
        router = PostsRouter(navigator: mockNvigator)
    }

    override func tearDown()
    {
        router = nil
        mockNvigator = nil
    }
    
    func testPushPostDetails_CallsNavigator()
    {
        let didCallNavigator = expectation(description: "Did call navigator")
        mockNvigator.pushBlock = { detailsViewController in
            didCallNavigator.fulfill()
        }
        router.pushPostDetails(for: Post(id: 1, userId: 2, title: "Saman", body: "Hello world"))
        waitForExpectations(timeout: 1)
    }
}
