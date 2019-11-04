//
//  PostsPresenterTests.swift
//  BabylonDemoAppTests
//
//  Created by Saman Badakhshan on 30/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import XCTest
import PromiseKit
@testable import BabylonApiService
@testable import BabylonDemoApp

class PostsPresenterTests: XCTestCase {

    var mockInteractor: MockPostsIntercator!
    var mockRouter: MockRouter!
    var mockDelegate: MockPostsPresenterDelegate!
    var presenter: PostsPresenter!
    
    override func setUp()
    {
        mockInteractor = MockPostsIntercator()
        mockRouter = MockRouter()
        mockDelegate = MockPostsPresenterDelegate()
        presenter = PostsPresenter(router: mockRouter, interactor: mockInteractor)
        presenter.delegate = mockDelegate
    }

    override func tearDown()
    {
        mockInteractor = nil
        mockRouter = nil
        presenter = nil
        mockDelegate = nil
    }
    
    func testRefresh_HappypPath_ResolvesCorrectViewModel()
    {
        let didStartLoading = expectation(description: "Did start loading")
        mockDelegate.postsPresenterDidStartLoadingBlock = {
            didStartLoading.fulfill()
        }
        let didNotFishWithError = expectation(description: "Did not finsh with error")
         didNotFishWithError.isInverted = true
         mockDelegate.postsPresenterDidRecieveErrorBlock = { _ in
             didNotFishWithError.fulfill()
         }
        let didFinshLoading = expectation(description: "Did finish loading")
        mockDelegate.postsPresenterDidUpdatePostsBlock = {
            didFinshLoading.fulfill()
        }
        mockInteractor.updatePostsBlock = {
            return Promise { seal in
                seal.fulfill([Post(id: 1, userId: 2, title: "Hello", body: "World")])
            }
        }
        let didRecieveViewModels = expectation(description: "Did recieve view models")
        presenter.output.viewModelsSubject
            .subscribe(onNext: { viewModels in
                XCTAssertEqual(viewModels, [PostViewModel(title: "Hello", subTitle: "World")])
                didRecieveViewModels.fulfill()
            }, onError: { error in
                XCTFail()
            }).dispose()
        presenter.refresh()
        wait(for: [didStartLoading, didNotFishWithError, didFinshLoading, didRecieveViewModels], timeout: 1, enforceOrder: true)
        
    }
    
    func testRefresh_InteractorFailsWithError_ViewModelsEmpty()
    {
        let didStartLoading = expectation(description: "Did start loading")
        mockDelegate.postsPresenterDidStartLoadingBlock = {
            didStartLoading.fulfill()
        }
        let didNotFinshLoading = expectation(description: "Did not finish loading")
        didNotFinshLoading.isInverted = true
        mockDelegate.postsPresenterDidUpdatePostsBlock = {
            didNotFinshLoading.fulfill()
        }
        let didFinshWithError = expectation(description: "Did finish with error")
        mockDelegate.postsPresenterDidRecieveErrorBlock = { error in
            didFinshWithError.fulfill()
        }
        let didUpdatePosts = expectation(description: "Did update posts")
        mockInteractor.updatePostsBlock = {
            didUpdatePosts.fulfill()
            return Promise { seal in
                seal.reject(PostsPresenterError.unableToLoadPosts(NSError(domain: "Saman", code: 100)))
            }
        }
        presenter.output.viewModelsSubject
            .subscribe(onNext: { viewModels in
                print(viewModels)
            }, onError: { error in
                print(error)
            }).dispose()
        presenter.refresh()
        wait(for: [didStartLoading, didUpdatePosts, didNotFinshLoading, didFinshWithError], timeout: 1, enforceOrder: true)
    }
    
    func testDidSelectPost_CallsPushDetailsOnRouter()
    {
        let selectedPost = Post(id: 1, userId: 2, title: "Hello", body: "World")
        let didFinshLoading = expectation(description: "Did finish loading")
        mockDelegate.postsPresenterDidUpdatePostsBlock = {
            didFinshLoading.fulfill()
        }
        mockInteractor.updatePostsBlock = {
            return Promise { seal in
                seal.fulfill([selectedPost])
            }
        }
        presenter.refresh()
        waitForExpectations(timeout: 1)
        
        let didPushDetails = expectation(description: "Did push details")
        mockRouter.pushPostDetailsBlock = { post in
            XCTAssertEqual(selectedPost, post)
            didPushDetails.fulfill()
        }
        self.presenter.input.indexPathSubject.onNext([0,0])
        waitForExpectations(timeout: 1)
    }
}
