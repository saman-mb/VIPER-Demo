//
//  PostsInteractor.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 30/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import BabylonApiService
import PromiseKit

enum PostsInteratorError: Error
{
    case failedToLoad([Error])
}

protocol PostsInteractable
{
    func updatePosts() -> Promise<[Post]>
}

class PostsInteractor: PostsInteractable
{
    static let postsFileName = "Posts.json"
    
    private let api: BabylonApi
    private var fileWriter: FileWritable
    private var fileReader: FileReadable
    private(set) var posts: [Post] = []
    
    init(api: BabylonApi, fileInteractor: FileInteractor)
    {
        self.api = api
        self.fileWriter = fileInteractor
        self.fileReader = fileInteractor
    }
    
    func updatePosts() -> Promise<[Post]>
    {
        return Promise { seal in
            
            firstly {
                loadPosts()
            }
            .then(on: DispatchQueue.userIntiatedGlobal) { posts in
                posts.writeToFile(named: type(of: self).postsFileName, fileWriter: self.fileWriter)
            }
            .done { posts in
                seal.fulfill(posts)
            }
            .catch { error in
                seal.reject(error)
            }
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
           .catch { networkError in
               firstly {
                   self.loadPostsFromDisk()
               }
               .done { posts in
                   seal.fulfill(posts)
               }
               .catch { diskError in
                   seal.reject(PostsInteratorError.failedToLoad([networkError, diskError]))
               }
           }
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
               seal.reject(error)
           }
       }
   }
}
