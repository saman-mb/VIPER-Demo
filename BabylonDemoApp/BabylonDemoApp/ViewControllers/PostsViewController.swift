//
//  ViewController.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 17/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit

class PostsViewController: UITableViewController {
    
    private let postsPresenter: PostsPresenter
    
    init?(coder: NSCoder, postsPresenter: PostsPresenter)
    {
        self.postsPresenter = postsPresenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder)
    {
        fatalError("You must create this view controller with a \(PostsPresenter.self)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Posts"
    }
    
    //MARK:- UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: "PostCell")
        }
        cell.textLabel?.text = "Hello"
        cell.detailTextLabel?.text = "World"
        return cell
    }
}

