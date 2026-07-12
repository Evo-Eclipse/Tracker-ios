//
//  FormRowCell.swift
//  Tracker
//
//  Created by Pavel Komarov on 10.07.2026.
//

import UIKit

/// Shared "category / schedule" row used by the tracker creation and edit forms.
/// Builds its subviews once and reconfigures on reuse — no manual subview stacking.
final class FormRowCell: UITableViewCell {

    static let identifier = "FormRowCell"

    /// Position of the row within its rounded group (controls corner masking and separator).
    enum Position {
        case single   // all corners rounded, no separator
        case top      // top corners rounded, separator at the bottom
        case bottom   // bottom corners rounded, no separator
    }

    // MARK: - Subviews

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var subtitleTopConstraint: NSLayoutConstraint!
    private var titleCenterConstraint: NSLayoutConstraint!

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(title: String, subtitle: String?, position: Position) {
        titleLabel.text = title
        subtitleLabel.text = subtitle

        let hasSubtitle = subtitle?.isEmpty == false
        subtitleLabel.isHidden = !hasSubtitle
        subtitleTopConstraint.isActive = hasSubtitle
        titleCenterConstraint.isActive = !hasSubtitle

        switch position {
        case .single:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separator.isHidden = true
        case .top:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            separator.isHidden = false
        case .bottom:
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separator.isHidden = true
        }
    }

    // MARK: - Private Methods

    private func setup() {
        backgroundColor = .ypBackground.withAlphaComponent(0.3)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        layer.cornerRadius = 16

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(separator)

        subtitleTopConstraint = subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        titleCenterConstraint = titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),

            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
