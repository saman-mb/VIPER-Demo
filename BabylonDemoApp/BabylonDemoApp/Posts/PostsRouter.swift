//
//  PostsRouter.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 28/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import Foundation
import UIKit
import BabylonApiService

protocol PostsRoutable
{
    func pushPostDetails(for selectedPost: Post)
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
        navigator.push(to: type(of: self).makePostDetailViewController(selection: selection))
    }
}

extension PostsRouter
{
    static func makePostDetailViewController(selection: PostDetailsSelection) -> PostDetailViewController
    {
        let storyboard = UIStoryboard(name: "ViewControllers", bundle: nil)
        let postsViewController = storyboard.instantiateViewController(identifier: "PostDetailViewController", creator: { coder in
            return PostDetailViewController(coder: coder, presenter: PostDetailPresenter(api: BabylonServiceFactory.makeApi(), fileInteractor: DocumentsFacade()), selection: selection)
        })
        return postsViewController
    }
    
    static func makePostsViewController(router: PostsRoutable) -> PostsViewController
    {
        let storyboard = UIStoryboard(name: "ViewControllers", bundle: nil)
        let postsViewController = storyboard.instantiateViewController(identifier: "PostsViewController", creator: { coder in
            return PostsViewController(coder: coder, postsPresenter: PostsPresenter(api: BabylonServiceFactory.makeApi(), router: router, fileInteractor: DocumentsFacade()))
        })
        return postsViewController
    }
}
