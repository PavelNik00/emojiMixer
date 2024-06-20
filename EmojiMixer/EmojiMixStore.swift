//
//  EmojiMixStore.swift
//  EmojiMixer
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import CoreData
import UIKit

final class EmojiMixStore {
    
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    // сохраняем ссылку на переданных контекст
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // получаем контекст из AppDelegate
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    func addNewEmojiMix(_ emojiMix: EmojiMix) throws {
        // создаем новый емоздимикскордата
        let emojiMixCoreData = EmojiMixCoreData(context: context)
        updateExistingEmojiMix(emojiMixCoreData, with: emojiMix)
        try context.save()
    }
    
    func updateExistingEmojiMix(_ emojiMixCoreData: EmojiMixCoreData, with mix: EmojiMix) {
        emojiMixCoreData.emojis = mix.emoji
        emojiMixCoreData.colorHex = uiColorMarshalling.hexString(from: mix.backgroundColor)
    }
}
