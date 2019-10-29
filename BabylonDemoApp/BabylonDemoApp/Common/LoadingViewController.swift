//
//  LoadingViewController.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 28/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit

protocol LoadingViewControllerDelegagte: class
{
    func loadingViewControllerDidTapRetryButton()
}

class LoadingViewController: UIViewController {

    weak var delegate: LoadingViewControllerDelegagte?
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var retryButton: UIButton!
    
    static func makeFromStoryBoard() -> LoadingViewController
    {
        let storyboard = UIStoryboard(name: "ViewControllers", bundle: nil)
        let loadingViewController = storyboard.instantiateViewController(identifier: "LoadingViewController", creator: { coder in
            return LoadingViewController(coder: coder)
        })
        return loadingViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSpinner(false)
        showMessage(false)
    }
    
    func showSpinner(_ shouldShow: Bool)
    {
        view.isHidden = !shouldShow
        if shouldShow {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
    }
    
    func showMessage(_ shouldShow: Bool)
    {
        view.isHidden = !shouldShow
        messageLabel.isHidden = !shouldShow
        retryButton.isHidden = !shouldShow
    }
}
