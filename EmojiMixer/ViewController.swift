//
//  ViewController.swift
//  EmojiMixer
//
//  Created by Pavel Nikipelov on 15.05.2024.
//

import UIKit

class ViewController: UIViewController {

    let collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    
    private var emoji = [String]()
//    private let emoji = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
    
    private let addButton = UIButton()
    private let undoButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
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

    func setupAddButton() {
        
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemBlue
        
        addButton.addAction(UIAction(title: "+", handler: { [weak self] _ in
            // Массив доступных эмозди
            let availableEmoji: [String] = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
            
            // Произвольно выберем эмодзи из массива
            let selectedEmoji = (0..<1).map { _ in availableEmoji[Int.random(in: 0..<availableEmoji.count)] }
            
            // Добавим выбранные эмодзи в коллекцию
            self?.add(emoji: selectedEmoji)
        }), for: .touchUpInside)
        
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
        
        undoButton.addAction(UIAction(title: "Undo", handler: { [weak self] _ in
            self?.removeLastEmoji()
        }), for: .touchUpInside)
        
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
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoji.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? EmojiCollectionViewCell
        
        cell?.label.text = emoji[indexPath.row]
        cell?.contentView.backgroundColor = .white
        
        return cell!
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
