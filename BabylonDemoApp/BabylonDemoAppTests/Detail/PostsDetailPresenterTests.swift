//
//  PostsDetailPresenterTests.swift
//  BabylonDemoAppTests
//
//  Created by Saman Badakhshan on 30/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import XCTest
import PromiseKit
@testable import BabylonApiService
@testable import BabylonDemoApp

class PostsDetailPresenterTests: XCTestCase {
    
    var presenter: PostDetailPresenter!
    var mockDelegate: MockPostsDetailDelegate!
    var mockInteractor: MockPostDetailInteractor!
    
    override func setUp()
    {
        mockInteractor = MockPostDetailInteractor()
        mockDelegate = MockPostsDetailDelegate()
        presenter = PostDetailPresenter(interactor: mockInteractor)
        presenter.delegate = mockDelegate
    }

    override func tearDown()
    {
        mockInteractor = nil
        mockDelegate = nil
        presenter = nil
    }
    
    func testLoadDetails_HappyPath_LoadCorrectViewModel()
    {
        let selection = PostDetailsSelection(userId: 1, postId: 2, postText: "Hello world")
        let didLoadDetails = expectation(description: "Did load details")
        mockInteractor.loadDetailsBlock = {
            didLoadDetails.fulfill()
            return Promise { seal in
                let company = Company(name: "x", catchPhrase: "y", bs: "z")
                let geo = GeoLocation(lat: "e", lng: "f")
                let address = Address(street: "a", suite: "b", city: "c", zipcode: "d", geo: geo)
                let user = User(id: 1, name: "Saman", username: "B", email: "abc@gmail.com", address: address, phone: "1234", website: "www.abc.com", company: company)
                let comment = Comment(postId: 2, id: 1, name: "", email: "abc", body: "Hello world")
                let postDetails = ([user], [comment])
                seal.fulfill(postDetails)
            }
        }
        let didStartLoading = expectation(description: "Did start loading")
        mockDelegate.postDetailPresenterDidStartLoadingBlock = {
            didStartLoading.fulfill()
        }
        let didFinishLoading = expectation(description: "Did finish loading")
        mockDelegate.postDetailPresenterDidFinishLoadingBlock = { viewModel in
            didFinishLoading.fulfill()
            let expectedViewModel = PostDetailsViewModel(authorTitle: "B", description: "Hello world", numberOfCommentsText: "1 comment")
            XCTAssertEqual(expectedViewModel, viewModel)
        }
        presenter.loadDetails(for: selection)
        wait(for: [didStartLoading, didLoadDetails, didFinishLoading], timeout: 2, enforceOrder: true)
    }
    
    func testLoadDetails_InteractorFailedWithError()
    {
        let selection = PostDetailsSelection(userId: 1, postId: 2, postText: "Hello world")
        let didLoadDetails = expectation(description: "Did load details")
        mockInteractor.loadDetailsBlock = {
            didLoadDetails.fulfill()
            return Promise { seal in
                seal.reject(NSError(domain: "Saman", code: 2))
            }
        }
        let didStartLoading = expectation(description: "Did start loading")
        mockDelegate.postDetailPresenterDidStartLoadingBlock = {
            didStartLoading.fulfill()
        }
        let didFinishLoading = expectation(description: "Did finish loading")
        didFinishLoading.isInverted = true
        mockDelegate.postDetailPresenterDidFinishLoadingBlock = { viewModel in
            didFinishLoading.fulfill()
        }
        let didRecieveError = expectation(description: "Did recieve error")
        mockDelegate.postDetailPresenterDidFailToLoadWithErrorBlock = { _ in
            didRecieveError.fulfill()
        }
        presenter.loadDetails(for: selection)
        wait(for: [didStartLoading, didLoadDetails, didFinishLoading, didRecieveError], timeout: 2, enforceOrder: true)
    }
}
