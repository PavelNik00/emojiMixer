### Компоненты MVVM

1. **Model**: Это слой данных. В нашем случае, это `EmojiMixStore`, который взаимодействует с CoreData для сохранения и извлечения данных о смешении эмодзи.
2. **View**: Это пользовательский интерфейс. У нас это `EmojiMixesViewController` и `EmojiMixCollectionViewCell`, которые отображают эмодзи и их цвета.
3. **ViewModel**: Это посредник между Model и View. В нашем случае, это `EmojiMixesViewModel` и `EmojiMixViewModel`, которые управляют данными и бизнес-логикой для представления.

### Шаги работы приложения

1. **Запуск приложения и инициализация ViewController**
    
    Когда приложение запускается, загружается `EmojiMixesViewController`. Это основной экран, который отображает коллекцию смешанных эмодзи.
    
    ```swift
    swiftCopy code
    final class EmojiMixesViewController: UIViewController {
        private var viewModel: EmojiMixesViewModel!
    }
    
    ```
    
2. **Настройка CollectionView и навигационных кнопок**
    
    В методе `viewDidLoad` ViewController настраивает `UICollectionView` и добавляет кнопки в навигационную панель.
    
    ```swift
    swiftCopy code
    override func viewDidLoad() {
        super.viewDidLoad()
        // Настройка навигационной панели
        if let navBar = navigationController?.navigationBar {
            let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewEmojiMix))
            navBar.topItem?.setRightBarButton(rightButton, animated: false)
    
            let leftButton = UIBarButtonItem(
                title: NSLocalizedString("Delete All", comment: ""),
                style: .plain,
                target: self,
                action: #selector(deleteAll)
            )
            navBar.topItem?.setLeftBarButton(leftButton, animated: false)
        }
        // Настройка CollectionView
        setupCollectionView()
        // Инициализация ViewModel
        viewModel = EmojiMixesViewModel()
        viewModel.emojiMixesBinding = { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
    }
    
    ```
    
3. **Инициализация ViewModel и загрузка данных**
    
    ViewModel загружает данные из хранилища (`EmojiMixStore`) и передает их в View.
    
    ```swift
    swiftCopy code
    final class EmojiMixesViewModel {
        private let emojiMixStore: EmojiMixStore
    
        private(set) var emojiMixes: [EmojiMixViewModel] = [] {
            didSet {
                emojiMixesBinding?(emojiMixes)
            }
        }
    
        var emojiMixesBinding: Binding<[EmojiMixViewModel]>?
    
        convenience init() {
            let emojiMixStore = try! EmojiMixStore(
                context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            )
            self.init(emojiMixStore: emojiMixStore, emojiMixFactory: EmojiMixFactory())
        }
    }
    
    ```
    
4. **Связывание данных с View через Binding**
    
    Когда данные в ViewModel обновляются, они передаются в View через биндинг. Это позволяет автоматически обновлять интерфейс при изменении данных.
    
    ```swift
    swiftCopy code
    var emojiMixes: [EmojiMixViewModel] = [] {
        didSet {
            emojiMixesBinding?(emojiMixes)
        }
    }
    
    ```
    
5. **Обработка действий пользователя**
    
    Когда пользователь нажимает кнопку "Добавить", вызывается метод `addNewEmojiMix`, который добавляет новый смешанный эмодзи в хранилище через ViewModel.
    
    ```swift
    swiftCopy code
    @objc
    private func addNewEmojiMix() {
        viewModel.addEmojiMixTapped()
    }
    
    ```
    
    ViewModel добавляет новый эмодзи в хранилище:
    
    ```swift
    swiftCopy code
    func addEmojiMixTapped() {
        let newMix = emojiMixFactory.makeNewMix()
        try! emojiMixStore.addNewEmojiMix(newMix.emojies, color: newMix.backgroundColor)
    }
    
    ```
    
6. **Обновление данных в хранилище и уведомление ViewModel**
    
    Когда данные в хранилище обновляются, `EmojiMixStore` уведомляет об этом ViewModel через делегат:
    
    ```swift
    swiftCopy code
    extension EmojiMixStore: NSFetchedResultsControllerDelegate {
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            delegate?.storeDidUpdate(self)
        }
    }
    
    ```
    
    ViewModel обновляет свои данные и передает их обратно в View:
    
    ```swift
    swiftCopy code
    extension EmojiMixesViewModel: EmojiMixStoreDelegate {
        func storeDidUpdate(_ store: EmojiMixStore) {
            emojiMixes = getEmojiMixesFromStore()
        }
    }
    
    ```
    

### Сводка

1. **ViewController** загружается и настраивает интерфейс.
2. **ViewModel** загружает данные из **Model** (хранилища) и передает их в **View**.
3. **View** отображает данные и предоставляет взаимодействие с пользователем.
4. При взаимодействии пользователя с интерфейсом (например, добавление нового эмодзи), **View** вызывает методы **ViewModel**.
5. **ViewModel** обновляет данные в **Model**.
6. **Model** уведомляет **ViewModel** об изменениях.
7. **ViewModel** обновляет **View** через биндинги.

Таким образом, архитектура MVVM обеспечивает четкое разделение обязанностей и позволяет легко управлять сложностью приложения.
