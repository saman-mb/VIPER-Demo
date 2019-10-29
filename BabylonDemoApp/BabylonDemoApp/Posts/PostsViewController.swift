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
    @IBOutlet var tableView: UITableView!
    private var disposeBag = DisposeBag()
    private var loadingViewController: LoadingViewController
    
    static func makeFromStoryBoard(router: PostsRoutable) -> PostsViewController
    {
        let storyboard = UIStoryboard(name: "ViewControllers", bundle: nil)
        let postsViewController = storyboard.instantiateViewController(identifier: "PostsViewController", creator: { coder in
            return PostsViewController(coder: coder, postsPresenter: PostsPresenter(api: BabylonServiceFactory.makeApi(), router: router, fileInteractor: DocumentsFacade()))
        })
        return postsViewController
    }
    
    init?(coder: NSCoder, postsPresenter: PostsPresenter)
    {
        self.presenter = postsPresenter
        self.loadingViewController = LoadingViewController.makeFromStoryBoard()
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

extension PostsViewController: PostsPresentableDelegate
{
    func postsPresenterDidStartLoading()
    {
        loadingViewController.showMessage(false)
        loadingViewController.showSpinner(true)
    }
    
    func postsPresenterDidUpdatePosts(with viewModels: [PostViewModel])
    {
        loadingViewController.showMessage(false)
        loadingViewController.showSpinner(false)
        tableView.reloadData()
    }
    
    func postsPresenterDidRecieveError(_ error: PostsPresenterError)
    {
        loadingViewController.showSpinner(false)
        loadingViewController.showMessage(true)
    }
}

