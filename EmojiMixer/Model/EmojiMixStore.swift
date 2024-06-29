//
//  EmojiMixStore.swift
//  EmojiMixer
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import UIKit
import CoreData

enum EmojiMixStoreError: Error {
    case decodingErrorInvalidEmojies
    case decodingErrorInvalidColorHex
}

protocol EmojiMixStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: EmojiMixStore)
}

final class EmojiMixStore: NSObject {
    private let uiColorMarshalling = UIColorMarshalling()
    
    // контекст для работы с кор дата
    private let context: NSManagedObjectContext
    
    // управление результатами запросов с кор дата
    private var fetchedResultsController: NSFetchedResultsController<EmojiMixCoreData>!

    // уведомление об изменений данных
    weak var delegate: EmojiMixStoreDelegate?

    // инициализация и настройка NSFetchedResultsController
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()

        let fetchRequest = EmojiMixCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \EmojiMixCoreData.emojies, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }

    // возвращаем текущие эмодзи
    var emojiMixes: [EmojiMixCoreData] {
        return self.fetchedResultsController.fetchedObjects ?? []
    }

    // добавляем новые эмодзи
    func addNewEmojiMix(_ emojies: String, color: UIColor) throws {
        let emojiMixCoreData = EmojiMixCoreData(context: context)
        emojiMixCoreData.emojies = emojies
        emojiMixCoreData.colorHex = uiColorMarshalling.hexString(from: color)
        try context.save()
    }

    // удаляем все эмодзи
    func deleteAll() throws {
        let objects = fetchedResultsController.fetchedObjects ?? []
        for object in objects {
            context.delete(object)
        }
        try context.save()
    }

    // преобразование данных из кор дата в объект EmojiMix
    private func emojiMix(from emojiMixCorData: EmojiMixCoreData) throws -> EmojiMix {
        guard let emojies = emojiMixCorData.emojies else {
            throw EmojiMixStoreError.decodingErrorInvalidEmojies
        }
        guard let colorHex = emojiMixCorData.colorHex else {
            throw EmojiMixStoreError.decodingErrorInvalidEmojies
        }
        return EmojiMix(
            emojies: emojies,
            backgroundColor: uiColorMarshalling.color(from: colorHex)
        )
    }
}

extension EmojiMixStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}

