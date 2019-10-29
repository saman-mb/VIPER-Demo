//
//  PostsRouter.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 28/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import BabylonApiService

protocol PostsRoutable
{
    func pushPostDetails(for selectedPost: Post)
    func popToPostsList()
}

struct PostDetailsSelection
{
    let userId: Int
    let postId: Int
    let postText: String
}

class PostsRouter: PostsRoutable
{
    let navigator: PostsNavigatable
    
    init(navigator: PostsNavigatable)
    {
        self.navigator = navigator
    }
    
    func pushPostDetails(for selectedPost: Post)
    {
        let selection = PostDetailsSelection(userId: selectedPost.userId, postId: selectedPost.id, postText: selectedPost.body)
        navigator.push(to: PostDetailViewController.makeFromStoryBoard(router: self, selection: selection))
    }
    
    func popToPostsList()
    {
        navigator.popToList()
    }
}
