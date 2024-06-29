//
//  EmojiCollectionViewCell.swift
//  EmojiMixer
//
//  Created by Pavel Nikipelov on 16.05.2024.
//

import UIKit

// View - предоставление отображает данные и реагирует на действия пользователя
final class EmojiMixCollectionViewCell: UICollectionViewCell {

    let titleLabel: UILabel = UILabel()

    // viewModel для ячейки, обновляет UI при изменении данных
    var viewModel: EmojiMixViewModel! {
        didSet {
            viewModel.emojiBinding = { [weak self] emojis in
                self?.titleLabel.text = emojis
            }
            viewModel.backgroundColorBinding = { [weak self] backgroundColor in
                self?.contentView.backgroundColor = backgroundColor
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

        contentView.layer.cornerRadius = 10.0
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // метод для подготовки ячейки к повторному использованию, обнуляет биндинги
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel.emojiBinding = nil
        viewModel.backgroundColorBinding = nil
    }
}
