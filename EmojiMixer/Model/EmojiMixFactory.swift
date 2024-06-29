//
//  EmojiMixFactory.swift
//  EmojiMixer
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import UIKit

// модель
final class EmojiMixFactory {
    func makeNewMix() -> EmojiMix {
        let emojies = make3RandomEmojies()
        return EmojiMix(
            emojies: "\(emojies.0)\(emojies.1)\(emojies.2)",
            backgroundColor: makeColor(emojies)
        )
    }

    private let emojies = [
        "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒",
        "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️",
        "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄",
    ]

    private func make3RandomEmojies() -> (String, String, String) {
        let first = emojies.randomElement()!
        let second = emojies.randomElement()!
        let third = emojies.randomElement()!
        return (first, second, third)
    }

    private func makeColor(_ emojies: (String, String, String)) -> UIColor {
        func cgfloat256(_ t: String) -> CGFloat {
            let value = t.unicodeScalars.reduce(Int(0)) { r, t in
                return r + Int(t.value)
            }
            return CGFloat(value % 128) / 255.0 + 0.25
        }
        return UIColor(
            red: cgfloat256(emojies.0),
            green: cgfloat256(emojies.1),
            blue: cgfloat256(emojies.2),
            alpha: 1
        )
    }
}



