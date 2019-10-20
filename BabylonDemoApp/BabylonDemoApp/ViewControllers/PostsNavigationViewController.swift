//
//  PostsNavigationViewController.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit
import BabylonApiService

class PostsNavigationViewController: UINavigationController {
    
    private let babylonApi: BabylonApi
    private let postsViewController: PostsViewController
    
    init?(coder: NSCoder, babylonApi: BabylonApi)
    {
        self.babylonApi = babylonApi
        self.postsViewController = ViewControllerFactory.makePostsViewController(api: babylonApi)
        super.init(coder: coder)
    }

    required init?(coder: NSCoder)
    {
        fatalError("You must create this view controller with a \(BabylonApi.self)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        postsViewController.view.frame = view.bounds
        view.addSubview(postsViewController.view)
    }
}
