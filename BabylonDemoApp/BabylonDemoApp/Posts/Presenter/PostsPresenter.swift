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
    func postsPresenterDidUpdatePosts()
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
}

final class PostsPresenter: PostsPresentable
{
    private typealias RefreshResult = (viewModels: [PostViewModel], posts: [Post])
    
    private let router: PostsRoutable
    private var posts: [Post] = []
    
    private let interactor: PostsInteractable
    
    weak var delegate: PostsPresentableDelegate?
    
    private(set) var viewModels: BehaviorRelay<[PostViewModel]> = BehaviorRelay(value: [])
    
    init(router: PostsRoutable, interactor: PostsInteractable)
    {
        self.router = router
        self.interactor = interactor
    }
    
    func presentDetailsForPost(at index: Int)
    {
        let post = posts[index]
        router.pushPostDetails(for: post)
    }
    
    func refresh()
    {
        firstly {
            interactor.updatePosts()
        }
        .ensure {
            self.delegate?.postsPresenterDidStartLoading()
        }
        .then(on: DispatchQueue.main) { posts in
            self.updatePosts(posts)
        }
        .then(on: DispatchQueue.userIntiatedGlobal) { posts in
            self.mapPostsToViewModels(from: posts)
        }
        .done { viewModels in
            self.viewModels.accept(viewModels)
            self.delegate?.postsPresenterDidUpdatePosts()
        }
        .catch { error in
            self.delegate?.postsPresenterDidRecieveError(PostsPresenterError.unableToLoadPosts(error))
        }
    }
    
    private func updatePosts(_ posts: [Post]) -> Promise<[Post]>
    {
        return Promise { seal in
            self.posts = posts
            seal.fulfill(posts)
        }
    }
    
    private func mapPostsToViewModels(from posts: [Post]) -> Promise<[PostViewModel]>
    {
        return Promise { seal in
            let viewModels = posts.map { PostViewModel(title: $0.title, subTitle: $0.body) }
            seal.fulfill((viewModels))
        }
    }
}
