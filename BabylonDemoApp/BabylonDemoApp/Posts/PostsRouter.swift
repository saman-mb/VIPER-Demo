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

class PostsRouter: PostsRoutable
{
    let navigator: PostsNavigatable
    
    init(navigator: PostsNavigatable)
    {
        self.navigator = navigator
    }
    
    func pushPostDetails(for selectedPost: Post)
    {
        navigator.push(to: PostDetailViewController.makeFromStoryBoard(router: self))
    }
    
    func popToPostsList()
    {
        navigator.popToList()
    }
}
