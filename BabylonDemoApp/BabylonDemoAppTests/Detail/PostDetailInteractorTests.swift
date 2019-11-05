//
//  PostDetailInteractorTests.swift
//  BabylonDemoAppTests
//
//  Created by Saman Badakhshan on 05/11/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import XCTest
import PromiseKit
@testable import BabylonApiService
@testable import BabylonDemoApp

class PostDetailInteractorTests: XCTestCase {

    fileprivate enum JsonFile: String
    {
        case users = "Users.json", comments = "Comments.json"
    }
    
    fileprivate enum ApiFailType
    {
        case users, comments
    }
    var mockFileInteractor: MockFileInteractor!
    var mockApi: MockBabylonApi!
    var interactor: PostDetailInteractor!
    var users: [User]!
    var comments: [Comment]!
    var expectedUsersData: Data?
    var expectedCommentsData: Data?
    
    override func setUp()
    {
        users = [User(id: 1, name: "Leanne Graham", username: "Bret", email: "Sincere@april.biz", address: Address(street: "Kulas Light", suite: "Apt. 556", city: "Gwenborough", zipcode: "92998-3874", geo: GeoLocation(lat: "-37.3159", lng: "81.1496")), phone: "1-770-736-8031 x56442", website: "hildegard.org", company: Company(name: "Romaguera-Crona", catchPhrase: "Multi-layered client-server neural-net", bs: "harness real-time e-markets"))]
        comments = [Comment(postId: 1, id: 1, name: "id labore ex et quam laborum", email: "Eliseo@gardner.biz", body: "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium")]
        expectedUsersData = try! JSONEncoder().encode(users)
        expectedCommentsData = try! JSONEncoder().encode(comments)
        mockFileInteractor = MockFileInteractor()
        mockApi = MockBabylonApi()
        interactor = PostDetailInteractor(api: mockApi, fileInteractor: mockFileInteractor)
    }

    override func tearDown()
    {
        expectedUsersData = nil
        expectedCommentsData = nil
        users = nil
        comments = nil
        mockFileInteractor = nil
        mockApi = nil
        interactor = nil
    }

    func testLoadDetails_HappyPath_FinishesSuccessfully()
    {
        let finished = expectation(description: "Success")
        let didRequestUsers = expectation(description: "Did request users")
        let didRequestComments = expectation(description: "Did request comments")
        let didWriteUsers = expectation(description: "Did write users")
        let didWriteComments = expectation(description: "Did write comments")
        
        stubApiSuccess(didRequestUsers, didRequestComments)
        stubWritSuccess(didWriteUsers, didWriteComments)
        
        firstly {
            interactor.loadDetails()
        }
        .done { details in
            XCTAssertEqual(details.users, self.users)
            XCTAssertEqual(details.comments, self.comments)
            finished.fulfill()
        }
        .catch { error in
            XCTFail("\(error)")
        }
        wait(for: [didRequestUsers, didRequestComments, didWriteUsers, didWriteComments, finished], timeout: 1)
    }
    
    func testLoadDetais_UsrsRequestFails_JsonLoadedFromDisk_FinishesSuccessfully()
    {
        let finished = expectation(description: "Success")
        let didRequestUsers = expectation(description: "Did request users")
        let didRequestComments = expectation(description: "Did request comments")
        let didWriteUsers = expectation(description: "Did write users")
        let didWriteComments = expectation(description: "Did write comments")
        let didCallRead = expectation(description: "Did call read")
        
        stubApiFailed(didRequestUsers, didRequestComments, failType: .users)
        stubWritSuccess(didWriteUsers, didWriteComments)
        stubReadSuccess(didCallRead, file: .users)
        
        firstly {
            interactor.loadDetails()
        }
        .done { details in
            XCTAssertEqual(details.users, self.users)
            XCTAssertEqual(details.comments, self.comments)
            finished.fulfill()
        }
        .catch { error in
            XCTFail("\(error)")
        }
        wait(for: [didRequestUsers, didRequestComments, didCallRead, didWriteUsers, didWriteComments, finished], timeout: 1)
    }
    
