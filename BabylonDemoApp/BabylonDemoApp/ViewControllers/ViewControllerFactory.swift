//
//  ViewControllerFactory.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit
import BabylonApiService

final class ViewControllerFactory
{
    private static let storyboard = UIStoryboard(name: "ViewControllers", bundle: nil)
    
    static func makeDetailViewController(api: BabylonApi) -> PostDetailViewController
    {
        let postsViewController = storyboard.instantiateViewController(identifier: "PostDetailViewController", creator: { coder in
            return PostDetailViewController(coder: coder, presenter: PostDetailPresenter(api: api))
        })
        return postsViewController
    }
    
    static func makePostsViewController(api: BabylonApi) -> PostsViewController
    {
        let postsViewController = storyboard.instantiateViewController(identifier: "PostsViewController", creator: { coder in
            return PostsViewController(coder: coder, postsPresenter: PostsPresenter(api: api))
        })
        return postsViewController
    }
}
