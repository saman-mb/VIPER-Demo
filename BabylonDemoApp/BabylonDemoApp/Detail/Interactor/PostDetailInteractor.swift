//
//  PostDetailInteractor.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 30/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import BabylonApiService
import PromiseKit

typealias PostDetails = (users: [User], comments: [Comment])

protocol PostDetailInteractable
{
    func loadDetails() -> Promise<PostDetails>
}

enum PostDetailInteractorError: Error
{
    case failedToLoadDetails(Error)
    case failedToLoadUsersFromDisk([Error])
    case failedToLoadCommentsFromDisk([Error])
}

class PostDetailInteractor: PostDetailInteractable
{
    static let commentsFileName = "Comments.json"
    static let usersFileName = "Users.json"
    
    private let api: BabylonApi
    private let fileWriter: FileWritable
    private let fileReader: FileReadable
    
    private(set) var users: [User] = []
    private(set) var comments: [Comment] = []
    
    init(api: BabylonApi, fileInteractor: FileInteractor)
    {
        self.api = api
        self.fileWriter = fileInteractor
        self.fileReader = fileInteractor
    }
    
    func loadDetails() -> Promise<PostDetails>
    {
        return Promise { seal in
            firstly {
                when(fulfilled: loadUsers(), loadComments())
            }
            .then(on: DispatchQueue.main) { users, comments in
                when(fulfilled: self.updateUsers(users), self.updateComments(comments))
            }
            .then(on: DispatchQueue.userIntiatedGlobal) { users, comments in
                when(fulfilled:
                    users.writeToFile(named: type(of: self).usersFileName, fileWriter: self.fileWriter),
                    comments.writeToFile(named: type(of: self).commentsFileName, fileWriter: self.fileWriter))
            }
            .done { users, comments in
                seal.fulfill((users, comments))
            }
            .catch { error in
                seal.reject(PostDetailInteractorError.failedToLoadDetails(error))
            }
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
                       seal.reject(PostDetailInteractorError.failedToLoadUsersFromDisk([networkError, diskError]))
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
                       seal.reject(PostDetailInteractorError.failedToLoadCommentsFromDisk([networkError, diskError]))
                   }
               }
           }
       }
    
    private func updateUsers(_ users:[User]) -> Promise<[User]>
    {
        return Promise { seal in
            self.users = users
            seal.fulfill(users)
        }
    }
    
    private func updateComments(_ comments:[Comment]) -> Promise<[Comment]>
    {
        return Promise { seal in
            self.comments = comments
            seal.fulfill(comments)
        }
    }
}
