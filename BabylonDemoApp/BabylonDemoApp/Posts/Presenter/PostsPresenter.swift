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

protocol PostsPresentatbleInput
{
    var didSelectPost: PublishSubject<IndexPath>  { get }
}

protocol PostsPresentatbleOutput
{
    var viewModel: Observable<PostViewModel> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<NSError> { get }
}

protocol PostsPresentable
{
    var input: PostsPresentatbleInput { get }
    var delegate: PostsPresentableDelegate? { get set }
    var viewModels: BehaviorRelay<[PostViewModel]> { get }
    func refresh()
}

enum PostsPresenterError: Error
{
    case unableToLoadPosts(Error)
}

final class PostsPresenter: PostsPresentable, PostsPresentatbleInput
{
    private typealias RefreshResult = (viewModels: [PostViewModel], posts: [Post])
    
    var input: PostsPresentatbleInput { return self }
    let didSelectPost = PublishSubject<IndexPath>()
    weak var delegate: PostsPresentableDelegate?
    
    private let router: PostsRoutable
    private let interactor: PostsInteractable
    private let disposeBag = DisposeBag()

    private var posts: [Post] = []
    private(set) var viewModels: BehaviorRelay<[PostViewModel]> = BehaviorRelay(value: [])
    
    init(router: PostsRoutable, interactor: PostsInteractable)
    {
        self.router = router
        self.interactor = interactor
        bindToView()
    }
    
    func refresh()
    {
        self.delegate?.postsPresenterDidStartLoading()
        firstly {
            interactor.updatePosts()
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
    
    private func bindToView()
    {
        didSelectPost.asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .bind(onNext: presentDetailsForPost)
            .disposed(by: disposeBag)
    }

    private func presentDetailsForPost(at indePath: IndexPath)
    {
        let post = posts[indePath.row]
        router.pushPostDetails(for: post)
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
