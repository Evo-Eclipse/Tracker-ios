//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 24.07.2025.
//

import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Private Properties

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.buttonAdd, for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()

    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = L10n.filtersButton
        config.baseBackgroundColor = .ypBlue
        config.baseForegroundColor = .ypWhite
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        config.background.cornerRadius = 16
        button.configuration = config
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.placeholder = L10n.searchPlaceholder
        return controller
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
        view.image = UIImage.iconDizzy
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.emptyTrackersMessage
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeaderView.identifier)
        return collectionView
    }()

    private var dataSource: UICollectionViewDiffableDataSource<TrackerCategory, Tracker>!

    private let viewModel: TrackersViewModel
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date = Date()

    private var categoryStore: TrackerCategoryStore {
        return viewModel.categoryStore
    }

    // MARK: - Initializers

    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite
        viewModel.delegate = self

        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupDataSource()

        // Sync initial state
        currentDate = viewModel.getCurrentDate()
        datePicker.date = currentDate

        // Load initial data
        viewModel.setDate(currentDate)

        // Отправляем событие открытия экрана
        AnalyticsService.shared.reportScreenOpen(screen: .main)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Отправляем событие закрытия экрана
        AnalyticsService.shared.reportScreenClose(screen: .main)
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        // Отправляем событие клика на кнопку добавления трека
        AnalyticsService.shared.reportClick(screen: .main, item: .addTrack)
        presentModalViewController()
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        viewModel.setDate(currentDate)
    }

    @objc private func filtersButtonTapped() {
        // Отправляем событие клика на кнопку фильтра
        AnalyticsService.shared.reportClick(screen: .main, item: .filter)
        let currentFilter = viewModel.getCurrentFilter()
        let filtersViewController = FiltersViewController(selected: currentFilter)
        filtersViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: filtersViewController)
        present(navigationController, animated: true)
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = L10n.trackersTab

        let addBarButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.leftBarButtonItem = addBarButtonItem

        let datePickerBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerBarButtonItem

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupViews() {
        [placeholderStackView, collectionView, filtersButton].forEach {
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
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func presentModalViewController() {
        let modalViewController = TrackerTypeSelectionViewController(categoryStore: categoryStore)
        modalViewController.trackerDelegate = self
        let navigationController = UINavigationController(rootViewController: modalViewController)
        present(navigationController, animated: true)
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<TrackerCategory, Tracker>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, tracker -> UICollectionViewCell? in
            guard let self = self else { return nil }
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCell.identifier,
                for: indexPath
            ) as? TrackerCell else { return UICollectionViewCell() }
            cell.delegate = self
            cell.configure(with: tracker, on: self.currentDate)
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerHeaderView.identifier,
                for: indexPath
            ) as? TrackerHeaderView else { return nil }

            if let category = self?.dataSource.snapshot().sectionIdentifiers[indexPath.section] {
                header.configure(with: category.title)
            }
            return header
        }
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>()
        snapshot.appendSections(visibleCategories)
        for category in visibleCategories {
            snapshot.appendItems(category.trackers, toSection: category)
        }

        // Tracker identity is id-based, so an edited tracker (new title/emoji/color)
        // or the same tracker viewed on a different date (different completion state)
        // is treated as "unchanged" by the diff and its cell would not re-render.
        // Explicitly reconfigure the items that persist across the update.
        let existingItems = Set(dataSource.snapshot().itemIdentifiers)
        let itemsToReconfigure = snapshot.itemIdentifiers.filter { existingItems.contains($0) }
        if !itemsToReconfigure.isEmpty {
            snapshot.reconfigureItems(itemsToReconfigure)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func configurePlaceholder(showNothingFound: Bool) {
        if showNothingFound {
            placeholderImageView.image = UIImage.iconFaceWithMonocle
            placeholderLabel.text = L10n.noSearchResultsMessage
        } else {
            placeholderImageView.image = UIImage.iconDizzy
            placeholderLabel.text = L10n.emptyTrackersMessage
        }
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] _, _ in
            return self?.createTrackerSection()
        }
    }

    private func createTrackerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(158)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 4,
            bottom: 0,
            trailing: 4
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(158)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )

        let section = NSCollectionLayoutSection(group: group)
        // section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 0,
            bottom: 16,
            trailing: 0
        )

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(38)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]

        return section
    }

    // MARK: - TrackersViewModelDelegate

    private func presentEditTracker(_ tracker: Tracker) {
        let editViewController = TrackerEditViewController(
            tracker: tracker,
            recordStore: viewModel.recordStore,
            categoryStore: categoryStore
        )
        editViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: editViewController)
        present(navigationController, animated: true)
    }

    private func confirmDeleteTracker(_ tracker: Tracker) {
        let alertController = UIAlertController(
            title: L10n.deleteConfirmationTitle,
            message: nil,
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(title: L10n.deleteAction, style: .destructive) { [weak self] _ in
            self?.deleteTracker(tracker)
        }
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: L10n.cancelButton, style: .cancel)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func deleteTracker(_ tracker: Tracker) {
        viewModel.deleteTracker(id: tracker.id)
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.setSearchText(searchController.searchBar.text)
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]

        // Отправляем событие тапа на трек
        AnalyticsService.shared.reportClick(screen: .main, item: .track)

        print("Selected tracker: \(tracker.title)")
    }
}

