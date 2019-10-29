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
    
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var commentCountLabel: UILabel!
    
    static func makeFromStoryBoard(router: PostsRoutable) -> PostDetailViewController
    {
        let storyboard = UIStoryboard(name: "ViewControllers", bundle: nil)
        let postsViewController = storyboard.instantiateViewController(identifier: "PostDetailViewController", creator: { coder in
            return PostDetailViewController(coder: coder, presenter: PostDetailPresenter(api: BabylonServiceFactory.makeApi(), router: router, fileWriter: DocumentsFacade()))
        })
        return postsViewController
    }
    
    required init?(coder: NSCoder, presenter: PostDetailPresenter)
    {
        self.presenter = presenter
        self.loadingViewController = LoadingViewController.makeFromStoryBoard()
        super.init(coder: coder)
        self.presenter.delegate = self
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
        // dipsplay content
    }
    
    func postDetailPresenterDidFailToLoadWithError(_ error: Error)
    {
        loadingViewController.showMessage(true)
        loadingViewController.showSpinner(false)
    }
}
