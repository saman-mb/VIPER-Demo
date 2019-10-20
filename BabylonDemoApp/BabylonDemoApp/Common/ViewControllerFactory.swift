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
    static func makePostsViewController(api: BabylonApi) -> PostsViewController
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postsViewController = storyboard.instantiateViewController(identifier: "\(type(of: PostsViewController.self))", creator: { coder in
            return PostsViewController(coder: coder, babylonApi: api)
        })
        return postsViewController
    }
    
    static func makePostsNavigationViewController(api: BabylonApi) -> PostsNavigationViewController
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postsViewController = storyboard.instantiateViewController(identifier: "\(type(of: PostsViewController.self))", creator: { coder in
            return PostsNavigationViewController(coder: coder, babylonApi: api)
        })
        return postsViewController
    }
}
