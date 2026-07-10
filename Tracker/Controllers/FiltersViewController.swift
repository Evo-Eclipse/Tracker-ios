//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 14.08.2025.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func filtersViewController(_ vc: FiltersViewController, didSelect filter: TrackerFilter)
}

final class FiltersViewController: UIViewController {

    // MARK: - Public Properties

    weak var delegate: FiltersViewControllerDelegate?

    // MARK: - Private Properties

    private let viewModel: FiltersViewModel

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.identifier)
        return tableView
    }()

    // MARK: - Initializers

    init(selected: TrackerFilter) {
        self.viewModel = FiltersViewModel(selectedFilter: selected)
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
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        title = L10n.filtersTitle
        navigationItem.hidesBackButton = true
    }

    private func setupViews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfFilters()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FilterCell.identifier,
            for: indexPath
        ) as? FilterCell else {
            return UITableViewCell()
        }

        let filter = viewModel.filter(at: indexPath.row)
        let title = viewModel.title(for: filter)
        let showCheckmark = viewModel.isSelected(withCheckmark: filter)
        let isFirstCell = viewModel.isFirstFilter(at: indexPath.row)
        let isLastCell = viewModel.isLastFilter(at: indexPath.row)

        cell.configure(
            title: title,
            isSelected: showCheckmark,
            isFirstCell: isFirstCell,
            isLastCell: isLastCell
        )

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectFilter(at: indexPath.row)
        tableView.reloadData()
        dismiss(animated: true)
    }
}

// MARK: - FiltersViewModelDelegate

extension FiltersViewController: FiltersViewModelDelegate {
    func filtersViewModel(_ viewModel: FiltersViewModel, didSelectFilter filter: TrackerFilter) {
        delegate?.filtersViewController(self, didSelect: filter)
    }
}
