//
//  PostsInteractorTests.swift
//  BabylonDemoAppTests
//
//  Created by Saman Badakhshan on 17/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import XCTest
import PromiseKit
@testable import BabylonApiService
@testable import BabylonDemoApp

class PostsInteractorTests: XCTestCase {

    var interactor: PostsInteractor!
    var mockFileInteractor: MockFileInteractor!
    var mockBabylonApi: MockBabylonApi!
    var posts: [Post]!
    var expectedPostData: Data?
    
    override func setUp()
    {
        posts = [Post(id: 1, userId: 2, title: "Saman", body: "Hello world"),
                 Post(id: 2, userId: 2, title: "Saman", body: "Hello universe")]
        expectedPostData = try! JSONEncoder().encode(posts)
        mockBabylonApi = MockBabylonApi()
        mockFileInteractor = MockFileInteractor()
        interactor = PostsInteractor(api: mockBabylonApi, fileInteractor: mockFileInteractor)
    }

    override func tearDown()
    {
        posts = nil
        expectedPostData = nil
        interactor = nil
        mockBabylonApi = nil
        mockFileInteractor = nil
    }
    
    // MARK: - updatePosts
    
    func testUpdatePosts_ApiCallSuccess_DiskLoadNotCalled_FileWriteSuccess_UpdatesPostsSuccessfully()
    {
        let didCallApi = expectation(description: "Did call posts API")
        let didUpdate = expectation(description: "Did update")
        let didCallWrite = expectation(description: "Did call write")
        let didNotCallLoadFromDisk = expectation(description: "Did not call load from disk")
        
        didNotCallLoadFromDisk.isInverted = true
        stubWritSuccess(didCallWrite)
        stubApiSuccess(didCallApi)
        stubDiskLoadSuccess(didNotCallLoadFromDisk)
        
        firstly {
            interactor.updatePosts()
        }
        .done { posts in
            didUpdate.fulfill()
        }.catch { error in
            XCTFail("Promise expected to succeed")
        }
        wait(for: [didCallApi, didNotCallLoadFromDisk, didCallWrite, didUpdate], timeout: 1, enforceOrder: true)
    }
    
    func testUpdatePosts_ApiCallSuccess_DiskLoadNotCalled_FileWriteFailed_UpdatesPostsSuccessfully()
    {
        let didCallApi = expectation(description: "Did call posts API")
        let didFail = expectation(description: "Did fail")
        let didCallWrite = expectation(description: "Did call write")
        let didNotCallLoadFromDisk = expectation(description: "Did not call load from disk")
        
        didNotCallLoadFromDisk.isInverted = true
        stubWritFailed(didCallWrite)
        stubApiSuccess(didCallApi)
        stubDiskLoadSuccess(didNotCallLoadFromDisk)
        
        firstly {
            interactor.updatePosts()
        }
        .done { posts in
            XCTFail("Promise expected to fail")
        }.catch { error in
            didFail.fulfill()
        }
        wait(for: [didCallApi, didNotCallLoadFromDisk, didCallWrite, didFail], timeout: 1, enforceOrder: true)
    }
    
    func testUpdatePosts_ApiCallFailed_DiskLoadFailed_WriteIsNotCalled_UpdatesPostsSuccessfully()
    {
        let didCallApi = expectation(description: "Did call posts API")
        let didNotCallWrite = expectation(description: "Did not call write")
        let didFail = expectation(description: "Did fail")
        let didCallLoadFromDisk = expectation(description: "Did call load from disk")

        didNotCallWrite.isInverted = true
        stubApiFailed(didCallApi)
        stubDiskLoadFailed(didCallLoadFromDisk)
        stubWritFailed(didNotCallWrite)

        firstly {
          interactor.updatePosts()
        }
        .done { posts in
            XCTFail("Promise expected to fail")
        }.catch { error in
            didFail.fulfill()
        }
        wait(for: [didCallApi, didCallLoadFromDisk, didNotCallWrite, didFail], timeout: 1, enforceOrder: true)
    }
    
    func testUpdatePosts_ApiCallFailed_DiskLoadSuccess_WriteSuccess_UpdatesPostsSuccessfully()
    {
        let didCallApi = expectation(description: "Did call posts API")
        let didCallLoadFromDisk = expectation(description: "Did call load from disk")
        let didCallWrite = expectation(description: "Did call write")
        let didSucceed = expectation(description: "Did succeed")

        stubApiFailed(didCallApi)
        stubDiskLoadSuccess(didCallLoadFromDisk)
        stubWritSuccess(didCallWrite)

        firstly {
            interactor.updatePosts()
        }
        .done { posts in
            didSucceed.fulfill()
        }.catch { error in
            XCTFail("Promise expected to succeed")
        }
        wait(for: [didCallApi, didCallLoadFromDisk, didCallWrite, didSucceed], timeout: 1, enforceOrder: true)
    }
    
    //MARK: - Helpers
    
    fileprivate func stubApiSuccess(_ didCallApi: XCTestExpectation)
    {
        mockBabylonApi.postsBlock = { completion in
            didCallApi.fulfill()
            completion(.success(self.posts))
        }
    }
    
    fileprivate func stubApiFailed(_ didCallApi: XCTestExpectation)
    {
        mockBabylonApi.postsBlock = { completion in
            didCallApi.fulfill()
            completion(.error(BabylonApiError.invalidUrl))
        }
    }
    
    fileprivate func stubDiskLoadSuccess(_ didCallRead: XCTestExpectation)
    {
        mockFileInteractor.loadDataBlock = { fileName in
            XCTAssertEqual(fileName, "Posts.json")
            didCallRead.fulfill()
            return self.expectedPostData!
        }
    }
    
    fileprivate func stubDiskLoadFailed(_ didCallRead: XCTestExpectation)
    {
        mockFileInteractor.loadDataBlock = { fileName in
            XCTAssertEqual(fileName, "Posts.json")
            didCallRead.fulfill()
            throw DocumentsManagerError.unableToFindFileNamed(fileName)
        }
    }
    
    fileprivate func stubWritSuccess(_ didCallWrite: XCTestExpectation)
    {
        mockFileInteractor.writeBlock = { data, fileName in
            XCTAssertEqual(fileName, "Posts.json")
            XCTAssertEqual(data, self.expectedPostData)
            didCallWrite.fulfill()
        }
    }
    
    fileprivate func stubWritFailed(_ didCallWrite: XCTestExpectation)
    {
        mockFileInteractor.writeBlock = { data, fileName in
            XCTAssertEqual(fileName, "Posts.json")
            XCTAssertEqual(data, self.expectedPostData)
            didCallWrite.fulfill()
            throw DocumentsManagerError.missingDocumentsDirectoy
        }
    }
}
