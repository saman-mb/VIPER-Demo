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
        self.loadingViewController.delegate = self
    }

    required init?(coder: NSCoder)
    {
        fatalError("You must create this view controller with a \(PostsPresenter.self)")
    }
    
    fileprivate func setupViews() {
        title = "Posts"
        overrideUserInterfaceStyle = .light
        addChild(loadingViewController)
        view.addSubview(loadingViewController.view)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupPresenterBindings()
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
            .distinctUntilChanged()
            .filter { $0 == true }
            .subscribe(onNext: { isLoading in
                self.handleLoadingStarted()
            })
            .disposed(by: disposeBag)
        
        presenter.outputs.errorSubject
            .delay(1.0, scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { error in
                self.handleLoadingError()
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
    }
    
    fileprivate func handleLoadingError()
    {
        loadingViewController.view.isHidden = false
        loadingViewController.showSpinner(false)
        loadingViewController.showMessage(true)
    }
    
    fileprivate func handleLoadingStarted()
    {
        loadingViewController.view.isHidden = false
        loadingViewController.showMessage(false)
        loadingViewController.showSpinner(true)
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

