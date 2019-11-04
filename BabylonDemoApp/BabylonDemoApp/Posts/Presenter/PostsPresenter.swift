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

enum PostsPresenterError: Error
{
    case unableToLoadPosts(Error)
}

protocol PostsPresentatbleOutput
{
    var viewModelsRelay: BehaviorRelay<[PostViewModel]> { get }
    var loadingSubject: BehaviorSubject<Bool> { get }
}

protocol PostsPresentatbleInput
{
    var indexPathSubject: PublishSubject<IndexPath>  { get }
    var refreshSubject: PublishSubject<Void> { get }
}

protocol PostsPresentable
{
    var inputs: PostsPresentatbleInput { get }
    var outputs: PostsPresentatbleOutput { get }
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
    
    init(router: PostsRoutable, interactor: PostsInteractable)
    {
        self.router = router
        self.interactor = interactor
        let input = PostsPresenterInput()
        self.inputs = input
        input.presenter = self
    }
    
    fileprivate func refreshPosts()
    {
        self.outputs.loadingSubject.onNext(true)
        firstly {
            interactor.updatePosts()
        }
        .then(on: DispatchQueue.main) { posts in
            self.update(with: posts)
        }
        .then(on: DispatchQueue.userIntiatedGlobal) { posts in
            self.mapViewModels(from: posts)
        }
        .done { viewModels in
            self.outputs.loadingSubject.onNext(false)
            self.outputs.viewModelsRelay.accept(viewModels)
        }
        .catch { error in
            self.outputs.loadingSubject.onNext(false)
            self.outputs.loadingSubject.onError(PostsPresenterError.unableToLoadPosts(error))
        }
    }

    fileprivate func presentDetailsForPost(at indePath: IndexPath)
    {
        let post = posts[indePath.row]
        router.pushPostDetails(for: post)
    }
    
    private func update(with posts: [Post]) -> Promise<[Post]>
    {
        return Promise { seal in
            self.posts = posts
            seal.fulfill(posts)
        }
    }
    
    private func mapViewModels(from posts: [Post]) -> Promise<[PostViewModel]>
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
    var loadingSubject = BehaviorSubject<Bool>(value: false)
}

fileprivate final class PostsPresenterInput: PostsPresentatbleInput
{
    var refreshSubject = PublishSubject<Void>()
    var indexPathSubject = PublishSubject<IndexPath>()
    
    var presenter: PostsPresenter!
    {
        didSet {
            setupRefreshBinding()
            setupDetailSelectionBiding()
        }
    }
    
    func setupRefreshBinding()
    {
        refreshSubject.asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .bind(onNext: presenter.refreshPosts)
            .disposed(by: presenter.disposeBag)
    }
    
    func setupDetailSelectionBiding()
    {
        indexPathSubject.asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .bind(onNext: presenter.presentDetailsForPost)
            .disposed(by: presenter.disposeBag)
    }
}
