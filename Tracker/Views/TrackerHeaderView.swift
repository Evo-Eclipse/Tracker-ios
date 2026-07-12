//
//  TrackerHeaderView.swift
//  Tracker
//
//  Created by Pavel Komarov on 29.07.2025.
//

import UIKit

final class TrackerHeaderView: UICollectionReusableView {

    // MARK: - Public Properties

    static let identifier = "TrackerSectionHeaderView"

    // MARK: - Private Properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypBlack
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func configure(with title: String) {
        titleLabel.text = title
    }

    // MARK: - Private Methods

    private func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -28)
        ])
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Tracker Header - Short Title") {
    let header: UIView = {
        let h = TrackerHeaderView(frame: CGRect(x: 0, y: 0, width: 375, height: 38))
        h.configure(with: "Домашние дела")
        h.layoutIfNeeded()
        return h
    }()
    header
}

#Preview("Tracker Header - Long Title") {
    let header: UIView = {
        let h = TrackerHeaderView(frame: CGRect(x: 0, y: 0, width: 375, height: 50))
        h.configure(with: "Очень длинное название категории которое должно переноситься на несколько строк")
        h.layoutIfNeeded()
        return h
    }()
    header
}
#endif
