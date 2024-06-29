//
//  EmojiMixViewModel.swift
//  EmojiMixer
//
//  Created by Pavel Nikipelov on 29.06.2024.
//

import UIKit

typealias Binding<T> = (T) -> Void

final class EmojiMixViewModel: Identifiable {
    let id: String
    private let emojis: String
    private let backgroundColor: UIColor

    init(id: String, emojis: String, backgroundColor: UIColor) {
        self.id = id
        self.emojis = emojis
        self.backgroundColor = backgroundColor
    }
    
    var emojiBinding: Binding<String>? {
        didSet {
            emojiBinding?(emojis)
        }
    }
    
    var backgroundColorBinding: Binding<UIColor>? {
        didSet {
            backgroundColorBinding?(backgroundColor)
        }
    }
}
