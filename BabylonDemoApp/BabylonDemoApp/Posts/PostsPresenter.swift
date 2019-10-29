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
    private var fileWriter: FileWritable
    private var fileReader: FileReadable
    weak var delegate: PostsPresentableDelegate?
    private(set) var viewModels: BehaviorRelay<[PostViewModel]> = BehaviorRelay(value: [])
    
    init(api: BabylonApi, router: PostsRoutable, fileInteractor: FileInteractor)
    {
        self.api = api
        self.router = router
        self.fileWriter = fileInteractor
        self.fileReader = fileInteractor
    }
    
    func presentDetailsForPost(at index: Int)
    {
        let post = posts[index]
        router.pushPostDetails(for: post)
    }
    
    func refresh()
    {
        firstly {
            loadPosts()
        }
        .then(on: DispatchQueue.userIntiatedGlobal) { posts in
            when(fulfilled: self.writePostsToDisk(posts), self.mapPostsToViewModels(from: posts))
        }
        .ensure {
            self.delegate?.postsPresenterDidStartLoading()
        }
        .done { posts, viewModels in
            // I have put a fake delay here so its easier to see the spinner
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.posts = posts
                self.viewModels.accept(viewModels)
                self.delegate?.postsPresenterDidRecieveError(.invalidJson)
            }
        }
        .catch { error in
            self.delegate?.postsPresenterDidRecieveError(.unableToLoadPosts(error))
        }
    }

    private func loadPosts() -> Promise<[Post]>
    {
        return Promise { seal in
            firstly {
                api.posts()
            }
            .done { posts in
                seal.fulfill(posts)
            }
            .catch { error in
                // TODO: this network error is never surfaced
                firstly {
                    self.loadPostsFromDisk()
                }
                .done { posts in
                    seal.fulfill(posts)
                }
                .catch { error in
                    seal.reject(error)
                }
            }
        }
    }
    
    private func mapPostsToViewModels(from posts: [Post]) -> Promise<[PostViewModel]>
    {
        return Promise { seal in
            let viewModels = posts.map { PostViewModel(title: $0.title, subTitle: $0.body) }
            seal.fulfill((viewModels))
        }
    }
    
    private func loadPostsFromDisk() -> Promise<[Post]>
    {
        return Promise { seal in
            do {
                let data = try fileReader.loadData(fromFileName: type(of: self).postsFileName)
                let posts = try JSONDecoder().decode([Post].self, from: data)
                seal.fulfill(posts)
            }
            catch {
                seal.reject(PostsPresenterError.failedToPersistPosts(error))
            }
        }
    }
    
    private func writePostsToDisk(_ posts: [Post]) -> Promise<[Post]>
    {
        return Promise { seal in
            do {
                try posts.writeToFileToDocuments(named: type(of: self).postsFileName, fileWriter: fileWriter)
                seal.fulfill(posts)
            }
            catch {
                seal.reject(PostsPresenterError.failedToPersistPosts(error))
            }
        }
    }
}
