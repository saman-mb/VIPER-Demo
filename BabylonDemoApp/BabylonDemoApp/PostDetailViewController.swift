//
//  PostDetailViewController.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit
import BabylonApiService

class PostDetailViewController: UIViewController {

    let presenter: PostDetailPresenter
    
    static func makeFromStoryBoard(withApi api: BabylonApi) -> PostDetailViewController
    {
        let storyboard = UIStoryboard(name: "ViewControllers", bundle: nil)
        let postsViewController = storyboard.instantiateViewController(identifier: "PostDetailViewController", creator: { coder in
            return PostDetailViewController(coder: coder, presenter: PostDetailPresenter(api: api))
        })
        return postsViewController
    }
    
    required init?(coder: NSCoder, presenter: PostDetailPresenter)
    {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder)
    {
        fatalError("You must create this view controller with a \(PostDetailPresenter.self)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Post Detail"
    }
}
