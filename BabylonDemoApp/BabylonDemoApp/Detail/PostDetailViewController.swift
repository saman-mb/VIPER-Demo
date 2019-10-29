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

    private let presenter: PostDetailPresenter
    private let loadingViewController: LoadingViewController
    private let selection: PostDetailsSelection
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var commentCountLabel: UILabel!
    
    static func makeFromStoryBoard(router: PostsRoutable, selection: PostDetailsSelection) -> PostDetailViewController
    {
        let storyboard = UIStoryboard(name: "ViewControllers", bundle: nil)
        let postsViewController = storyboard.instantiateViewController(identifier: "PostDetailViewController", creator: { coder in
            return PostDetailViewController(coder: coder, presenter: PostDetailPresenter(api: BabylonServiceFactory.makeApi(), router: router, fileWriter: DocumentsFacade()), selection: selection)
        })
        return postsViewController
    }
    
    required init?(coder: NSCoder, presenter: PostDetailPresenter, selection: PostDetailsSelection)
    {
        self.presenter = presenter
        self.selection = selection
        self.loadingViewController = LoadingViewController.makeFromStoryBoard()
        super.init(coder: coder)
        self.presenter.delegate = self
        self.loadingViewController.delegate = self
    }

    required init?(coder: NSCoder)
    {
        fatalError("You must create this view controller with a \(PostDetailPresenter.self)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addChild(loadingViewController)
        view.addSubview(loadingViewController.view)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        presenter.loadDetails(for: selection)
    }
}

extension PostDetailViewController: LoadingViewControllerDelegagte
{
    func loadingViewControllerDidTapRetryButton()
    {
        presenter.loadDetails(for: selection)
    }
}

extension PostDetailViewController: PostDetailPresentableDelegate
{
    func postDetailPresenterDidStartLoading()
    {
        loadingViewController.showMessage(false)
        loadingViewController.showSpinner(true)
    }
    
    func postDetailPresenterDidFinishLoading(viewModel: PostDetailsViewModel)
    {
        loadingViewController.showMessage(false)
        loadingViewController.showSpinner(false)
        title = viewModel.authorTitle
        descriptionTextView.text = viewModel.description
        commentCountLabel.text = viewModel.numberOfCommentsText
    }
    
    func postDetailPresenterDidFailToLoadWithError(_ error: Error)
    {
        loadingViewController.showMessage(true)
        loadingViewController.showSpinner(false)
    }
}
