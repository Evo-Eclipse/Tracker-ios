//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Pavel Komarov on 06.08.2025.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {

    // MARK: - Public Properties

    static let reuseIdentifier = "EmojiCell"

    // MARK: - Private Properties

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()

    let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(cardView)
        cardView.addSubview(emojiLabel)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 52),
            cardView.heightAnchor.constraint(equalToConstant: 52),
            emojiLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func setSelected(_ isSelected: Bool) {
        cardView.backgroundColor = isSelected ? .ypLightGray : .clear
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Emoji Cell - Selected") {
    let cell: UIView = {
        let c = EmojiCollectionViewCell()
        c.emojiLabel.text = "😊"
        c.setSelected(true)
        c.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
        c.layoutIfNeeded()
        return c
    }()
    cell
}

#Preview("Emoji Cell - Not Selected") {
    let cell: UIView = {
        let c = EmojiCollectionViewCell()
        c.emojiLabel.text = "🏃"
        c.setSelected(false)
        c.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
        c.layoutIfNeeded()
        return c
    }()
    cell
}
#endif
