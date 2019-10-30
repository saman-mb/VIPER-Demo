//
//  ViewController.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 17/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostsViewController: UIViewController {
    
    private var presenter: PostsPresentable
    @IBOutlet var tableView: UITableView!
    private var disposeBag = DisposeBag()
    private var loadingViewController: LoadingViewController
    
    init?(coder: NSCoder, postsPresenter: PostsPresenter)
    {
        self.presenter = postsPresenter
        self.loadingViewController = LoadingViewController.makeFromStoryBoard()
        super.init(coder: coder)
        self.presenter.delegate = self
        self.loadingViewController.delegate = self
    }

    required init?(coder: NSCoder)
    {
        fatalError("You must create this view controller with a \(PostsPresenter.self)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Posts"
        addChild(loadingViewController)
        view.addSubview(loadingViewController.view)
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

extension PostsViewController: LoadingViewControllerDelegagte
{
    func loadingViewControllerDidTapRetryButton()
    {
        presenter.refresh()
    }
}

extension PostsViewController: PostsPresentableDelegate
{
    func postsPresenterDidStartLoading()
    {
        loadingViewController.view.isHidden = false
        loadingViewController.showMessage(false)
        loadingViewController.showSpinner(true)
    }
    
    func postsPresenterDidUpdatePosts()
    {
        loadingViewController.view.isHidden = true
        loadingViewController.showMessage(false)
        loadingViewController.showSpinner(false)
    }
    
    func postsPresenterDidRecieveError(_ error: PostsPresenterError)
    {
        loadingViewController.view.isHidden = false
        loadingViewController.showSpinner(false)
        loadingViewController.showMessage(true)
    }
}
