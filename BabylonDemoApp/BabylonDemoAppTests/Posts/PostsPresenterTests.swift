//
//  PostsPresenterTests.swift
//  BabylonDemoAppTests
//
//  Created by Saman Badakhshan on 30/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import XCTest
import PromiseKit
import RxSwift
@testable import BabylonApiService
@testable import BabylonDemoApp

class PostsPresenterTests: XCTestCase {

    var mockInteractor: MockPostsIntercator!
    var mockRouter: MockRouter!
    var presenter: PostsPresenter!
    
    override func setUp()
    {
        mockInteractor = MockPostsIntercator()
        mockRouter = MockRouter()
        presenter = PostsPresenter(router: mockRouter, interactor: mockInteractor)
    }

    override func tearDown()
    {
        mockInteractor = nil
        mockRouter = nil
        presenter = nil
    }
    
    func testRefresh_HappypPath_ResolvesCorrectViewModel()
    {
        let disposeBag = DisposeBag()
        let didStartLoading = expectation(description: "Did start loading")
        let didFinshLoading = expectation(description: "Did finish loading")
        let didNotFishWithError = expectation(description: "Did not finsh with error")
        didNotFishWithError.isInverted = true
        
        presenter.outputs.loadingSubject
            .filter { $0 == true }
            .subscribe(onNext: { _ in
                didStartLoading.fulfill()
            })
            .disposed(by: disposeBag)
        
        presenter.outputs.errorSubject
                .subscribe(onNext: { _ in
                   didNotFishWithError.fulfill()
                })
                .disposed(by: disposeBag)
        
        presenter.outputs.viewModelsRelay
            .filter { $0.count > 0 }
            .subscribe(onNext: { viewModels in
                didFinshLoading.fulfill()
            })
            .disposed(by: disposeBag)
        
        mockInteractor.updatePostsBlock = {
            return Promise { seal in
                seal.fulfill([Post(id: 1, userId: 2, title: "Hello", body: "World")])
            }
        }
        presenter.inputs.refreshSubject.onNext(())
        wait(for: [didStartLoading, didNotFishWithError, didFinshLoading], timeout: 1, enforceOrder: true)
        
    }
    
    func testRefresh_InteractorFailsWithError_ViewModelsEmpty()
    {
        let disposeBag = DisposeBag()
        let didUpdatePosts = expectation(description: "Did update posts")
        let didStartLoading = expectation(description: "Did start loading")
        let didFinishWithError = expectation(description: "Did finish with error")
        let didNotFinshLoading = expectation(description: "Did not finish loading")
        didNotFinshLoading.isInverted = true
        
        presenter.outputs.loadingSubject
            .filter { $0 == true }
            .subscribe(onNext: { _ in
                didStartLoading.fulfill()
            })
            .disposed(by: disposeBag)
        
        presenter.outputs.errorSubject
             .subscribe(onNext: { _ in
                didFinishWithError.fulfill()
             })
             .disposed(by: disposeBag)
        
        presenter.outputs.viewModelsRelay
            .filter { $0.count > 0 }
            .subscribe(onNext: { viewModels in
                didNotFinshLoading.fulfill()
            })
            .disposed(by: disposeBag)
        
        mockInteractor.updatePostsBlock = {
            didUpdatePosts.fulfill()
            return Promise { seal in
                seal.reject(PostsPresenterError.unableToLoadPosts(NSError(domain: "Saman", code: 100)))
            }
        }
        presenter.inputs.refreshSubject.onNext(())
        wait(for: [didStartLoading, didUpdatePosts, didNotFinshLoading, didFinishWithError], timeout: 1, enforceOrder: true)
    }
    
    func testDidSelectPost_CallsPushDetailsOnRouter()
    {
        let disposeBag = DisposeBag()
        let selectedPost = Post(id: 1, userId: 2, title: "Hello", body: "World")
        let didFinshLoading = expectation(description: "Did finish loading")
        presenter.outputs.viewModelsRelay
            .filter { $0.count > 0 }
            .subscribe(onNext: { viewModels in
                didFinshLoading.fulfill()
            })
            .disposed(by: disposeBag)
        
        mockInteractor.updatePostsBlock = {
            return Promise { seal in
                seal.fulfill([selectedPost])
            }
        }
        presenter.inputs.refreshSubject.onNext(())
        waitForExpectations(timeout: 1)
        
        let didPushDetails = expectation(description: "Did push details")
        mockRouter.pushPostDetailsBlock = { post in
            XCTAssertEqual(selectedPost, post)
            didPushDetails.fulfill()
        }
        self.presenter.inputs.indexPathSubject.onNext([0,0])
        waitForExpectations(timeout: 1)
    }
}
