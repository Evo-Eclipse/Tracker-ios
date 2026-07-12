//
//  SplashViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 23.07.2025.
//

import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Private Properties

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.iconSplash
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlue

        setupViews()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        switchToTabBarViewController()
    }

    // MARK: - Private Methods

    private func setupViews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func switchToTabBarViewController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid configuration, no main window found")
            return
        }

        let tabBarViewController = TabBarViewController()
        window.rootViewController = tabBarViewController

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }
}
