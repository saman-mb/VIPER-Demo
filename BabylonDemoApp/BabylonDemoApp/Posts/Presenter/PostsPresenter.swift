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
}

enum PostsPresenterError: Error
{
    case unableToLoadPosts(Error)
}

protocol PostsPresentatbleOutput
{
    var viewModelsRelay: BehaviorRelay<[PostViewModel]> { get }
    var loadingSubject: PublishSubject<Bool> { get }
}

protocol PostsPresentatbleInput
{
    var indexPathSubject: PublishSubject<IndexPath>  { get }
}

protocol PostsPresentable
{
    var inputs: PostsPresentatbleInput { get }
    var outputs: PostsPresentatbleOutput { get }
    var delegate: PostsPresentableDelegate? { get set }
    
    func refresh()
}

final class PostsPresenter: PostsPresentable
{
    private typealias RefreshResult = (viewModels: [PostViewModel], posts: [Post])
    
    var inputs: PostsPresentatbleInput
    var outputs: PostsPresentatbleOutput = PostsPresenterOutput()
    
    private let interactor: PostsInteractable
    fileprivate let router: PostsRoutable
    fileprivate let disposeBag = DisposeBag()
    
    private var posts: [Post] = []
    
    weak var delegate: PostsPresentableDelegate?
    
    init(router: PostsRoutable, interactor: PostsInteractable)
    {
        self.router = router
        self.interactor = interactor
        let input = PostsPresenterInput()
        self.inputs = input
        input.presenter = self
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
            self.outputs.viewModelsRelay.accept(viewModels)
            self.delegate?.postsPresenterDidUpdatePosts()
        }
        .catch { error in
            self.outputs.loadingSubject.onError(PostsPresenterError.unableToLoadPosts(error))
        }
    }

    fileprivate func presentDetailsForPost(at indePath: IndexPath)
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

fileprivate final class PostsPresenterOutput: PostsPresentatbleOutput
{
    var viewModelsRelay: BehaviorRelay<[PostViewModel]> = BehaviorRelay(value: [])
    var loadingSubject = PublishSubject<Bool>()
}

fileprivate final class PostsPresenterInput: PostsPresentatbleInput
{
    var indexPathSubject = PublishSubject<IndexPath>()
    var presenter: PostsPresenter!
    {
        didSet {
            setupDetailSelectionBiding()
        }
    }
    
    func setupDetailSelectionBiding()
    {
        indexPathSubject.asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .bind(onNext: presenter.presentDetailsForPost)
            .disposed(by: presenter.disposeBag)
    }
}
