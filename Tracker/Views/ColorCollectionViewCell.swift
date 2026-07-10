//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Pavel Komarov on 06.08.2025.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {

    // MARK: - Public Properties

    static let reuseIdentifier = "ColorCell"

    // MARK: - Private Properties

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Color Cell - Blue") {
    let cell: UIView = {
        let c = ColorCollectionViewCell()
        c.configure(with: .ypSelection1)
        c.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
        c.layoutIfNeeded()
        return c
    }()
    cell
}

#Preview("Color Cell - Red") {
    let cell: UIView = {
        let c = ColorCollectionViewCell()
        c.configure(with: .ypSelection3)
        c.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
        c.layoutIfNeeded()
        return c
    }()
    cell
}
#endif
