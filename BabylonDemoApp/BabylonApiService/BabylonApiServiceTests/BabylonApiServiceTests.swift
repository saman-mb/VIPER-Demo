//
//  BabylonApiServiceTests.swift
//  BabylonApiServiceTests
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import XCTest
@testable import BabylonApiService

class BabylonApiServiceTests: XCTestCase {

    var mockConfig: MockConfiguration!
    var mockUrlSession: MockUrlSession!
    var sut: BabylonApiImplementation!
    
    override func setUp()
    {
        mockConfig = MockConfiguration()
        mockUrlSession = MockUrlSession()
        sut = BabylonApiImplementation(configration: mockConfig, urlSession: mockUrlSession)
    }
    
    override func tearDown()
    {
        sut = nil
        mockConfig = nil
        mockUrlSession = nil
    }
    
    func testPosts_Response200_ValidJsonData_RequestCorrectUrlAndParses()
    {
        let postsRequestFinnished = expectation(description: "Posts did finnish")
        let json = "[\r\n{\r\n\"userId\": 1,\r\n\"id\": 1,\r\n\"title\": \"sunt aut facere repellat provident occaecati excepturi optio reprehenderit\",\r\n\"body\": \"quia et suscipit\\nsuscipit recusandae consequuntur expedita et cum\\nreprehenderit molestiae ut ut quas totam\\nnostrum rerum est autem sunt rem eveniet architecto\"\r\n}\r\n]"
        stubUrlSession(endpoint: mockConfig.postsEndpoont, jsonString: json, error: nil) { request in
            XCTAssertEqual(request.url?.absoluteString, "https://saman.com/posts")
        }
        sut.posts { (result) in
            switch result
            {
            case .success(let posts):
                XCTAssertEqual(posts, [Post(id: 1, userId: 1, title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")])
            case .error(let error):
                XCTFail("Expected posts but recieved error: \(error)")
            }
            postsRequestFinnished.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testComments_Response200_ValidJsonData_RequestCorrectUrlAndParses()
    {
        let commentsRequestDidFinish = expectation(description: "Comments request did finnish")
        let json = "[\r\n{\r\n\"postId\": 1,\r\n\"id\": 1,\r\n\"name\": \"id labore ex et quam laborum\",\r\n\"email\": \"Eliseo@gardner.biz\",\r\n\"body\": \"laudantium enim quasi est quidem magnam voluptate ipsam eos\\ntempora quo necessitatibus\\ndolor quam autem quasi\\nreiciendis et nam sapiente accusantium\"\r\n}\r\n]"
        stubUrlSession(endpoint: mockConfig.commentsEndpoint, jsonString: json, error: nil) { request in
            XCTAssertEqual(request.url?.absoluteString, "https://saman.com/abcd/comments")
        }
        sut.comments { (result) in
            switch result
            {
            case .success(let comments):
                XCTAssertEqual(comments, [Comment(postId: 1, id: 1, name: "id labore ex et quam laborum", email: "Eliseo@gardner.biz", body: "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium")])
            case .error(let error):
                XCTFail("Expected comments but recieved error: \(error)")
            }
            commentsRequestDidFinish.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUsers_Response200_ValidJsonData_RequestCorrectUrlAndParses()
    {
        let usersRequestDidFinish = expectation(description: "Users request did finnish")
        let json = "[\r\n{\r\n\"id\": 1,\r\n\"name\": \"Leanne Graham\",\r\n\"username\": \"Bret\",\r\n\"email\": \"Sincere@april.biz\",\r\n\"address\": {\r\n\"street\": \"Kulas Light\",\r\n\"suite\": \"Apt. 556\",\r\n\"city\": \"Gwenborough\",\r\n\"zipcode\": \"92998-3874\",\r\n\"geo\": {\r\n\"lat\": \"-37.3159\",\r\n\"lng\": \"81.1496\"\r\n}\r\n},\r\n\"phone\": \"1-770-736-8031 x56442\",\r\n\"website\": \"hildegard.org\",\r\n\"company\": {\r\n\"name\": \"Romaguera-Crona\",\r\n\"catchPhrase\": \"Multi-layered client-server neural-net\",\r\n\"bs\": \"harness real-time e-markets\"\r\n}\r\n}\r\n]"
        stubUrlSession(endpoint: mockConfig.usersEndpoint, jsonString: json, error: nil) { request in
            XCTAssertEqual(request.url?.absoluteString, "https://saman.com/abcd/users")
        }
        sut.users { result in
            switch result
            {
            case .success(let users):
                XCTAssertEqual(users, [User(id: 1, name: "Leanne Graham", username: "Bret", email: "Sincere@april.biz", address: Address(street: "Kulas Light", suite: "Apt. 556", city: "Gwenborough", zipcode: "92998-3874", geo: GeoLocation(lat: "-37.3159", lng: "81.1496")), phone: "1-770-736-8031 x56442", website: "hildegard.org", company: Company(name: "Romaguera-Crona", catchPhrase: "Multi-layered client-server neural-net", bs: "harness real-time e-markets"))])
            case .error(let error):
                XCTFail("Expected users but recieved error: \(error)")
            }
            usersRequestDidFinish.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    private func stubUrlSession(endpoint: String, jsonString: String, error: Error?, assertBlock: @escaping (URLRequest)-> Void)
    {
        let jsonData = jsonString.data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        mockUrlSession.dataTaskClosure = { request, completion in
            assertBlock(request)
            completion(jsonData, response, error)
            return MockDataTask()
        }
    }

}
