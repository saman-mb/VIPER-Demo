//
//  PostsNavigationController.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 27/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit

protocol PostsNavigatable
{
    func push(to detailsViewController: PostDetailViewController)
}

class PostsNavigationController: UINavigationController, PostsNavigatable
{
    func push(to detailsViewController: PostDetailViewController)
    {
        pushViewController(detailsViewController, animated: true)
    }
}
