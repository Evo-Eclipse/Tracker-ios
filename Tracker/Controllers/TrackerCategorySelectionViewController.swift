//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 29.07.2025.
//

import UIKit

final class TrackerCategorySelectionViewController: UIViewController {

    // MARK: - Public Properties

    var onCategorySelected: ((String?) -> Void)?

    // MARK: - Private Properties

    private let viewModel: TrackerCategorySelectionViewModel

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        return tableView
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
        label.text = L10n.categoriesDescription
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.addCategoryButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializers

    init(viewModel: TrackerCategorySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()

        view.backgroundColor = .ypWhite

        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupBindings()
        updateEmptyState()
    }

    // MARK: - Actions

    @objc private func addCategoryButtonTapped() {
        presentNewCategoryViewController()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        viewModel.onCategoriesChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
        }

        viewModel.onSelectedCategoryChanged = { [weak self] selectedCategory in
            DispatchQueue.main.async {
                self?.onCategorySelected?(selectedCategory)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func setupNavigationBar() {
        title = L10n.categoryTitle
        navigationItem.hidesBackButton = true
    }

    private func presentNewCategoryViewController() {
        let viewModel = TrackerNewCategoryViewModel()
        let newCategoryVC = TrackerNewCategoryViewController(viewModel: viewModel)
        newCategoryVC.onCategoryCreated = { [weak self] newCategory in
            guard let self = self else { return }
            self.viewModel.addCategory(title: newCategory)
        }

        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        present(navigationController, animated: true)
    }

    private func setupViews() {
        [tableView, placeholderStackView, addCategoryButton].forEach {
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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),

            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func updateEmptyState() {
        let isEmpty = viewModel.isEmpty
        placeholderStackView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

// MARK: - UITableViewDataSource

extension TrackerCategorySelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }

        let categoryTitle = viewModel.categoryTitle(at: indexPath.row)
        let isSelected = viewModel.isSelected(at: indexPath.row)
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == viewModel.numberOfCategories - 1

        cell.configure(
            title: categoryTitle,
            isSelected: isSelected,
            isFirstCell: isFirstCell,
            isLastCell: isLastCell
        )

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TrackerCategorySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
}
