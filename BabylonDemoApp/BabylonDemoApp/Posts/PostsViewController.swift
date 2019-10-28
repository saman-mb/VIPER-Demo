//
//  ViewController.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 17/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit
import BabylonApiService
import RxSwift
import RxCocoa

class PostsViewController: UIViewController {
    
    private var presenter: PostsPresentable
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var retryButton: UIButton!
    private var disposeBag = DisposeBag()
    
    static func makeFromStoryBoard(router: PostsRoutable) -> PostsViewController
    {
        let storyboard = UIStoryboard(name: "ViewControllers", bundle: nil)
        let postsViewController = storyboard.instantiateViewController(identifier: "PostsViewController", creator: { coder in
            return PostsViewController(coder: coder, postsPresenter: PostsPresenter(api: BabylonServiceFactory.makeApi(), router: router))
        })
        return postsViewController
    }
    
    init?(coder: NSCoder, postsPresenter: PostsPresenter)
    {
        self.presenter = postsPresenter
        super.init(coder: coder)
        self.presenter.delegate = self
    }

    required init?(coder: NSCoder)
    {
        fatalError("You must create this view controller with a \(PostsPresenter.self)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Posts"
        setupTableViewBindings()
        presenter.refresh()
    }
    
    private func setupTableViewBindings()
    {
        presenter.viewModels
            .bind(to: tableView.rx.items(cellIdentifier: "PostCell", cellType: PostTableViewCell.self)) { (row, viewModel, cell) in
                cell.viewModel.accept(viewModel)
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    fileprivate func showMessage(_ shouldShow: Bool)
    {
        messageLabel.isHidden = !shouldShow
        retryButton.isHidden = !shouldShow
    }
}

extension PostsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        presenter.presentDetailsForPost(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 120
    }
}

extension PostsViewController: PostsPresentableDelegate
{
    func postsPresenterDidStartLoading()
    {
        showMessage(false)
        activityIndicator.startAnimating()
    }
    
    func postsPresenterDidUpdatePosts(with viewModels: [PostViewModel])
    {
        showMessage(false)
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func postsPresenterDidRecieveError(_ error: PostsPresenterError)
    {
        activityIndicator.stopAnimating()
        showMessage(true)
    }
}

