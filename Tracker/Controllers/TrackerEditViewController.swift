//
//  TrackerEditViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 14.08.2025.
//

import UIKit

protocol TrackerEditViewControllerDelegate: AnyObject {
    func didUpdateTracker(_ tracker: Tracker)
}

final class TrackerEditViewController: UIViewController {

    // MARK: - Public Properties

    weak var delegate: TrackerEditViewControllerDelegate?

    // MARK: - Private Properties

    private let viewModel: TrackerEditViewModel
    private let categoryStore: TrackerCategoryStore
    private let maxTitleLength = Validation.maxTitleLength

    private var tableViewTopConstraint: NSLayoutConstraint!
    private var errorLabelHeightConstraint: NSLayoutConstraint!

    private lazy var titleTextField: UITextField = {
        let textField = SpacedTextField()
        textField.placeholder = L10n.trackerNamePlaceholder
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .ypBackground.withAlphaComponent(0.3)
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = MessageFormatter.characterLimitTemplate(maxTitleLength)
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FormRowCell.self, forCellReuseIdentifier: FormRowCell.identifier)
        return tableView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.cancelButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.emojiSectionTitle
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()

    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.colorSectionTitle
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.saveButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    private var trackerType: TrackerType {
        return viewModel.trackerType
    }

    // MARK: - Initializers

    init(tracker: Tracker, recordStore: TrackerRecordStore, categoryStore: TrackerCategoryStore) {
        self.viewModel = TrackerEditViewModel(tracker: tracker, recordStore: recordStore)
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()

        view.backgroundColor = .ypWhite

        setupViewModel()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setErrorHidden(true)
        populateFields()
        viewModel.updateDaysCount()
    }

    private func setupViewModel() {
        viewModel.delegate = self
    }

    // MARK: - Actions

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func saveButtonTapped() {
        viewModel.saveTracker()
    }

    @objc private func textFieldDidChange() {
        guard let text = titleTextField.text else { return }
        viewModel.setTitle(text)
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        title = L10n.editHabitTitle
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleTextField, errorLabel, daysCountLabel, tableView, emojiLabel, emojiCollectionView,
         colorLabel, colorsCollectionView, cancelButton, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    private func setupConstraints() {
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24)
        errorLabelHeightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            daysCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            daysCountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            titleTextField.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 40),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),

            errorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            errorLabelHeightConstraint,

            tableViewTopConstraint,
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: trackerType.hasSchedule ? 150 : 75),

            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),

            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            colorsCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 204),

            cancelButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -34),

            saveButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -34)
        ])
    }

    private func populateFields() {
        titleTextField.text = viewModel.title
    }

    private func setErrorHidden(_ hidden: Bool) {
        errorLabel.isHidden = hidden
        errorLabelHeightConstraint.constant = hidden ? 0 : 22
        tableViewTopConstraint.constant = hidden ? 24 : 46
    }

    private func setDaysCount(_ count: Int) {
        daysCountLabel.text = DaysFormatter.localizedDaysCount(count)
    }
}

// MARK: - UITextFieldDelegate

extension TrackerEditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if updatedText.count > maxTitleLength {
            setErrorHidden(false)
            return false
        } else {
            setErrorHidden(true)
            return true
        }
    }
}

// MARK: - UITableViewDataSource

extension TrackerEditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerType.hasSchedule ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FormRowCell.identifier, for: indexPath) as? FormRowCell else {
            return UITableViewCell()
        }

        let position: FormRowCell.Position = trackerType.hasSchedule
            ? (indexPath.row == 0 ? .top : .bottom)
            : .single

        if indexPath.row == 0 {
            cell.configure(title: L10n.categoryTitle, subtitle: viewModel.selectedCategory, position: position)
        } else {
            cell.configure(title: L10n.scheduleTitle,
                           subtitle: DaysFormatter.scheduleSubtitle(for: viewModel.selectedSchedule),
                           position: position)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TrackerEditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let categoryViewModel = TrackerCategorySelectionViewModel(categoryStore: categoryStore)
            let categoryVC = TrackerCategorySelectionViewController(viewModel: categoryViewModel)

            categoryVC.onCategorySelected = { [weak self] selectedCategory in
                guard let self = self, let selectedCategory = selectedCategory else { return }
                self.viewModel.setSelectedCategory(selectedCategory)
            }
            navigationController?.pushViewController(categoryVC, animated: true)
        } else {
            let scheduleVC = TrackerScheduleSelectionViewController()
            scheduleVC.onScheduleSelected = { [weak self] selectedDays in
                self?.viewModel.setSelectedSchedule(selectedDays)
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerEditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? String.selectionEmojis.count : UIColor.selectionColors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            let emoji = String.selectionEmojis[indexPath.item]
            cell.emojiLabel.text = emoji
            cell.contentView.backgroundColor = .clear
            cell.layer.cornerRadius = 16

            // Set initial selection state
            if emoji == viewModel.selectedEmoji {
                cell.setSelected(true)
            } else {
                cell.setSelected(false)
            }

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            let color = UIColor.selectionColors[indexPath.item]
            cell.configure(with: color)
            cell.layer.cornerRadius = 8

            // Set initial selection state
            if color == viewModel.selectedColor {
                cell.contentView.layer.borderWidth = 3
                cell.contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
                cell.contentView.layer.cornerRadius = 8
            } else {
                cell.contentView.layer.borderWidth = 0
            }

            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerEditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerEditViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            // Deselect previous emoji
            let previousEmoji = viewModel.selectedEmoji
            if let previousIndex = String.selectionEmojis.firstIndex(of: previousEmoji),
               let previousCell = collectionView.cellForItem(at: IndexPath(item: previousIndex, section: 0)) as? EmojiCollectionViewCell {
                previousCell.setSelected(false)
            }

            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
                cell.setSelected(true)
                viewModel.setSelectedEmoji(String.selectionEmojis[indexPath.item])
            }
        } else {
            // Deselect previous color
            let previousColor = viewModel.selectedColor
            if let previousIndex = UIColor.selectionColors.firstIndex(of: previousColor),
               let previousCell = collectionView.cellForItem(at: IndexPath(item: previousIndex, section: 0)) as? ColorCollectionViewCell {
                previousCell.contentView.layer.borderWidth = 0
            }

            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
                cell.contentView.layer.borderWidth = 3
                cell.contentView.layer.borderColor = UIColor.selectionColors[indexPath.item].withAlphaComponent(0.3).cgColor
                cell.contentView.layer.cornerRadius = 8
                viewModel.setSelectedColor(UIColor.selectionColors[indexPath.item])
            }
        }
    }
}

// MARK: - TrackerEditViewModelDelegate

extension TrackerEditViewController: TrackerEditViewModelDelegate {
    func viewModelDidUpdateSaveButtonState(_ viewModel: TrackerEditViewModel, isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
        saveButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }

    func viewModel(_ viewModel: TrackerEditViewModel, didUpdateTracker tracker: Tracker) {
        delegate?.didUpdateTracker(tracker)
        dismiss(animated: true)
    }

    func viewModel(_ viewModel: TrackerEditViewModel, didUpdateError isHidden: Bool) {
        setErrorHidden(isHidden)
    }

    func viewModel(_ viewModel: TrackerEditViewModel, didUpdateDaysCount count: Int) {
        setDaysCount(count)
    }

    func viewModelDidUpdateSelectedCategory(_ viewModel: TrackerEditViewModel, category: String) {
        tableView.reloadData()
    }

    func viewModelDidUpdateSelectedSchedule(_ viewModel: TrackerEditViewModel, schedule: Set<Weekday>) {
        tableView.reloadData()
    }
}
