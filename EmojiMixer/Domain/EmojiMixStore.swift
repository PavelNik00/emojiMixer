//
//  EmojiMixStore.swift
//  EmojiMixer
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import CoreData
import UIKit

enum EmojiMixStoreError: Error {
    case decodingErrorInvalidEmojies
    case decodingErrorInvalidColorHex
}

struct EmojiMixStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

// сообщает View Controller об обновлении
protocol EmojiMixStoreDelegate: AnyObject {
    func store(
        _ store: EmojiMixStore,
        didUpdate update: EmojiMixStoreUpdate
    )
}

final class EmojiMixStore: NSObject {
    
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    // получает из БД сохранённые записи и передаёт через делегирование обновления в EmojiMixStore
    private var fetchedResultsController: NSFetchedResultsController<EmojiMixCoreData>!
    
    weak var delegate: EmojiMixStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<EmojiMixStoreUpdate.Move>?
    
    // получаем контекст из AppDelegate
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    // сохраняем ссылку на переданных контекст
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()

        // создаём запрос NSFetchRequest<ManagedRecord> — он работает с объектами типа ManagedRecord
        let fetchRequest = EmojiMixCoreData.fetchRequest()
        
        // Обязательно указываем минимум один параметр сортировки
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \EmojiMixCoreData.emojis, ascending: true)
        ]
        
        // Для создания контроллера укажем два обязательных параметра:
        // - запрос NSFetchRequest — в нём содержится минимум один параметр сортировки;
        // - контекст NSManagedObjectContext — он нужен для выполнения запроса
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        // Назначаем контроллеру делегата, чтобы уведомлять об изменениях
        controller.delegate = self
        
        // Делаем выборку данных
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    //
    var emojiMixes: [EmojiMix] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let emojiMixes = try? objects.map({ try self.emojiMix(from: $0) })
        else { return [] }
        return emojiMixes
    }
    
//    func fetchEmojiMixes() throws -> [EmojiMix] {
//        let fetchRequest = EmojiMixCoreData.fetchRequest()
//        let emojiMixesFromCoreData = try context.fetch(fetchRequest)
//        return try emojiMixesFromCoreData.map { try self.emojiMix(from: $0) }
//    }
    
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
    
    func emojiMix(from emojiMixCoreData: EmojiMixCoreData) throws -> EmojiMix {
        guard let emojis = emojiMixCoreData.emojis else {
            throw EmojiMixStoreError.decodingErrorInvalidEmojies
        }
        guard let colorHex = emojiMixCoreData.colorHex else {
            throw EmojiMixStoreError.decodingErrorInvalidEmojies
        }
        return EmojiMix(
            emoji: emojis,
            backgroundColor: uiColorMarshalling.color(from: colorHex)
        )
    }
}

extension EmojiMixStore: NSFetchedResultsControllerDelegate {
    
    // Метод controllerWillChangeContent срабатывает перед тем, как
    // изменится состояние объектов, которые добавляются или удаляются.
    // В нём мы инициализируем переменные, которые содержат индексы
    // изменённых объектов
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<EmojiMixStoreUpdate.Move>()
    }

    // Метод controllerDidChangeContent срабатывает после
    // добавления или удаления объектов. В нём мы передаём индексы
    // изменённых объектов в класс MainViewController и очищаем до следующего изменения
    // переменные, которые содержат индексы
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: EmojiMixStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!,
                movedIndexes: movedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }

    // Метод controller(_: didChange anObject) срабатывает после того как изменится
    // состояние конкретного объекта. Мы добавляем индекс
    // изменённого объекта в соответствующий набор индексов:
    // deletedIndexes — для удалённых объектов,
    // insertedIndexes — для добавленных
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}

