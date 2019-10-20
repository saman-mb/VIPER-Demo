//
//  ViewController.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 17/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit
import BabylonApiService

class PostsViewController: UIViewController
{
    private let babylonApi: BabylonApi
    private let postsPresenter: PostsPresenter
    
    init?(coder: NSCoder, babylonApi: BabylonApi)
    {
        self.babylonApi = babylonApi
        self.postsPresenter = PostsPresenter(api: babylonApi)
        super.init(coder: coder)
    }

    required init?(coder: NSCoder)
    {
        fatalError("You must create this view controller with a \(BabylonApi.self)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}

