//
//  PostsPresenter.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import PromiseKit
import BabylonApiService

protocol PostsPresenterDelegate: class {
    func postsPresenterDidStartLoading()
    func postsPresenterDidUpdatePosts()
    func postsPresenterDidRecieveError(_ error: PostsPresenterError)
}

enum PostsPresenterError: Error {
    case unableToLoadPosts(Error)
    case failedToPersistPosts(Error)
    case invalidJson
}

final class PostsPresenter
{
    static let postsFileName = "Posts.json"
    weak var delegate: PostsPresenterDelegate?
    let api: BabylonApi
    private(set) var posts: [Post] = []
    
    init(api: BabylonApi)
    {
        self.api = api
    }
    
    func refreshPosts()
    {
        delegate?.postsPresenterDidStartLoading()
        firstly {
            api.posts()
        }
        .then(on: DispatchQueue.global()) { posts in
            self.persistPostsToDisk(posts)
        }
        .done { posts in
            self.posts = posts
            self.delegate?.postsPresenterDidUpdatePosts()
        }
        .catch { error in
            self.delegate?.postsPresenterDidRecieveError(.unableToLoadPosts(error))
        }
    }
    
    private func persistPostsToDisk(_ posts: [Post]) -> Promise<[Post]>
    {
        return Promise { seal in
            do {
                try posts.writeToFileOnDisk(named: type(of: self).postsFileName)
                seal.fulfill(posts)
            }
            catch {
                seal.reject(PostsPresenterError.failedToPersistPosts(error))
            }
        }
    }
}