// MARK: - TrackerCreationFormViewControllerDelegate

extension TrackersViewController: TrackerCreationFormViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, in category: String) {
        viewModel.createTracker(tracker, in: category)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func didToggleTracker(_ tracker: Tracker, on date: Date) {
        // Отправляем событие клика на кнопку выполнения трека
        AnalyticsService.shared.reportClick(screen: .main, item: .track)
        viewModel.toggleTracker(tracker, on: date)
    }

    func getCompletionCount(for trackerId: UUID) -> Int {
        return viewModel.getCompletionCount(for: trackerId)
    }

    func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool {
        return viewModel.isTrackerCompleted(trackerId, on: date)
    }

    func didRequestEditTracker(_ tracker: Tracker) {
        // Отправляем событие клика на редактирование
        AnalyticsService.shared.reportClick(screen: .main, item: .edit)
        presentEditTracker(tracker)
    }

    func didRequestDeleteTracker(_ tracker: Tracker) {
        // Отправляем событие клика на удаление
        AnalyticsService.shared.reportClick(screen: .main, item: .delete)
        confirmDeleteTracker(tracker)
    }
}

// MARK: - FiltersViewControllerDelegate

extension TrackersViewController: FiltersViewControllerDelegate {
    func filtersViewController(_ vc: FiltersViewController, didSelect filter: TrackerFilter) {
        viewModel.setFilter(filter)
    }
}

// MARK: - TrackerEditViewControllerDelegate

extension TrackersViewController: TrackerEditViewControllerDelegate {
    func didUpdateTracker(_ tracker: Tracker) {
        viewModel.updateTracker(tracker)
    }
}

// MARK: - TrackersViewModelDelegate

extension TrackersViewController: TrackersViewModelDelegate {
    func viewModel(_ viewModel: TrackersViewModel, didUpdateCategories categories: [TrackerCategory]) {
        visibleCategories = categories
        applySnapshot()
    }

    func viewModel(_ viewModel: TrackersViewModel, didUpdateHasTrackers hasTrackers: Bool) {
        filtersButton.isHidden = !hasTrackers
    }

    func viewModel(_ viewModel: TrackersViewModel, didUpdatePlaceholder type: TrackersPlaceholderType) {
        switch type {
        case .empty, .nothingFound:
            placeholderStackView.isHidden = false
            configurePlaceholder(showNothingFound: type == .nothingFound)
        case .none:
            placeholderStackView.isHidden = true
        }
    }

    func viewModel(_ viewModel: TrackersViewModel, didUpdateDate date: Date) {
        currentDate = date
        datePicker.date = date
    }
}
