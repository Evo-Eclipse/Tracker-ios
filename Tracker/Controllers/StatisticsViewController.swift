//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 24.07.2025.
//

import UIKit

final class StatisticsViewController: UIViewController {

    // MARK: - Private Properties

    private lazy var bestPeriodCard = StatisticCardView(title: L10n.bestPeriodTitle)
    private lazy var perfectDaysCard = StatisticCardView(title: L10n.perfectDaysTitle)
    private lazy var completedCard = StatisticCardView(title: L10n.completedTrackersTitle)
    private lazy var averageCard = StatisticCardView(title: L10n.averageValueTitle)

    private lazy var statisticsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            bestPeriodCard, perfectDaysCard, completedCard, averageCard
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var placeholderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "iconSmilingFaceWithTear")
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.emptyStatisticsMessage
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()

    private let viewModel: StatisticsViewModel

    // MARK: - Initializers

    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite
        viewModel.delegate = self

        setupNavigationBar()
        setupViews()
        setupConstraints()
        viewModel.loadStatistics()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadStatistics()
        AnalyticsService.shared.reportScreenOpen(screen: .statistics)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.reportScreenClose(screen: .statistics)
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = L10n.statisticsTab
    }

    private func setupViews() {
        [statisticsStackView, placeholderStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [placeholderImageView, placeholderLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            placeholderStackView.addArrangedSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            statisticsStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            statisticsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            bestPeriodCard.heightAnchor.constraint(equalToConstant: 90),

            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func updateUI(hasData: Bool) {
        statisticsStackView.isHidden = !hasData
        placeholderStackView.isHidden = hasData
    }
}

// MARK: - StatisticsViewModelDelegate

extension StatisticsViewController: StatisticsViewModelDelegate {
    func viewModel(_ viewModel: StatisticsViewModel, didUpdate data: StatisticsData) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.bestPeriodCard.setValue(data.bestPeriod)
            self.perfectDaysCard.setValue(data.perfectDays)
            self.completedCard.setValue(data.completedTrackers)
            self.averageCard.setValue(data.averageValue)
        }
    }

    func viewModel(_ viewModel: StatisticsViewModel, didUpdateHasData hasData: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(hasData: hasData)
        }
    }
}
