//
//  StatisticCardView.swift
//  Tracker
//
//  Created by Pavel Komarov on 10.07.2026.
//

import UIKit

/// A card showing a single statistic value with a gradient border, per the design.
final class StatisticCardView: UIView {

    // MARK: - Private Properties

    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.text = "0"
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()

    private let gradientLayer = CAGradientLayer()
    private let borderShape = CAShapeLayer()

    // MARK: - Initializers

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    /// Updates the displayed value
    func setValue(_ value: Int) {
        numberLabel.text = "\(value)"
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        // Inset by half the line width so the 1pt stroke stays fully inside the bounds
        borderShape.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: 16
        ).cgPath
    }

    // MARK: - Private Methods

    private func setup() {
        layer.cornerRadius = 16

        gradientLayer.colors = [
            UIColor(red: 0.99, green: 0.3, blue: 0.29, alpha: 1).cgColor,  // #FD4C49
            UIColor(red: 0.27, green: 0.9, blue: 0.62, alpha: 1).cgColor,  // #46E69D
            UIColor(red: 0, green: 0.48, blue: 0.98, alpha: 1).cgColor     // #007BFA
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16

        borderShape.lineWidth = 1
        borderShape.fillColor = UIColor.clear.cgColor
        borderShape.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = borderShape

        layer.addSublayer(gradientLayer)

        [numberLabel, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Statistic Card") {
    let card = StatisticCardView(title: "Лучший период")
    card.setValue(6)
    card.frame = CGRect(x: 0, y: 0, width: 343, height: 90)
    card.layoutIfNeeded()
    return card
}
#endif
