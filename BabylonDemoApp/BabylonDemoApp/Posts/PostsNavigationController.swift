//
//  PostsNavigationController.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 27/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit
import BabylonApiService

protocol PostsNavigatable
{
    func push(to detailsViewController: PostDetailViewController)
    func popToList()
}

class PostsNavigationController: UINavigationController, PostsNavigatable
{
    func push(to detailsViewController: PostDetailViewController)
    {
        pushViewController(detailsViewController, animated: true)
    }
    
    func popToList()
    {
        popViewController(animated: true)
    }
}
