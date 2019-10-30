//
//  AppDelegate.swift
//  BabylonDemoApp
//
//  Created by Saman Badakhshan on 17/10/2019.
//  Copyright © 2019 Saman Badakhshan. All rights reserved.
//

import UIKit
import BabylonApiService

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let navigationController = PostsNavigationController()
        let router = PostsRouter(navigator: navigationController)
        let postsViewController = PostsRouter.makePostsViewController(router: router)
        navigationController.viewControllers = [postsViewController]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
     
        return true
    }
}

