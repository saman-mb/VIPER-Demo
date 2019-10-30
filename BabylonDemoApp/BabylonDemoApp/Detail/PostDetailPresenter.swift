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
    case failedToLoadDetails(Error)
    case unableToExtractUserDetails
    case failedToLoadUsersFromDisk([Error])
    case failedToLoadCommentsFromDisk([Error])
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
    let fileWriter: FileWritable
    let fileReader: FileReadable
    
    private let users: [User] = []
    private let comments: [Comment] = []
    
    init(api: BabylonApi, fileInteractor: FileInteractor)
    {
        self.api = api
        self.fileWriter = fileInteractor
        self.fileReader = fileInteractor
    }
    
    func loadDetails(for selection: PostDetailsSelection)
    {
        firstly {
            when(fulfilled: api.users(), api.comments())
        }
        .ensure {
            self.delegate?.postDetailPresenterDidStartLoading()
        }
        .then(on: DispatchQueue.userIntiatedGlobal) { users, comments in
            when(fulfilled:
                users.writeToFile(named: type(of: self).usersFileName, fileWriter: self.fileWriter),
                comments.writeToFile(named: type(of: self).commentsFileName, fileWriter: self.fileWriter))
        }
        .then(on: DispatchQueue.userIntiatedGlobal) { users, comments in
            self.mapViewModels(from: users, comments: comments, selection: selection)
        }
        .done { viewModel in
            self.delegate?.postDetailPresenterDidFinishLoading(viewModel: viewModel)
        }
        .catch { error in
            self.delegate?.postDetailPresenterDidFailToLoadWithError(PostDetailPresenterError.failedToLoadDetails(error))
        }
    }
    
    //MARK: - Helpers
    
    private func loadUsers() -> Promise<[User]>
    {
        return Promise { seal in
            firstly {
                api.users()
            }
            .done { users in
                seal.fulfill(users)
            }
            .catch { networkError in
                firstly {
                    [User].loadFromFile(named: type(of: self).usersFileName, fileReader: self.fileReader)
                }
                .done { users in
                    seal.fulfill(users)
                }
                .catch { diskError in
                    seal.reject(PostDetailPresenterError.failedToLoadUsersFromDisk([networkError, diskError]))
                }
            }
        }
    }
    
    private func loadComments() -> Promise<[Comment]>
    {
        return Promise { seal in
            firstly {
                api.comments()
            }
            .done { comments in
                seal.fulfill(comments)
            }
            .catch { networkError in
                firstly {
                    [Comment].loadFromFile(named: type(of: self).commentsFileName, fileReader: self.fileReader)
                }
                .done { comments in
                    seal.fulfill(comments)
                }
                .catch { diskError in
                    seal.reject(PostDetailPresenterError.failedToLoadCommentsFromDisk([networkError, diskError]))
                }
            }
        }
    }
    
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
}