    func testLoadDetais_CommentsRequestFails_JsonLoadedFromDisk_FinishesSuccessfully()
    {
        let finished = expectation(description: "Success")
        let didRequestUsers = expectation(description: "Did request users")
        let didRequestComments = expectation(description: "Did request comments")
        let didCallRead = expectation(description: "Did call read")
        let didWriteUsers = expectation(description: "Did write users")
        let didWriteComments = expectation(description: "Did write comments")
        
        stubApiFailed(didRequestUsers, didRequestComments, failType: .comments)
        stubWritSuccess(didWriteUsers, didWriteComments)
        stubReadSuccess(didCallRead, file: .comments)
        
        firstly {
            interactor.loadDetails()
        }
        .done { details in
            XCTAssertEqual(details.users, self.users)
            XCTAssertEqual(details.comments, self.comments)
            finished.fulfill()
        }
        .catch { error in
            XCTFail("\(error)")
        }
        wait(for: [didRequestUsers, didRequestComments, didCallRead, didWriteUsers, didWriteComments, finished], timeout: 1)
    }
    
    //MARK: Helpers
    fileprivate func stubApiSuccess(_ didRequestUsers: XCTestExpectation, _ didRequestComments: XCTestExpectation)
    {
        mockApi.usersBlock = { completion in
            didRequestUsers.fulfill()
            completion(.success(self.users))
        }
        
        mockApi.commentsBlock = { completion in
            didRequestComments.fulfill()
            completion(.success(self.comments))
        }
    }
    
    fileprivate func stubApiFailed(_ didRequestUsers: XCTestExpectation, _ didRequestComments: XCTestExpectation, failType: ApiFailType)
    {
        mockApi.usersBlock = { completion in
            didRequestUsers.fulfill()
            if case .users = failType {
                completion(.error(BabylonApiError.invalidUrl))
            } else {
                completion(.success(self.users))
            }
        }
        
        mockApi.commentsBlock = { completion in
            didRequestComments.fulfill()
            if case .comments = failType {
                completion(.error(BabylonApiError.invalidUrl))
            } else {
                completion(.success(self.comments))
            }
        }
    }
    
    fileprivate func stubReadSuccess(_ didCallRead: XCTestExpectation, file: JsonFile)
    {
        mockFileInteractor.loadDataBlock = { fileName in
            XCTAssertEqual(fileName, file.rawValue)
            didCallRead.fulfill()
            switch file
            {
            case .users:
                return self.expectedUsersData!
            case .comments:
                return self.expectedCommentsData!
            }
        }
    }
    
    fileprivate func stubReadFailed(_ didCallRead: XCTestExpectation, file: JsonFile)
    {
        mockFileInteractor.loadDataBlock = { fileName in
            XCTAssertEqual(fileName, file.rawValue)
            didCallRead.fulfill()
            throw DocumentsManagerError.unableToFindFileNamed(fileName)
        }
    }
    
    fileprivate func stubWritSuccess(_ didCallWriteUsers: XCTestExpectation, _ didCallWriteComments: XCTestExpectation)
    {
        mockFileInteractor.writeBlock = { data, fileName in
            if fileName == JsonFile.users.rawValue {
                XCTAssertEqual( data, self.expectedUsersData)
                didCallWriteUsers.fulfill()
            } else {
                XCTAssertEqual(data, self.expectedCommentsData)
                didCallWriteComments.fulfill()
            }
        }
    }
    
    fileprivate func stubWritFailed(_ didCallWriteUsers: XCTestExpectation, _ didCallWriteComments: XCTestExpectation)
    {
        mockFileInteractor.writeBlock = { data, fileName in
            if fileName == JsonFile.users.rawValue {
                XCTAssertEqual( data, self.expectedUsersData)
                didCallWriteUsers.fulfill()
            } else {
                XCTAssertEqual(data, self.expectedCommentsData)
                didCallWriteComments.fulfill()
            }
            throw DocumentsManagerError.missingDocumentsDirectoy
        }
    }
}
