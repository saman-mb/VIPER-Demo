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
        self.loadingViewController.delegate = self
    }

    required init?(coder: NSCoder)
    {
        fatalError("You must create this view controller with a \(PostsPresenter.self)")
    }
    
    fileprivate func setupViews() {
        title = "Posts"
        overrideUserInterfaceStyle = .light
        refreshControl.addTarget(self, action: #selector(refreshControlDidAcivate(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        addChild(loadingViewController)
        view.addSubview(loadingViewController.view)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupPresenterBindings()
    }
    
    @objc private func refreshControlDidAcivate(_ sender: Any)
    {
        refreshPosts()
    }
    
    private func setupPresenterBindings()
    {
        presenter.outputs.viewModelsRelay
            .bind(to: tableView.rx.items(cellIdentifier: "PostCell", cellType: PostTableViewCell.self)) { (row, viewModel, cell) in
                cell.viewModel.accept(viewModel)
            }
            .disposed(by: disposeBag)
        
        presenter.outputs.viewModelsRelay
            .subscribe(onNext: { viewModels in
                self.handleLoadingFinishedSuccessfully()
            })
            .disposed(by: disposeBag)
        
        presenter.outputs.loadingSubject
            .filter { $0 == true }
            .subscribe(onNext: { isLoading in
                self.handleLoadingStarted()
            })
            .disposed(by: disposeBag)
        
        presenter.outputs.errorSubject
            .subscribe(onNext: { error in
                // adding a delay to ease spinner to error message transition
                DispatchQueue.main.asyncAfter(seconds: 1) {
                    self.handleLoadingError()
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                self.presenter.inputs.indexPathSubject.onNext(indexPath)
            })
            .disposed(by: disposeBag)
        
        presenter.inputs.refreshSubject.onNext(())
    }
    
    fileprivate func handleLoadingFinishedSuccessfully()
    {
        loadingViewController.view.isHidden = true
        loadingViewController.showMessage(false)
        loadingViewController.showSpinner(false)
        refreshControl.endRefreshing()
    }
    
    fileprivate func handleLoadingError()
    {
        loadingViewController.view.isHidden = false
        loadingViewController.showSpinner(false)
        loadingViewController.showMessage(true)
        refreshControl.endRefreshing()
    }
    
    fileprivate func handleLoadingStarted()
    {
        loadingViewController.view.isHidden = false
        loadingViewController.showMessage(false)
        loadingViewController.showSpinner(true)
        refreshControl.endRefreshing()
    }
    
    fileprivate func refreshPosts()
    {
        presenter.inputs.refreshSubject.onNext(())
    }
}

extension PostsViewController: LoadingViewControllerDelegagte
{
    func loadingViewControllerDidTapRetryButton()
    {
        refreshPosts()
    }
}

