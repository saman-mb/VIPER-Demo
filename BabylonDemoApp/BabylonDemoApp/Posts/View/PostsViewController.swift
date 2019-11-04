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
    private let refreshControl = UIRefreshControl()
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
        refreshControl.addTarget(self, action: #selector(refreshControlDidAcivate(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        addChild(loadingViewController)
        view.addSubview(loadingViewController.view)
        setupTableViewBindings()
        presenter.refresh()
    }
    
    @objc private func refreshControlDidAcivate(_ sender: Any)
    {
        presenter.refresh()
    }
    
    private func setupTableViewBindings()
    {
        presenter.outputs.viewModelsRelay
            .bind(to: tableView.rx.items(cellIdentifier: "PostCell", cellType: PostTableViewCell.self)) { (row, viewModel, cell) in
                cell.viewModel.accept(viewModel)
            }
            .disposed(by: disposeBag)
        
        presenter.outputs.loadingSubject
            .subscribe(onError: { error in
                self.loadingViewController.view.isHidden = false
                self.loadingViewController.showSpinner(false)
                self.loadingViewController.showMessage(true)
                self.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                self.presenter.inputs.indexPathSubject.onNext(indexPath)
            })
            .disposed(by: disposeBag)
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
        refreshControl.endRefreshing()
    }
    
    func postsPresenterDidUpdatePosts()
    {
        loadingViewController.view.isHidden = true
        loadingViewController.showMessage(false)
        loadingViewController.showSpinner(false)
        refreshControl.endRefreshing()
    }
}

