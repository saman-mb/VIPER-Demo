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

protocol PostsPresentableDelegate: class
{
    func postsPresenterDidStartLoading()
    func postsPresenterDidUpdatePosts(with viewModels: [PostViewModel])
    func postsPresenterDidRecieveError(_ error: PostsPresenterError)
}

protocol PostsPresentable
{
    var delegate: PostsPresentableDelegate? { get set }
    var viewModels: BehaviorRelay<[PostViewModel]> { get }
    func presentDetailsForPost(at index: Int)
    func refresh()
}

enum PostsPresenterError: Error
{
    case unableToLoadPosts(Error)
    case failedToPersistPosts(Error)
    case invalidJson
}

final class PostsPresenter: PostsPresentable
{
    private typealias RefreshResult = (viewModels: [PostViewModel], posts: [Post])
    
    static let postsFileName = "Posts.json"
    private let api: BabylonApi
    private let router: PostsRoutable
    private var posts: [Post] = []
    weak var delegate: PostsPresentableDelegate?
    private(set) var viewModels: BehaviorRelay<[PostViewModel]> = BehaviorRelay(value: [])
    
    init(api: BabylonApi, router: PostsRoutable)
    {
        self.api = api
        self.router = router
    }
    
    func presentDetailsForPost(at index: Int)
    {
        let post = posts[index]
        router.pushPostDetails(for: post)
    }
    
    func refresh()
    {
        firstly {
            api.posts()
        }
        .then(on: DispatchQueue.userIntiatedGlobal) { posts in
            self.persistPostsJson(posts)
        }
        .then(on: DispatchQueue.userIntiatedGlobal) { posts in
            self.mapPostsToViewModels(from: posts)
        }
        .ensure {
            self.delegate?.postsPresenterDidStartLoading()
        }
        .done { result in
            self.posts = result.posts
            self.viewModels.accept(result.viewModels)
            self.delegate?.postsPresenterDidUpdatePosts(with: result.viewModels)
        }
        .catch { error in
            self.delegate?.postsPresenterDidRecieveError(.unableToLoadPosts(error))
        }
    }
    
    private func mapPostsToViewModels(from posts: [Post]) -> Promise<RefreshResult>
    {
        return Promise { seal in
            let viewModels = posts.map { PostViewModel(title: $0.title, subTitle: $0.body) }
            seal.fulfill((viewModels, posts))
        }
    }
    
    private func persistPostsJson(_ posts: [Post]) -> Promise<[Post]>
    {
        return Promise { seal in
            do {
                try posts.writeToFileToDocuments(named: type(of: self).postsFileName)
                seal.fulfill(posts)
            }
            catch {
                seal.reject(PostsPresenterError.failedToPersistPosts(error))
            }
        }
    }
}
