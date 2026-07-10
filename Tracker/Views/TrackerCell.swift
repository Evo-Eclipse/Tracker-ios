//
//  TrackerCell.swift
//  Tracker
//
//  Created by Pavel Komarov on 29.07.2025.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didToggleTracker(_ tracker: Tracker, on date: Date)
    func getCompletionCount(for trackerId: UUID) -> Int
    func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool
    func didRequestEditTracker(_ tracker: Tracker)
    func didRequestDeleteTracker(_ tracker: Tracker)
}

final class TrackerCell: UICollectionViewCell {

    // MARK: - Public Properties

    static let identifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?

    // MARK: - Private Properties

    private var tracker: Tracker?
    private var currentDate: Date = Date()
    private var isCompleted: Bool = false

    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        // view.backgroundColor will be adapted during cell configuration
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        // label.text will be adapted during cell configuration
        return label
    }()

    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 2
        // label.text will be adapted during cell configuration
        return label
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        // label.text will be adapted during cell configuration
        return label
    }()

    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage.buttonCompleteInactive.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        // button.tintColor will be adapted during cell configuration
        return button
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraints()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc private func completeButtonTapped() {
        guard let tracker = tracker else { return }

        let calendar = Calendar.app
        let today = calendar.startOfDay(for: Date())
        let selectedDate = calendar.startOfDay(for: currentDate)

        if selectedDate > today {
            return
        }

        delegate?.didToggleTracker(tracker, on: currentDate)

        isCompleted.toggle()
        updateCompletionState()
        updateCountLabel()
    }

    // MARK: - Public Methods

    func configure(with tracker: Tracker, on date: Date = Date()) {
        self.tracker = tracker
        self.currentDate = date

        let appColor = tracker.color
        let uiColor = UIColor(appColor: appColor)
        cardView.backgroundColor = uiColor
        completeButton.tintColor = uiColor

        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title

        updateCompletionState()
        updateCountLabel()
    }

    // MARK: - Private Methods

    private func setupViews() {
        [emojiBackgroundView, emojiLabel, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }

        [cardView, countLabel, completeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: emojiBackgroundView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            completeButton.widthAnchor.constraint(equalToConstant: 44),
            completeButton.heightAnchor.constraint(equalToConstant: 44),

            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: completeButton.leadingAnchor, constant: -8)
        ])
    }

    private func setupGestures() {
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        cardView.addInteraction(contextMenuInteraction)
    }

    private func updateCompletionState() {
        guard let tracker = tracker else { return }

        isCompleted = delegate?.isTrackerCompleted(tracker.id, on: currentDate) ?? false

        let image = (isCompleted ? UIImage.buttonCompleteActive : UIImage.buttonCompleteInactive).withRenderingMode(.alwaysTemplate)

        completeButton.setImage(image, for: .normal)

        completeButton.alpha = isCompleted ? 0.3 : 1.0

        let calendar = Calendar.app
        let today = calendar.startOfDay(for: Date())
        let selectedDate = calendar.startOfDay(for: currentDate)
        completeButton.isEnabled = selectedDate <= today
    }

    private func updateCountLabel() {
        guard let tracker = tracker else { return }

        let completionCount = delegate?.getCompletionCount(for: tracker.id) ?? 0
        countLabel.text = DaysFormatter.localizedDaysCount(completionCount)
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let tracker = tracker else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: L10n.editAction, image: nil) { [weak self] _ in
                self?.delegate?.didRequestEditTracker(tracker)
            }

            let deleteAction = UIAction(title: L10n.deleteAction, image: nil, attributes: .destructive) { [weak self] _ in
                self?.delegate?.didRequestDeleteTracker(tracker)
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

// MARK: - Preview

#if DEBUG
private final class MockTrackerCellDelegate: TrackerCellDelegate {
    private let completionCount: Int
    private let isCompleted: Bool

    init(completionCount: Int = 0, isCompleted: Bool = false) {
        self.completionCount = completionCount
        self.isCompleted = isCompleted
    }

    func didToggleTracker(_ tracker: Tracker, on date: Date) {}
    func getCompletionCount(for trackerId: UUID) -> Int { completionCount }
    func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool { isCompleted }
    func didRequestEditTracker(_ tracker: Tracker) {}
    func didRequestDeleteTracker(_ tracker: Tracker) {}
}

#Preview("Regular Tracker Cell") {
    let tracker = Tracker(
        id: UUID(),
        title: "Пить воду",
        color: UIColor.ypSelection1.appColor,
        emoji: "💧",
        schedule: [.monday, .tuesday, .wednesday, .thursday, .friday]
    )

    let cell: UIView = {
        let c = TrackerCell()
        c.delegate = MockTrackerCellDelegate(completionCount: 5, isCompleted: false)
        c.configure(with: tracker, on: Date())
        c.frame = CGRect(x: 0, y: 0, width: 167, height: 158)
        c.layoutIfNeeded()
        return c
    }()
    cell
}

#Preview("Completed Tracker Cell") {
    let tracker = Tracker(
        id: UUID(),
        title: "Сделано!",
        color: UIColor.ypSelection2.appColor,
        emoji: "✅",
        schedule: [.monday]
    )

    let cell: UIView = {
        let c = TrackerCell()
        c.delegate = MockTrackerCellDelegate(completionCount: 10, isCompleted: true)
        c.configure(with: tracker, on: Date())
        c.frame = CGRect(x: 0, y: 0, width: 167, height: 158)
        c.layoutIfNeeded()
        return c
    }()
    cell
}

#Preview("Long Title Tracker Cell") {
    let tracker = Tracker(
        id: UUID(),
        title: "Очень длинное название трекера которое должно переноситься",
        color: UIColor.ypSelection3.appColor,
        emoji: "📝",
        schedule: [.saturday, .sunday]
    )

    let cell: UIView = {
        let c = TrackerCell()
        c.delegate = MockTrackerCellDelegate(completionCount: 3, isCompleted: false)
        c.configure(with: tracker, on: Date())
        c.frame = CGRect(x: 0, y: 0, width: 167, height: 158)
        c.layoutIfNeeded()
        return c
    }()
    cell
}
#endif
