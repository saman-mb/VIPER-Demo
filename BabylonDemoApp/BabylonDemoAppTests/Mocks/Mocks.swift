//
//  Mocks.swift
//  BabylonDemoAppTests
//
//  Created by Saman Badakhshan on 30/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
@testable import PromiseKit
@testable import BabylonApiService
@testable import BabylonDemoApp

class MockBabylonApi: BabylonApi
{
    var postsBlock: ((@escaping GenericCompletion<[Post]>)-> Void)?
    var usersBlock: ((@escaping GenericCompletion<[User]>)-> Void)?
    var commentsBlock: ((@escaping GenericCompletion<[Comment]>)-> Void)?
    
    func posts(_ completion: @escaping GenericCompletion<[Post]>)
    {
        postsBlock?(completion)
    }
    
    func users(_ completion: @escaping GenericCompletion<[User]>)
    {
        usersBlock?(completion)
    }
    
    func comments(_ completion: @escaping GenericCompletion<[Comment]>)
    {
        commentsBlock?(completion)
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

class MockRouter: PostsRoutable
{
    var pushPostDetailsBlock: ((Post)->Void)?
    
    func pushPostDetails(for selectedPost: Post)
    {
        pushPostDetailsBlock?(selectedPost)
    }
}

class MockPostsIntercator: PostsInteractable
{
    var updatePostsBlock: (()->Promise<[Post]>)?
    
    func updatePosts() -> Promise<[Post]>
    {
        guard let block = updatePostsBlock else
        {
            return Promise { seal in
                seal.fulfill([])
            }
        }
        return block()
    }
}

class MockPostsDetailDelegate: PostDetailPresentableDelegate
{
    var postDetailPresenterDidStartLoadingBlock: (()->Void)?
    var postDetailPresenterDidFinishLoadingBlock: ((PostDetailsViewModel)->Void)?
    var postDetailPresenterDidFailToLoadWithErrorBlock: ((Error)->Void)?
    
    func postDetailPresenterDidStartLoading()
    {
        postDetailPresenterDidStartLoadingBlock?()
    }
    
    func postDetailPresenterDidFinishLoading(viewModel: PostDetailsViewModel)
    {
        postDetailPresenterDidFinishLoadingBlock?(viewModel)
    }
    
    func postDetailPresenterDidFailToLoadWithError(_ error: Error)
    {
        postDetailPresenterDidFailToLoadWithErrorBlock?(error)
    }
}

class MockPostDetailInteractor: PostDetailInteractable
{
    var loadDetailsBlock: (()->Promise<PostDetails>)?

    func loadDetails() -> Promise<PostDetails>
    {
        guard let block = loadDetailsBlock else {
            return Promise { seal in }
        }
        return block()
    }
}
