//
//  PostDetailViewController.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 20/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {

    let presenter: PostDetailPresenter
    
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
