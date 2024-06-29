//
//  EmojiMixesViewModel.swift
//  EmojiMixer
//
//  Created by Pavel Nikipelov on 29.06.2024.
//

import UIKit

// ViewModel
final class EmojiMixesViewModel {

    // служба для работы с данными эмодзи
    private let emojiMixStore: EmojiMixStore
    
    // фабрика для создания новых эмодзи
    private let emojiMixFactory: EmojiMixFactory
    private let uiColorMarshalling = UIColorMarshalling()

    // массив текущих эмодзи миксов, обновляемых при изменении
    private(set) var emojiMixes: [EmojiMixViewModel] = [] {
        didSet {
            emojiMixesBinding?(emojiMixes)
        }
    }
    
    // привязка для обновления UI при изменении данных
    var emojiMixesBinding: Binding<[EmojiMixViewModel]>?
    
    convenience init() {
        let emojiMixStore = try! EmojiMixStore(
            context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        )
        self.init(emojiMixStore: emojiMixStore, emojiMixFactory: EmojiMixFactory())
    }

    init(emojiMixStore: EmojiMixStore, emojiMixFactory: EmojiMixFactory) {
        self.emojiMixStore = emojiMixStore
        self.emojiMixFactory = emojiMixFactory
        emojiMixStore.delegate = self
        emojiMixes = getEmojiMixesFromStore()
    }

    // метод для обновления нового эмодзи микса
    func addEmojiMixTapped() {
        let newMix = emojiMixFactory.makeNewMix()
        try! emojiMixStore.addNewEmojiMix(newMix.emojies, color: newMix.backgroundColor)
    }

    // метод для удаления всех эмодзи миксов
    func deleteAll() {
        try! emojiMixStore.deleteAll()
    }

    // метод для получения эмодзи миксов из хранилища
    private func getEmojiMixesFromStore() -> [EmojiMixViewModel] {
        return emojiMixStore.emojiMixes.map {
            EmojiMixViewModel(
                id: $0.objectID.uriRepresentation().absoluteString,
                emojis: $0.emojies ?? "",
                backgroundColor: uiColorMarshalling.color(from: $0.colorHex ?? "")
            )
        }
    }
}

extension EmojiMixesViewModel: EmojiMixStoreDelegate {
    // метод делегата вызываемый при изменении данных в хранилище
    func storeDidUpdate(_ store: EmojiMixStore) {
        emojiMixes = getEmojiMixesFromStore()
    }
}
