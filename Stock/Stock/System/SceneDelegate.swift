//  SceneDelegate.swift
//  Created by aa on 11/30/22.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var navigationController: UINavigationController?
    var navigationRootVC: UIViewController?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene
        else { return }

        navigationRootVC = WatchListViewController()
        navigationController = UINavigationController(rootViewController: navigationRootVC ?? UIViewController())

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }
}
