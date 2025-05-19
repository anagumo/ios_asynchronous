import UIKit
import Combine

enum TransformationSection {
    case main
}

class HeroController: UIViewController {
    // MARK: UI Components
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var photoImageView: AsyncImageView!
    @IBOutlet private var infoTextView: UITextView!
    @IBOutlet private var transformationsCollectionView: UICollectionView!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    // MARK: Data Source
    typealias DataSource = UICollectionViewDiffableDataSource<TransformationSection, Transformation>
    typealias Spnapshot = NSDiffableDataSourceSnapshot<TransformationSection, Transformation>
    typealias CellRegistration = UICollectionView.CellRegistration<TransformationViewCell, Transformation>
    private var dataSource: DataSource?
    // MARK: Observed Objects
    private let heroViewModel: HeroViewModel
    private var subscribers: Set<AnyCancellable>
    
    // MARK: Lifecycle
    init(heroViewModel: HeroViewModel) {
        self.heroViewModel = heroViewModel
        self.subscribers = Set()
        super.init(nibName: "HeroView", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIComponents()
        bind()
        heroViewModel.load()
    }
    
    private func bind() {
        heroViewModel.appState.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.render(isLoading)
            }.store(in: &subscribers)
        
        heroViewModel.$hero
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hero in
                self?.render(hero)
            }.store(in: &subscribers)
        
        heroViewModel.$transformations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transformations in
                self?.render(transformations)
            }.store(in: &subscribers)
        
        heroViewModel.appState.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.render(errorMessage)
            }.store(in: &subscribers)
    }
    
    // MARK: Rendering Data
    private func render(_ isLoading: Bool) {
        if isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
    
    private func render(_ hero: Hero?) {
        guard let hero else { return }
        title = hero.name
        photoImageView.setImage(hero.photo)
        infoTextView.text = hero.info
        contentStackView.isHidden = false
        heroViewModel.loadTransformations()
    }
    
    private func render(_ transformations: [Transformation]) {
        var snapshot = Spnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(transformations)
        dataSource?.apply(snapshot)
        transformationsCollectionView.isHidden = false
    }
    
    private func render(_ errorMessage: String?) {
        guard let errorMessage else  { return }
        present(
            AlertBuilder().build(title: "Hero Error", message: errorMessage),
            animated: true
        )
    }
}
// MARK: - Collection View Delegates
extension HeroController {
    // MARK: UI Components Configuration
    private func configureUIComponents() {
        let cellNib = UINib(nibName: TransformationViewCell.identifier, bundle: Bundle(for: type(of: self)))
        let cell = CellRegistration(cellNib: cellNib) { cell, indexPath, transformation in
            cell.bind(transformation)
        }
        
        dataSource = DataSource(collectionView: transformationsCollectionView, cellProvider: { collectionView, indexPath, transformation in
                collectionView.dequeueConfiguredReusableCell(
                    using: cell,
                    for: indexPath,
                    item: transformation
                )
            }
        )
        
        transformationsCollectionView.dataSource = dataSource
        transformationsCollectionView.delegate = self
    }
}

extension HeroController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 150, height: 150)
    }
}
