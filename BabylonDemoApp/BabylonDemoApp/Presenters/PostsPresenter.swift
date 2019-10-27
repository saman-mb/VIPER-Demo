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
import RxSwift
import RxCocoa

protocol PostsPresenterDelegate: class
{
    func postsPresenterDidStartLoading()
    func postsPresenterDidUpdatePosts(with viewModels: [PostViewModel])
    func postsPresenterDidRecieveError(_ error: PostsPresenterError)
}

enum PostsPresenterError: Error
{
    case unableToLoadPosts(Error)
    case failedToPersistPosts(Error)
    case invalidJson
}

final class PostsPresenter
{
    static let postsFileName = "Posts.json"
    private let api: BabylonApi
    weak var delegate: PostsPresenterDelegate?
    private(set) var viewModels: BehaviorRelay<[PostViewModel]> = BehaviorRelay(value: [])
    
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
            self.persistPostsJson(posts)
        }
        .then(on: DispatchQueue.global()) { posts in
            self.mapPostsToViewModels(from: posts)
        }
        .done { viewModels in
            self.viewModels.accept(viewModels)
            self.delegate?.postsPresenterDidUpdatePosts(with: viewModels)
        }
        .catch { error in
            self.delegate?.postsPresenterDidRecieveError(.unableToLoadPosts(error))
        }
    }
    
    private func mapPostsToViewModels(from posts: [Post]) -> Promise<[PostViewModel]>
    {
        return Promise { seal in
            let viewModels = posts.map { PostViewModel(title: $0.title, subTitle: $0.body) }
            seal.fulfill(viewModels)
        }
    }
    
    private func persistPostsJson(_ posts: [Post]) -> Promise<[Post]>
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
