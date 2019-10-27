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
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let messageLabel: UILabel = UILabel()
    
    init?(coder: NSCoder, postsPresenter: PostsPresenter)
    {
        self.postsPresenter = postsPresenter
        super.init(coder: coder)
        self.postsPresenter.delegate = self
    }

    required init?(coder: NSCoder)
    {
        fatalError("You must create this view controller with a \(PostsPresenter.self)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Posts"
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        postsPresenter.refreshPosts()
    }
    
    //MARK:- UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return postsPresenter.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: "PostCell")
        }
        let post = postsPresenter.posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.body
        return cell
    }
}

extension PostsViewController: PostsPresenterDelegate
{
    func postsPresenterDidStartLoading()
    {
        activityIndicator.startAnimating()
    }
    
    func postsPresenterDidUpdatePosts()
    {
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func postsPresenterDidRecieveError(_ error: PostsPresenterError)
    {
        activityIndicator.stopAnimating()
        
    }
}

