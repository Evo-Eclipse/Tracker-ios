//
//  FilterCell.swift
//  Tracker
//
//  Created by Pavel Komarov on 14.08.2025.
//

import UIKit

final class FilterCell: UITableViewCell {

    // MARK: - Public Properties

    static let identifier = "FilterCell"

    // MARK: - Private Properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .ypBlue
        imageView.isHidden = true
        return imageView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        return view
    }()

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func configure(title: String, isSelected: Bool, isFirstCell: Bool, isLastCell: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected

        if isFirstCell && isLastCell {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirstCell {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastCell {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            layer.cornerRadius = 0
        }

        separatorView.isHidden = isLastCell
    }

    // MARK: - Private Methods

    private func setupCell() {
        backgroundColor = .ypBackground.withAlphaComponent(0.3)
        selectionStyle = .none

        [titleLabel, checkmarkImageView, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -16),

            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Filter Cell - Selected") {
    let cell: UIView = {
        let c = FilterCell()
        c.configure(title: "Сегодня", isSelected: true, isFirstCell: true, isLastCell: true)
        c.frame = CGRect(x: 0, y: 0, width: 375, height: 75)
        c.layoutIfNeeded()
        return c
    }()
    cell
}

#Preview("Filter Cell - Not Selected") {
    let cell: UIView = {
        let c = FilterCell()
        c.configure(title: "Завтра", isSelected: false, isFirstCell: false, isLastCell: false)
        c.frame = CGRect(x: 0, y: 0, width: 375, height: 75)
        c.layoutIfNeeded()
        return c
    }()
    cell
}
#endif
