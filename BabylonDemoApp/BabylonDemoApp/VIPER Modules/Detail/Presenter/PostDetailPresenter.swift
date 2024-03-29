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

struct PostDetailsViewModel: Equatable
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
    weak var delegate: PostDetailPresentableDelegate?
    private let interactor: PostDetailInteractable
    
    init(interactor: PostDetailInteractable)
    {
        self.interactor = interactor
    }
    
    func loadDetails(for selection: PostDetailsSelection)
    {
        self.delegate?.postDetailPresenterDidStartLoading()
        firstly {
            interactor.loadDetails()
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
