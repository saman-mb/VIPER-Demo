//
//  PostDetailPresenter.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 21/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import PromiseKit
import BabylonApiService

protocol PostDetailPresentableDelegate: class
{
    func postDetailPresenterDidStartLoading()
    func postDetailPresenterDidFinishLoading(viewModel: PostDetailsViewModel)
    func postDetailPresenterDidFailToLoadWithError(_ error: Error)
}

enum PostDetailPresenterError: Error
{
    case failedToLoadUserDetails(Error)
    case unableToExtractUserDetails
    case failedToPersistComments(Error)
    case failedToPersistUsers(Error)
}

struct PostDetailsViewModel
{
    let authorTitle: String
    let description: String
    let numberOfCommentsText: String
}

protocol PostDetailPresentable {
    var delegate: PostDetailPresentableDelegate? { get set }
    func loadUser(for selectedId: String, in post: Post)
}

final class PostDetailPresenter
{
    static let commentsFileName = "Comments.json"
    static let usersFileName = "Users.json"
    
    weak var delegate: PostDetailPresentableDelegate?
    let api: BabylonApi
    let router: PostsRoutable
    let fileWriter: FileWritable
    
    private let users: [User] = []
    private let comments: [Comment] = []
    
    init(api: BabylonApi, router: PostsRoutable, fileWriter: FileWritable)
    {
        self.api = api
        self.router = router
        self.fileWriter = fileWriter
    }
    
    func loadDetails(for selection: PostDetailsSelection)
    {
        firstly {
            when(fulfilled: api.users(), api.comments())
        }
        .then(on: DispatchQueue.userIntiatedGlobal) { users, comments in
            when(fulfilled: self.persistUsers(users), self.persistComments(comments))
        }
        .then(on: DispatchQueue.userIntiatedGlobal) { users, comments in
            self.mapViewModels(from: users, comments: comments, selection: selection)
        }
        .ensure {
            self.delegate?.postDetailPresenterDidStartLoading()
        }
        .done { viewModel in
            self.delegate?.postDetailPresenterDidFinishLoading(viewModel: viewModel)
        }
        .catch { error in
            self.delegate?.postDetailPresenterDidFailToLoadWithError(PostDetailPresenterError.failedToLoadUserDetails(error))
        }
    }
    
    //MARK: - Helpers
    
    private func mapViewModels(from users: [User], comments: [Comment], selection: PostDetailsSelection) -> Promise<PostDetailsViewModel>
    {
        return Promise { seal in
            guard let selectedUser = users.first(where: { $0.id == selection.userId }) else {
                seal.reject(PostDetailPresenterError.unableToExtractUserDetails)
                return
            }
            let viewModel = PostDetailsViewModel(authorTitle: selectedUser.username,
                                                description: selection.postText,
                                                numberOfCommentsText: commentsText(from: comments, selection: selection))
            seal.fulfill(viewModel)
        }
    }
    
    private func commentsText(from comments: [Comment], selection: PostDetailsSelection) -> String
    {
        let comments = comments.filter { $0.postId == selection.postId }
        if comments.count > 1 || comments.count == 0 {
            return "\(comments.count) comments"
        } else {
            return "1 comment"
        }
    }
    
    private func persistUsers(_ users: [User]) -> Promise<[User]>
    {
        return Promise { seal in
            do {
                try users.writeToFileToDocuments(named: type(of: self).usersFileName, fileWriter: fileWriter)
                seal.fulfill(users)
            }
            catch {
                seal.reject(PostDetailPresenterError.failedToPersistUsers(error))
            }
        }
    }
     
    private func persistComments(_ comments: [Comment]) -> Promise<[Comment]>
    {
        return Promise { seal in
            do {
                try comments.writeToFileToDocuments(named: type(of: self).commentsFileName, fileWriter: fileWriter)
                seal.fulfill(comments)
            }
            catch {
                seal.reject(PostDetailPresenterError.failedToPersistComments(error))
            }
        }
    }
}
