//
//  Mocks.swift
//  BabylonDemoAppTests
//
//  Created by Saman Badakhshan on 30/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
@testable import BabylonApiService
@testable import BabylonDemoApp

class MockBabylonApi: BabylonApi
{
    var postsBlock: ((@escaping GenericCompletion<[Post]>)-> Void)?
    var users: ((@escaping GenericCompletion<[User]>)-> Void)?
    var comments: ((@escaping GenericCompletion<[Comment]>)-> Void)?
    
    func posts(_ completion: @escaping GenericCompletion<[Post]>)
    {
        postsBlock?(completion)
    }
    
    func users(_ completion: @escaping GenericCompletion<[User]>)
    {
        users?(completion)
    }
    
    func comments(_ completion: @escaping GenericCompletion<[Comment]>)
    {
        comments?(completion)
    }
}

class MockFileInteractor: FileInteractor
{
    var loadDataBlock: ((String) throws -> Data)?
    var writeBlock: ((Data, String) throws -> Void)?
    
    func loadData(fromFileName: String) throws -> Data
    {
        return try loadDataBlock?(fromFileName) ?? Data()
    }
    
    func write(data: Data, toFileNamed fileName: String) throws
    {
        try writeBlock?(data, fileName)
    }
}

class MockPostsNavigator: PostsNavigatable
{
    var pushBlock: ((PostDetailViewController) -> Void)?
    
    func push(to detailsViewController: PostDetailViewController)
    {
        pushBlock?(detailsViewController)
    }
}
