//
//  ViewController.swift
//  EmojiMixer
//
//  Created by Pavel Nikipelov on 15.05.2024.
//

import UIKit

class EmojiMixViewController: UIViewController {

    private let emojiMixFactory = EmojiMixFactory()
    private let emojiMixStore = EmojiMixStore()

    private var visibleEmojiMixes: [EmojiMix] = []
    
    let collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        return collectionView
    }()
    
    
    private var emoji = [String]()
    
    private let addButton = UIButton()
    private let undoButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
//        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        view.addSubview(collectionView)
        setupCollectionView()
        
        view.addSubview(addButton)
        setupAddButton()
 
        view.addSubview(undoButton)
        setupUndoButton()
    }
    
    func setupCollectionView() {
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // создаем новый микс эмодзи при нажатии на клавишу +
    @objc func addNewEmojiMix() {
        let newMix = emojiMixFactory.makeNewMix()
        
        let newMixIndex = visibleEmojiMixes.count
        visibleEmojiMixes.append(newMix) // добавляем микс в visibleEmojuMixes
        
        // обновляем коллекцию
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [IndexPath(item: newMixIndex, section: 0)])
        }
    }
    
    @objc func removeNewEmojiMix() {
        let newMix = emojiMixFactory.makeNewMix()
        
        let newMixIndex = visibleEmojiMixes.count - 1
        visibleEmojiMixes.removeLast()
        
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [IndexPath(item: newMixIndex, section: 0)])
        }
    }
    
    func setupAddButton() {
        
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemBlue
        
        addButton.addTarget(self, action: #selector(addNewEmojiMix), for: .touchUpInside)
//        addButton.addAction(UIAction(title: "+", handler: { [weak self] _ in
//            // Массив доступных эмозди
//            let availableEmoji: [String] = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
//            
//            // Произвольно выберем эмодзи из массива
//            let selectedEmoji = (0..<1).map { _ in availableEmoji[Int.random(in: 0..<availableEmoji.count)] }
//
//            // Добавим выбранные эмодзи в коллекцию
//            self?.add(emoji: selectedEmoji)
//        }), for: .touchUpInside)
//        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 250),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupUndoButton(){
        
        undoButton.setTitle("Undo", for: .normal)
        undoButton.setTitleColor(.white, for: .normal)
        undoButton.backgroundColor = .systemBlue
        
        undoButton.addTarget(self, action: #selector(removeNewEmojiMix), for: .touchUpInside)

//        undoButton.addAction(UIAction(title: "Undo", handler: { [weak self] _ in
//            self?.removeLastEmoji()
//        }), for: .touchUpInside)
        
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            undoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -250),
            undoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            undoButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            undoButton.heightAnchor.constraint(equalToConstant: 50),
            undoButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func add(emoji values: [String]) {
        guard !values.isEmpty else { return }
        
        let count = emoji.count
        emoji += values
        
        collectionView.performBatchUpdates{
            let indexes = (count..<emoji.count).map { IndexPath(row: $0, section: 0) }
            collectionView.insertItems(at: indexes)
        }
    }
    
    func removeLastEmoji() {
        guard !emoji.isEmpty else { return }
        
        let count = emoji.count - 1 // определяем индекс последнего элемента в массиве emoji
        emoji.removeLast() // удаляем последний элемент из массива
        
        collectionView.performBatchUpdates{ // обновляем кооллекцию в батс-режиме
            let indexes = IndexPath(row: count, section: 0)// создаем индекс пути последнего элемента (удаленного)
            collectionView.deleteItems(at: [indexes]) // удаляем элемент из collView по этому индеку пути
        }
    }
    
    // метод для вычисления цвета фона
    func makeColor(_ emojis: (String, String, String)) -> UIColor {
         func cgfloat256(_ t: String) -> CGFloat {
              let value = t.unicodeScalars.reduce(Int(0)) { r, t in
                 return r + Int(t.value)
             }
             return CGFloat(value % 128) / 255.0 + 0.25
         }
         return UIColor(
             red: cgfloat256(emojis.0),
             green: cgfloat256(emojis.1),
             blue: cgfloat256(emojis.2),
             alpha: 1
         )
    }
}

extension EmojiMixViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleEmojiMixes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? EmojiCollectionViewCell
        
        let emojiMix = visibleEmojiMixes[indexPath.row]
        cell?.label.text = emojiMix.emoji
        cell?.contentView.backgroundColor = emojiMix.backgroundColor
        
        return cell!
    }
}

extension EmojiMixViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
